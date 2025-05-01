variable "bucket_name" {
  description = "The name of the S3 bucket to serve as the CloudFront origin"
  type        = string
}

variable "bucket_arn" {
  description = "The ARN of the S3 bucket for policy statements"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket (e.g. bucket.s3.region.amazonaws.com)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for HTTPS"
  type        = string
}

variable "domain_name" {
  description = "The custom domain name (CNAME) to associate with the CloudFront distribution"
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