# Network
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
  description = "VPC CIDR block to which AWS Resources belong"
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
  description = "Availability Zone where subnets exist"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Private Subnet names"
  type        = list(string)
  default     = null
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID to associate with route table"
  type        = string
  default     = null
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway when this variable is true (In Dev Environment)"
  type        = bool
}

# Tags
variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
  default     = "ktb-ca"
}

variable "project_tag" {
  description = "Write down Project Name Tag"
  type        = string
  default     = "choon-assistant"
}

variable "environment_tag" {
  description = "Write down Project Environment Tag"
  type        = string
  default     = "infra"
}

variable "version_tag" {
  description = "Write down Project Version Tag"
  type        = string
  default     = "v2"
}

variable "assignee_tag" {
  description = "Write down Assignee Tag"
  type        = string
}