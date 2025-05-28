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

output "tg_front_blue_name" {
  description = "Frontend Blue Target Group Name"
  value       = aws_lb_target_group.front_blue.name
}

output "tg_back_blue_name" {
  description = "Backend Blue Target Group Name"
  value       = aws_lb_target_group.back_blue.name
}

output "listener_front_arn" {
  description = "Frontend Listener ARN"
  value       = aws_lb_listener.fe_prod.arn
}


output "listener_back_arn" {
  description = "Backend Listener ARN"
  value       = aws_lb_listener.be_prod.arn
}
