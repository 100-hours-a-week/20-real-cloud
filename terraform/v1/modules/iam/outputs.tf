# iam
output "s3_reader_writer_iam_role_arn" {
  description = "ARN of the combined S3 reader/writer IAM role"
  value       = aws_iam_role.s3_reader_writer_role.arn
}
output "s3_reader_writer_iam_instance_profile_name" {
  description = "Instance profile name for the combined S3 reader/writer role"
  value       = aws_iam_instance_profile.s3_reader_writer_profile.name
}
