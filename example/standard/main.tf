provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

variable "cidr_block" {
  default = "10.101.0.0/16"
}

locals {
  # Split by availability zones
  az1_18bit_cidr = "${cidrsubnet(var.cidr_block, 2, 0)}" # 10.0.0.0/18
  az2_18bit_cidr = "${cidrsubnet(var.cidr_block, 2, 1)}" # 10.0.64.0/18
  az3_18bit_cidr = "${cidrsubnet(var.cidr_block, 2, 2)}" # 10.0.128.0/18
  az_spare_cidr  = "${cidrsubnet(var.cidr_block, 2, 3)}" # 10.0.192.0/18

  # -------------------------------------------------------
  # AZ1
  az1_19bit_cidr1 = "${cidrsubnet(local.az1_18bit_cidr, 1, 0)}" # 10.0.0.0/19

  az1_19bit_cidr2 = "${cidrsubnet(local.az1_18bit_cidr, 1, 1)}" # 10.0.32.0/19

  # Split the second 19bit
  az1_20bit_cidr1 = "${cidrsubnet(local.az1_19bit_cidr2, 1, 0)}" # 10.0.32.0/20
  az1_20bit_cidr2 = "${cidrsubnet(local.az1_19bit_cidr2, 1, 1)}" # 10.0.48.0/20

  # Split the second 20bit
  az1_21bit_cidr1 = "${cidrsubnet(local.az1_20bit_cidr2, 1, 0)}" # 10.0.48.0/21
  az1_21bit_cidr2 = "${cidrsubnet(local.az1_20bit_cidr2, 1, 1)}" # 10.0.56.0/21

  # -------------------------------------------------------
  # AZ2
  az2_19bit_cidr1 = "${cidrsubnet(local.az2_18bit_cidr, 1, 0)}" # 10.0.64.0/19

  az2_19bit_cidr2 = "${cidrsubnet(local.az2_18bit_cidr, 1, 1)}" # 10.0.96.0/19

  # Split the second 19bit
  az2_20bit_cidr1 = "${cidrsubnet(local.az2_19bit_cidr2, 1, 0)}" # 10.0.96.0/20
  az2_20bit_cidr2 = "${cidrsubnet(local.az2_19bit_cidr2, 1, 1)}" # 10.0.112.0/20

  # Split the second 20bit
  az2_21bit_cidr1 = "${cidrsubnet(local.az2_20bit_cidr2, 1, 0)}" # 10.0.112.0/21
  az2_21bit_cidr2 = "${cidrsubnet(local.az2_20bit_cidr2, 1, 1)}" # 10.0.120.0/21

  # -------------------------------------------------------
  # AZ3
  az3_19bit_cidr1 = "${cidrsubnet(local.az3_18bit_cidr, 1, 0)}" # 10.0.128.0/19

  az3_19bit_cidr2 = "${cidrsubnet(local.az3_18bit_cidr, 1, 1)}" # 10.0.160.0/19

  # Split the second 19bit
  az3_20bit_cidr1 = "${cidrsubnet(local.az3_19bit_cidr2, 1, 0)}" # 10.0.160.0/20
  az3_20bit_cidr2 = "${cidrsubnet(local.az3_19bit_cidr2, 1, 1)}" # 10.0.176.0/20

  # Split the second 20bit
  az3_21bit_cidr1 = "${cidrsubnet(local.az3_20bit_cidr2, 1, 0)}" # 10.0.176.0/21
  az3_21bit_cidr2 = "${cidrsubnet(local.az3_20bit_cidr2, 1, 1)}" # 10.0.184.0/21
}

module "vpc" {
  source             = "../../"
  name               = "standard"
  cidr_block         = "${var.cidr_block}"
  public_subnets     = ["${local.az1_20bit_cidr1}", "${local.az2_20bit_cidr1}", "${local.az3_20bit_cidr1}"]
  private_subnets    = ["${local.az1_19bit_cidr1}", "${local.az2_19bit_cidr1}", "${local.az3_19bit_cidr1}"]
  intra_subnets      = ["${local.az1_21bit_cidr1}", "${local.az2_21bit_cidr1}", "${local.az3_21bit_cidr1}"]
  availability_zones = "${data.aws_availability_zones.available.names}"

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  tags = {
    Environment = "example"
  }

  public_subnet_tags = {
    Type = "public"
  }

  private_subnet_tags = {
    Type = "private"
  }

  intra_subnet_tags = {
    Type = "intra"
  }
}
