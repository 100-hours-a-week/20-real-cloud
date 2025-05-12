#log
variable "s3_iam_role_arn" {
  description = "IAM role ARN that can read images and write/read/delete logs"
  type        = string
}

variable "s3_log_retention_days" {
  description = "Number of days to retain objects under the log prefix before expiration"
  type        = number
}

variable "cloudfront_distribution_arn" {
  description = "value of the ARN of the CloudFront distribution"
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