# Network
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

# Security
variable "security_group_name" {
  description = "Security Group Name"
  type        = string
  default     = ""
}

variable "security_group_description" {
  description = "Security Group Description"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID to associate with security group"
  type        = string
  default     = ""
}

variable "ingress_rules" {
  description = "Security Group's Ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "Security Group's Egress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}