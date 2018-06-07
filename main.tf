variable "name" {}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR block for public subnet"
  default     = []
}

variable "private_subnets" {
  description = "List of CIDR block for private subnet"
  default     = []
}

variable "availability_zones" {
  type    = "list"
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

#----------------------------------------------------------
# VPC
resource "aws_vpc" "this" {
  cidr_block           = "${var.cidr_block}"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = "${merge(map("Name", format("%s", var.name)))}"
}

#----------------------------------------------------------
# DHCP Options Set

#----------------------------------------------------------
# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(map("Name", format("%s", var.name)))}"
}

#----------------------------------------------------------
# Route Table
// public
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.this.id}"
  tags   = "${merge(map("Name", format("%s", "public")))}"
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

#----------------------------------------------------------
# Route Table - private
resource "aws_route_table" "private" {
  count = "${length(var.private_subnets)}"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${merge(map("Name", format("%s", "private")))}"
}

#----------------------------------------------------------
# Subnet - public
resource "aws_subnet" "public" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.this.id}"
  cidr_block              = "${element(var.public_subnets, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags = "${merge(map("Name", format("public.%s", element(var.availability_zones, count.index))))}"
}

#----------------------------------------------------------
# Route Table Association
resource "aws_route_table_association" "public" {
  count = "${length(var.public_subnets)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
