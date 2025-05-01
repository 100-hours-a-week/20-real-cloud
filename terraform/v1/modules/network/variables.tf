variable "vpc_cidr_block" {
  description = "VPC CIDR block to which EC2 instance belongs"
  type        = string
  default     = ""
}

variable "public_subnet_cidr_block" {
  description = "Only one Public Subnet CIDR block belonging to the VPC"
  type        = string
  default     = ""
}

variable "availability_zone" {
  description = "Availability Zone where public subnet exist"
  type        = string
  default     = ""
}

variable "gcp_cidr_block" {
  description = "GCP Instance's CIDR"
  type        = string
  default     = ""
}

# Tags
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "network"
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}