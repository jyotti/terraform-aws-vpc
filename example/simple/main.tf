provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

variable "cidr_block" {
  default = "10.100.0.0/16"
}

locals {
  # /18
  az1_18bit_cidr = "${cidrsubnet(var.cidr_block, 2, 0)}"
  az2_18bit_cidr = "${cidrsubnet(var.cidr_block, 2, 1)}"
  az3_18bit_cidr = "${cidrsubnet(var.cidr_block, 2, 2)}"
  az_spare_cidr  = "${cidrsubnet(var.cidr_block, 2, 3)}"

  # /19 - AZ1
  az1_19bit_cidr1 = "${cidrsubnet(local.az1_18bit_cidr, 1, 0)}"
  az1_19bit_cidr2 = "${cidrsubnet(local.az1_18bit_cidr, 1, 1)}"

  # /20 - AZ1
  az1_20bit_cidr1 = "${cidrsubnet(local.az1_19bit_cidr2, 1, 0)}"
  az1_20bit_cidr2 = "${cidrsubnet(local.az1_19bit_cidr2, 1, 1)}"

  # /19 - AZ2
  az2_19bit_cidr1 = "${cidrsubnet(local.az2_18bit_cidr, 1, 0)}"
  az2_19bit_cidr2 = "${cidrsubnet(local.az2_18bit_cidr, 1, 1)}"

  # /20 - AZ2
  az2_20bit_cidr1 = "${cidrsubnet(local.az2_19bit_cidr2, 1, 0)}"
  az2_20bit_cidr2 = "${cidrsubnet(local.az2_19bit_cidr2, 1, 1)}"

  # /19 - AZ3
  az3_19bit_cidr1 = "${cidrsubnet(local.az3_18bit_cidr, 1, 0)}"
  az3_19bit_cidr2 = "${cidrsubnet(local.az3_18bit_cidr, 1, 1)}"

  # /20 - AZ3
  az3_20bit_cidr1 = "${cidrsubnet(local.az3_19bit_cidr2, 1, 0)}"
  az3_20bit_cidr2 = "${cidrsubnet(local.az3_19bit_cidr2, 1, 1)}"
}

module "vpc" {
  source             = "../../"
  name               = "simple"
  cidr_block         = "${var.cidr_block}"
  public_subnets     = ["${local.az1_20bit_cidr1}", "${local.az2_20bit_cidr1}", "${local.az3_20bit_cidr1}"]
  availability_zones = "${data.aws_availability_zones.available.names}"

  tags = {
    Environment = "example"
  }
}
