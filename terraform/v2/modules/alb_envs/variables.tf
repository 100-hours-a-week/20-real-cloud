variable "back_target_group_port" {
  description = "port number of backend target group"
  type        = number
}

variable "front_target_group_port" {
  description = "port number of frontend target group"
  type        = number
}

variable "ws_target_group_port" {
  description = "port number of websocket target group"
  type        = number
}

variable "metric_target_group_port" {
  description = "port number of metric target group"
  type        = number
}

variable "target_group_vpc_id" {
  description = "VPC ID of target group"
  type        = string
}

variable "certificate_arn" {
  description = "Certificate ARN for HTTPS"
  type        = string
}

variable "alb_arn" {
  description = "ALB ARN"
  type        = string
}

variable "https_listener_arn" {
  description = "HTTPS 리스너 ARN"
  type        = string
}

variable "https_ws_listener_rule_priority" {
  description = "priority of websocket listener rule"
  type        = number
}

variable "https_front_listener_rule_priority" {
  description = "priority of frontend listener rule"
  type        = number
}

variable "https_back_listener_rule_priority" {
  description = "priority of backend listener rule"
  type        = number
}

variable "host_header_values" {
  description = "호스트 헤더 값들 (dev/prod 환경별로 다름)"
  type = object({
    ws    = list(string)
    front = list(string)
    back  = list(string)
  })
}

#tag용 변수
variable "module_name" {
  description = "Module name used for Module tag"
  type        = string
  default     = "alb"
}

variable "common_tags" {
  description = "공통 태그"
  type        = map(string)
}

variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
}