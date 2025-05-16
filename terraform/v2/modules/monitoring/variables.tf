# variable "environment" {
#   description = "Environment name (e.g. dev, prod)"
#   type        = string
# }

variable "log_group_names" {
  description = "Log group names"
  type        = list(string)
}

variable "service_name" {
  description = "Service name (e.g. frontend, backend, database)"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain the logs in CloudWatch"
  type        = number
  default     = 14
}

variable "module_name" {
  description = "Module name"
  type        = string
  default     = "monitoring"
}

variable "name_prefix" {
  description = "Name prefix for the ECR repository"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}