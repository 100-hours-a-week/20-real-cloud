# Tags
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "security"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}