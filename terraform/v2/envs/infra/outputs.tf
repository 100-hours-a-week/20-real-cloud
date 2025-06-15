output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb_infra.alb_arn
}

output "public_subnet_ids" {
  description = "Public Subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private Subnet IDs"
  value       = module.network.private_subnet_ids
}

output "public_zone_id" {
  description = "Public Route 53 Zone ID"
  value       = module.route53_public.public_zone_id
}

output "https_listener_arn" {
  description = "HTTPS Listener ARN"
  value       = module.alb_infra.https_listener_arn
}
