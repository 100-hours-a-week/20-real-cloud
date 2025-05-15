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


variable "alb_target_group_arn" {
  description = "ALB Target Group ARN"
  type        = string
  default     = null
}

variable "instance_port" {
  description = "Port number of the instance to be used in the target group"
  type        = number
  default     = 80
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

