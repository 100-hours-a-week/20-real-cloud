variable "subnet_ids" {
  description = "subnet id list to attach ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group id to attach ALB"
  type        = string
}

variable "target_group_vpc_id" {
  description = "VPC ID of target group"
  type        = string
}

variable "certificate_arn" {
  description = "Certificate ARN for HTTPS"
  type        = string
}

#tag용 변수
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "alb"
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}