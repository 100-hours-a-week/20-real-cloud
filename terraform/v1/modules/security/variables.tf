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