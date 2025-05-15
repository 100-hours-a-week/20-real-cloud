output "log_group_names" {
  description = "Name of the CloudWatch log group"
  value       = [for group in aws_cloudwatch_log_group.this : group.name]
}
