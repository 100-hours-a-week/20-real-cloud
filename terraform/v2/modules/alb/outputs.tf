output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "tg_front_blue_arn" {
  description = "Frontend Blue Target Group ARN"
  value       = aws_lb_target_group.front_blue.arn
}

output "tg_back_blue_arn" {
  description = "Backend Blue Target Group ARN"
  value       = aws_lb_target_group.back_blue.arn
}

