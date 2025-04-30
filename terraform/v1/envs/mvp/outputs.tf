# Network 관련 outputs
output "vpc_id" {
  description = "Default VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "Default public subnet ID"
  value       = module.network.public_subnet_id
}

output "security_group_id" {
  description = "Security Group with traffic control rules"
  value       = module.security.security_group_id
}