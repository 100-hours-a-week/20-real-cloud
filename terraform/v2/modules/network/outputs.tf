output "vpc_id" {
  description = "VPC ID"
  value       = var.is_infra_env ? aws_vpc.this[0].id : null
}

output "public_subnet_ids" {
  description = "Public subnet ID in VPC"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "Private subnet ID in VPC"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = var.create_nat_gateway ? aws_nat_gateway.this[0].id : var.nat_gateway_id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID belonging to VPC"
  value       = var.is_infra_env ? aws_internet_gateway.this[0].id : var.internet_gateway_id
}