variable "ami_id" {
  description = "The AMI ID for the instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID in which resources will be created."
  type        = string
}

variable "key_name" {
  description = "The key pair name to use for SSH access."
  type        = string
}

variable "instance_security_group_ids" {
  description = "List of security group IDs to associate with the instance."
  type        = list(string)
}

variable "instance_associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance."
  type        = bool
}

variable "iam_instance_profile" {
  description = "iam profile"
  type        = string
}

# variable "alb_target_group_arn" {
#   description = "ALB Target Group ARN"
#   type        = string
# }

# variable "instance_port" {
#   description = "Port number of the instance to be used in the target group"
#   type        = number
#   default     = 80
# }

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

