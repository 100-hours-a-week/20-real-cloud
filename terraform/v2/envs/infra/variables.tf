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
  description = "Availability Zone where subnets exist"
  type        = list(string)
}

variable "public_subnet_environments" {
  description = "Environment (dev/prod) for each public subnet"
  type        = list(string)
}

variable "private_subnet_environments" {
  description = "Environment (dev/prod) for each private subnet"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Private Subnet names"
  type        = list(string)
  default     = null
}

# ALB SG
variable "alb_ingress_rules" {
  description = "Security Group's Ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
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
}

# CDN
variable "apex_domain_name" {
  description = "The Apex domain name to associate with the CloudFront distribution"
  type        = string
}

variable "us_acm_certificate_arn" { 
  description = "The ARN of the ACM certificate to use for HTTPS"
  type        = string
}

variable "ap_acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for HTTPS"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket (e.g. bucket.s3.region.amazonaws.com)"
  type        = string
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
  default     = "infra"
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

