output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_zone_id" {
  description = "The Route 53 hosted zone ID for the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "cloudfront_distribution_arn" {
  description = "The ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.this.arn
}
