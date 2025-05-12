// outputs.tf

#static
output "static_bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  value       = aws_s3_bucket.static.bucket_regional_domain_name
}
