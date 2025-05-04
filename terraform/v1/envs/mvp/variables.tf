# Network
variable "vpc_cidr_block" {
  description = "VPC CIDR block to which EC2 instance belongs"
  type        = string
  default     = ""
}

variable "public_subnet_cidr_block" {
  description = "Only one Public Subnet CIDR block belonging to the VPC"
  type        = string
  default     = ""
}

variable "availability_zone" {
  description = "Availability Zone where public subnet exist"
  type        = string
  default     = ""
}

variable "gcp_cidr_block" {
  description = "GCP Instance's CIDR"
  type        = string
  default     = ""
}

# Security
variable "vpc_id" {
  description = "VPC ID to associate with security group"
  type        = string
  default     = ""
}

variable "ingress_rules" {
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

variable "egress_rules" {
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

# Tags
variable "name_prefix" {
  description = "Name tag's prefix"
  type        = string
  default     = "KTB-CA"
}

variable "project_tag" {
  description = "Write down Project Name Tag"
  type        = string
  default     = "choon-assistant"
}

variable "environment_tag" {
  description = "Write down Project Environment Tag"
  type        = string
  default     = "mvp"
}

variable "version_tag" {
  description = "Write down Project Version Tag"
  type        = string
  default     = "v1"
}

variable "assignee_tag" {
  description = "Write down Assignee Tag"
  type        = string
}

#cdn
variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate to use for HTTPS"
  type        = string
}

variable "domain_name" {
  description = "The custom domain name (CNAME) to associate with the CloudFront distribution"
  type        = string
}

#storage
variable "s3_image_prefix" {
  description = "Key prefix within the bucket for static images"
  type        = string
}

variable "s3_log_prefix" {
  description = "Key prefix within the bucket for backend logs"
  type        = string
}

variable "s3_log_retention_days" {
  description = "Number of days to retain objects under the log prefix before expiration"
  type        = number
}

#compute
variable "ami_id" {
  description = "The AMI ID for the instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "key_name" {
  description = "The key pair name to use for SSH access."
  type        = string
}

variable "instance_associate_public_ip_address" {
  description = "Whether to associate a public IP address with the instance."
  type        = bool
}

# alb
variable "target_group_port" {
  description = "port number of target group"
  type        = number
}