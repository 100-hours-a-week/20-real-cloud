output "cloudwatch_agent_agent_profile_name" {
  description = "Name of the CloudWatch agent profile"
  value       = aws_iam_instance_profile.cloudwatch_agent_profile.name
}


