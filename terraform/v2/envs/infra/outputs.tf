output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID belonging to VPC"
  value       = module.network.internet_gateway_id
}
