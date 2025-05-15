variable "module_name" {
  description = "Module name"
  type        = string
  default     = "iam"
}

variable "name_prefix" {
  description = "Name prefix for the ECR repository"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}