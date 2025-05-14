# Network
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
  description = "Availability Zone where public subnet exist"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Private Subnet Names (App or DB)"
  type        = list(string)
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
  default     = "dev"
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