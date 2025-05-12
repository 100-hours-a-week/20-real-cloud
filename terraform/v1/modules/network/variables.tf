variable "vpc_cidr_block" {
  description = "VPC CIDR block to which EC2 instance belongs"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "Only one Public Subnet CIDR block belonging to the VPC"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zone where public subnet exist"
  type        = list(string)
}

variable "gcp_cidr_block" {
  description = "GCP Instance's CIDR"
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