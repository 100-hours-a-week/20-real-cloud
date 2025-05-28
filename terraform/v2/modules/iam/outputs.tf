output "cloudwatch_agent_agent_profile_name" {
  description = "Name of the CloudWatch agent profile"
  value       = aws_iam_instance_profile.cloudwatch_agent_profile.name
}


# s3_role + ssm_role + codedeploy_role
output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}
output "ec2_iam_instance_profile_name" {
  description = "Instance profile name for the EC2 role"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ssm_iam_instance_profile_name" {
  description = "Instance profile name for the SSM role"
  value       = aws_iam_instance_profile.ssm_profile.name
}

output "codedeploy_iam_role_arn" {
  description = "ARN of the CodeDeploy IAM role"
  value       = aws_iam_role.codedeploy_role.arn
}
