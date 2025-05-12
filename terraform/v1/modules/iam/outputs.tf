# iam
output "s3_iam_role_arn" {
  description = "ARN of the combined S3 backend IAM role"
  value       = aws_iam_role.s3_role.arn
}
output "s3_iam_instance_profile_name" {
  description = "Instance profile name for the combined S3 backend role"
  value       = aws_iam_instance_profile.s3_profile.name
}
