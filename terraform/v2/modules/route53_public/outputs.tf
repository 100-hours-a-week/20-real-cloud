output "public_zone_id" {
  description = "Public Route 53 Zone ID"
  value       = aws_route53_zone.public.zone_id
}