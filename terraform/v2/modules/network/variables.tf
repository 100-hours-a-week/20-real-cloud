variable "is_infra_env" {
  description = "In Infra environments this variable is true, in other environments this variable is false"
  type        = bool
}

variable "vpc_id" {
  description = "VPC ID to associate with subnet"
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet Gateway ID to associate with route table"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block to which EC2 instance belongs"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "Public Subnet CIDR blocks belonging to the VPC"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "Private Subnet CIDR blocks belonging to the VPC"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zone where public subnet exist"
  type        = list(string)
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway when this variable is true (In Dev Environment)"
  type        = bool
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID to associate with route table"
  type        = string
}

# Tags
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "network"
}

variable "common_tags" {
  description = "Common Tags"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}

variable "az_name_map" {
  type = map(string)
  default = {
    "ap-northeast-2a" = "Azone"
    "ap-northeast-2c" = "Czone"
  }
}

variable "private_subnet_names" {
  description = "Private Subnet names"
  type        = list(string)
}
