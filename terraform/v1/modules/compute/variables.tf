variable "ami_id" {
  description = "The AMI ID for the instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID to launch the instance in."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID in which resources will be created."
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