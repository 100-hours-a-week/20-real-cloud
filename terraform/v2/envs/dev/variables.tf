# Network
variable "is_infra_env" {
  description = "Is this environment an infra environment?"
  type        = bool
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block to which AWS Resources belong"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "Public Subnet CIDR blocks belonging to the VPC"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "Private Subnet CIDR blocks belonging to the VPC"
  type        = list(string)
}

variable "availability_zones" {
  description = "Availability Zone where public subnet exist"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Private Subnet Names (App or DB)"
  type        = list(string)
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway when this variable is true (In Dev Environment)"
  type        = bool
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID to associate with route table"
  type        = string
  default     = null
}

# Monitoring
variable "front_service_name" {
  description = "Frontend Service Name"
  type        = string
}

variable "back_service_name" {
  description = "Backend Service Name"
  type        = string
}

variable "db_service_name" {
  description = "Database Service Name"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain the logs in CloudWatch"
  type        = number
}

variable "front_log_group_names" {
  description = "Frontend Log group names"
  type        = list(string)
}

variable "back_log_group_names" {
  description = "Backend Log group names"
  type        = list(string)
}

variable "db_log_group_names" {
  description = "Database Log group names"
  type        = list(string)
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
variable  "next_prod_code_deploy_bucket_arn"{
  description = "ARN of the S3 bucket for Next.js code deployment"
  type        = string
}
variable  "spring_prod_code_deploy_bucket_arn"{
  description = "ARN of the S3 bucket for spring code deployment"
  type        = string
}