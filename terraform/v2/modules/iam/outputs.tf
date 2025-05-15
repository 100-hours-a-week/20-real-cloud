output "cloudwatch_agent_agent_profile_name" {
  description = "Name of the CloudWatch agent profile"
  value       = aws_iam_instance_profile.cloudwatch_agent_profile.name
}


# s3_role + ssm_role
output "s3_iam_role_arn" {
  description = "ARN of the combined S3 backend IAM role"
  value       = aws_iam_role.s3_role.arn
}
output "s3_iam_instance_profile_name" {
  description = "Instance profile name for the combined S3 backend role"
  value       = aws_iam_instance_profile.s3_profile.name
}

output "ssm_iam_instance_profile_name" {
  description = "Instance profile name for the SSM role"
  value       = aws_iam_instance_profile.ssm_profile.name
}
