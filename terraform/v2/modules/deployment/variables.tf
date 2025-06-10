variable "module_name" {
  description = "Module name"
  type        = string
  default     = "codedeploy"
}

variable "name_prefix" {
  description = "Name prefix for the ECR repository"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "blue_green" {
  description = "Enable blue-green deployment"
  type        = bool
}

variable "app_name" {
  description = "CodeDeploy application name"
  type        = string
}

variable "deployment_group_name" {
  description = "CodeDeploy deployment group name"
  type        = string
}

variable "service_role_arn" {
  description = "IAM Role ARN for CodeDeploy"
  type        = string
}

variable "target_group_blue" {
  description = "Name of the blue target group"
  type        = string
  default     = ""
}

variable "listener_arn" {
  description = "Load balancer listener ARN for production traffic"
  type        = string
}

variable "auto_scaling_groups" {
  description = "List of Auto Scaling Groups for deployment"
  type        = list(string)
  default     = []
}

variable "deployment_config_name" {
  description = "Name of the deployment configuration"
  type        = string
  default     = "CodeDeployDefault.AllAtOnce"
}

variable "alarm_names" {
  description = "List of CloudWatch alarm names to monitor during deployment"
  type        = list(string)
  default     = []
} 