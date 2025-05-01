variable "bucket_name" {
  description = "The name of the S3 bucket"
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