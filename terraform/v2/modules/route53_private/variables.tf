variable "apex_domain_name" {
  description = "The Apex domain name to associate with the CloudFront distribution"
  type        = string
}

variable "db_ec2_private_dns" {
  description = "The database instance private DNS"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with subnet"
  type        = string
}

#tag용 변수
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "route53"
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}