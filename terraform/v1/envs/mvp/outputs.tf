# Network
output "vpc_id" {
  description = "Default VPC ID"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Default public subnet ID"
  value       = module.network.public_subnet_ids
}

# Security
output "security_group_id" {
  description = "Security Group with traffic control rules"
  value       = module.ec2_sg.security_group_id
}