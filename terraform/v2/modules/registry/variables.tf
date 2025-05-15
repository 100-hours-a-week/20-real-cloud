variable "name_prefix" {
  description = "Name prefix for the ECR repository"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "module_name" {
  description = "Module name for tagging"
  type        = string
  default     = "registry"
}