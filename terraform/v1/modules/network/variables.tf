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
