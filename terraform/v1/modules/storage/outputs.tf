// outputs.tf

#frontend
output "website_url" {
  description = "The website endpoint of the S3 bucket"
  value       = aws_s3_bucket_website_configuration.frontend.website_endpoint
}

output "frontend_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}


# backend
output "backend_bucket_arn" {
  description = "The ARN of the backend S3 bucket"
  value       = aws_s3_bucket.backend.arn
}
