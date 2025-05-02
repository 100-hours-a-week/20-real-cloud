#frontend
variable "s3_frontend_bucket_name" {
  description = "The name of the S3 bucket for static website hosting"
  type        = string
}

#backend
variable "s3_reader_writer_iam_role_arn" {
  description = "IAM role ARN that can read images and write/read/delete logs"
  type        = string
}

variable "s3_image_prefix" {
  description = "Key prefix within the bucket for static images"
  type        = string
  default     = "images"
}

variable "s3_log_prefix" {
  description = "Key prefix within the bucket for backend logs"
  type        = string
  default     = "logs"
}

variable "s3_log_retention_days" {
  description = "Number of days to retain objects under the log prefix before expiration"
  type        = number
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