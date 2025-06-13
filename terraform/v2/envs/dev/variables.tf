# ALB_ENV
variable "https_front_listener_rule_priority" {
  description = "priority of frontend listener rule"
  type        = number
}

variable "https_back_listener_rule_priority" {
  description = "priority of backend listener rule"
  type        = number
}

variable "https_ws_listener_rule_priority" {
  description = "priority of websocket listener rule"
  type        = number
}

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

variable "host_header_values" {
  description = "host header values (dev/prod environment)"
  type = object({
    ws    = list(string)
    front = list(string)
    back  = list(string)
  })
}

variable "ap_acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "apex_domain_name" {
  description = "The Apex domain name to associate with the CloudFront distribution"
  type        = string
}

# Tags
variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
  default     = "ktb-ca"
}

variable "project_tag" {
  description = "Write down Project Name Tag"
  type        = string
  default     = "choon-assistant"
}

variable "environment_tag" {
  description = "Write down Project Environment Tag"
  type        = string
  default     = "dev"
}

variable "version_tag" {
  description = "Write down Project Version Tag"
  type        = string
  default     = "v2"
}

variable "assignee_tag" {
  description = "Write down Assignee Tag"
  type        = string
}

#IAM
variable "static_bucket_arn" {
  description = "ARN of the S3 bucket for static files"
  type        = string
}
variable "log_bucket_arn" {
  description = "ARN of the S3 bucket for log files"
  type        = string
}

#compute
variable "ami_id" {
  description = "The AMI ID for the instance."
  type        = string
}

variable "key_name" {
  description = "The key pair name to use for SSH access."
  type        = string
}


#security groups
variable "ec2_ingress_rules" {
  description = "Security Group's Ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "ec2_egress_rules" {
  description = "Security Group's Egress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}
variable "next_prod_code_deploy_bucket_arn" {
  description = "ARN of the S3 bucket for Next.js code deployment"
  type        = string
}
variable "spring_prod_code_deploy_bucket_arn" {
  description = "ARN of the S3 bucket for spring code deployment"
  type        = string
}

variable "application_ingress_rules" {
  description = "Security Group's Ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "application_egress_rules" {
  description = "Security Group's Egress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "database_ingress_rules" {
  description = "Security Group's Ingress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "database_egress_rules" {
  description = "Security Group's Egress rules"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

