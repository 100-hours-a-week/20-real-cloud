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


# Tags
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "security"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}