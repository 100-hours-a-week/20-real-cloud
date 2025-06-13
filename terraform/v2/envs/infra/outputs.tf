output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
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
