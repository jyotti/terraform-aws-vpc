variable "name" {
  description = "Name to be used on all the resources as identifier"
  default     = ""
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR block for public subnet"
  default     = []
}

variable "private_subnets" {
  description = "List of CIDR block for private subnet"
  default     = []
}

variable "intra_subnets" {
  description = "List of CIDR block for intra subnet"
  default     = []
}

variable "availability_zones" {
  description = "A list of availability zones in the region"
  type        = "list"
  default     = []
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
