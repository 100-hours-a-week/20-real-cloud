output "codedeploy_app_name" {
  value = aws_codedeploy_app.this.name
}

output "codedeploy_deployment_group_name" {
  value = aws_codedeploy_deployment_group.this.deployment_group_name
} 

output "codedeploy_s3_bucket_arn" {
  description = "The ARN of the S3 bucket used for CodeDeploy"
  value = aws_s3_bucket.codedeploy_bucket.arn
}