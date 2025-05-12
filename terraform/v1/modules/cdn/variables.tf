variable "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket (e.g. bucket.s3.region.amazonaws.com)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for HTTPS"
  type        = string
}

variable "apex_domain_name" {
  description = "The Apex domain name to associate with the CloudFront distribution"
  type        = string
}

# variable "alb_dns_name" {
#   description = "The DNS name of the ALB"
#   type        = string
# }


variable "instance_public_dns" {
  description = "The public DNS name of the EC2 instance"
  type        = string
}


#tag용 변수
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "cdn"
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}