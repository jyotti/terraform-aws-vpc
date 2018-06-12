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
