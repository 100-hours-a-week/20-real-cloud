output "tg_front_blue_name" {
  description = "Frontend Blue Target Group Name"
  value       = aws_lb_target_group.front.name
}

output "tg_back_blue_name" {
  description = "Backend Blue Target Group Name"
  value       = aws_lb_target_group.back.name
}


output "tg_front_blue_arn" {
  description = "Frontend Blue Target Group ARN"
  value       = aws_lb_target_group.front.arn
}

output "tg_back_blue_arn" {
  description = "Backend Blue Target Group ARN"
  value       = aws_lb_target_group.back.arn
}