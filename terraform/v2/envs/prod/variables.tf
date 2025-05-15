
# Network
variable "is_infra_env" {
  description = "Is this environment an infra environment?"
  type        = bool
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
  description = "Availability Zone where public subnet exist"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Private Subnet Names (App or DB)"
  type        = list(string)
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway when this variable is true (In Prod Environment)"
  type        = bool
}

#compute
variable "ec2_instances" {
  type = map(object({
    ami                         = string
    instance_type               = string
    subnet_id                   = string
    key_name                    = string
    security_group_ids          = list(string)
    associate_public_ip_address = bool
    iam_instance_profile        = string
    use_eip                     = bool
    user_data                   = string
  }))
}

variable "lanch_templates" {
  type = map(object({
    ami                  = string
    instance_type        = string
    key_name             = string
    user_data            = string
    security_group_ids   = list(string)
    iam_instance_profile = string
    alb_target_group_arn = string
    subnet_id          = string
  }))
}


#security groups
variable "ec2_ingress_rules" {
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

variable "ec2_egress_rules" {
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

variable "alb_ingress_rules" {
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

variable "alb_egress_rules" {
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
  default     = "prod"
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