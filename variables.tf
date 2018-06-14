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

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = false
}

variable "enable_s3_endpoint" {
  description = "Should be true if you want to provision an S3 endpoint to the VPC"
  default     = false
}

variable "enable_dynamodb_endpoint" {
  description = "Should be true if you want to provision a DynamoDB endpoint to the VPC"
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}
