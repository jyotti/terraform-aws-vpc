locals {
  nat_gateway_count = "${var.single_nat_gateway ? 1 : length(var.public_subnets)}"
}

#----------------------------------------------------------
# VPC

resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr_block}"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

#----------------------------------------------------------
# DHCP Options Set

#----------------------------------------------------------
# Internet Gateway

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

#----------------------------------------------------------
# Route Table

// public
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", "public"))}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

// private
resource "aws_route_table" "private" {
  count = "${local.nat_gateway_count}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", format("private.%s", element(var.availability_zones, count.index))))}"
}

// intra
resource "aws_route_table" "intra" {
  count = "${length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(var.tags, map("Name", "intra"))}"
}

#----------------------------------------------------------
# Subnet

// public
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(var.tags, var.public_subnet_tags, map("Name", format("public.%s", element(var.availability_zones, count.index))))}"
}

// private
resource "aws_subnet" "private" {
  count = "${length(var.private_subnets)}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(var.private_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = "${merge(var.tags, var.private_subnet_tags, map("Name", format("private.%s", element(var.availability_zones, count.index))))}"
}

// intra
resource "aws_subnet" "intra" {
  count = "${length(var.intra_subnets)}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(var.intra_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = "${merge(var.tags, var.intra_subnet_tags, map("Name", format("intra.%s", element(var.availability_zones, count.index))))}"
}

#----------------------------------------------------------
# NAT Gateway

resource "aws_eip" "nat" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  vpc = true

  tags = "${merge(var.tags, map("Name", format("%s-%s", var.name, element(var.availability_zones, count.index))))}"
}

resource "aws_nat_gateway" "this" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"

  tags = "${merge(var.tags, map("Name", format("%s.%s", var.name, element(var.availability_zones, count.index))))}"
}

resource "aws_route" "private_nat_gateway" {
  count = "${var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"
}

#----------------------------------------------------------
# RDS DB subnet group

resource "aws_db_subnet_group" "this" {
  count = "${length(var.intra_subnets) > 0 ? 1 : 0}"

  name        = "${lower(var.name)}"
  description = "Database subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.intra.*.id}"]

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

#----------------------------------------------------------
# Redshift subnet group

resource "aws_redshift_subnet_group" "this" {
  count = "${length(var.intra_subnets) > 0 ? 1 : 0}"

  name        = "${var.name}"
  description = "Redshift subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.intra.*.id}"]

  tags = "${merge(var.tags, map("Name", format("%s", var.name)))}"
}

#----------------------------------------------------------
# ElastiCache subnet group

resource "aws_elasticache_subnet_group" "this" {
  count = "${length(var.intra_subnets) > 0 ? 1 : 0}"

  name        = "${var.name}"
  description = "ElastiCache subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.intra.*.id}"]
}

#----------------------------------------------------------
# VPC Endpoint - S3

data "aws_vpc_endpoint_service" "s3" {
  count = "${var.enable_s3_endpoint ? 1 : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${var.enable_s3_endpoint ? 1 : 0}"

  vpc_id       = "${aws_vpc.this.id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_s3" {
  count = "${var.enable_s3_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = "${var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_s3" {
  count = "${var.enable_s3_endpoint && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.intra.id}"
}

#----------------------------------------------------------
# VPC Endpoint - DynamoDB

data "aws_vpc_endpoint_service" "dynamodb" {
  count = "${var.enable_dynamodb_endpoint ? 1 : 0}"

  service = "dynamodb"
}

resource "aws_vpc_endpoint" "dynamodb" {
  count = "${var.enable_dynamodb_endpoint ? 1 : 0}"

  vpc_id       = "${aws_vpc.this.id}"
  service_name = "${data.aws_vpc_endpoint_service.dynamodb.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "private_dynamodb" {
  count = "${var.enable_dynamodb_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "public_dynamodb" {
  count = "${var.enable_dynamodb_endpoint && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

resource "aws_vpc_endpoint_route_table_association" "intra_dynamodb" {
  count = "${var.enable_dynamodb_endpoint && length(var.intra_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.dynamodb.id}"
  route_table_id  = "${aws_route_table.intra.id}"
}

#----------------------------------------------------------
# Route Table Association

// public
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

// private
resource "aws_route_table_association" "private" {
  count = "${length(var.private_subnets)}"

  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "intra" {
  count = "${length(var.intra_subnets)}"

  subnet_id      = "${element(aws_subnet.intra.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.intra.*.id, count.index)}"
}
