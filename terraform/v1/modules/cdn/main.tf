# modules/cloudfront/main.tf
resource "aws_cloudfront_origin_access_control" "static_oac" {
  name                              = "${var.name_prefix}-static-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront for ${var.domain_name}"
  default_root_object = "index.html"

  aliases = [var.domain_name]

  origin {
    origin_id                = "s3_origin"
    domain_name              = var.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.static_oac.id
  }

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb_origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb_origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies { forward = "all" }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }
  ordered_cache_behavior {
    path_pattern           = "/images/*"
    target_origin_id       = "s3_origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-cloudfront"
    }
  )

}

# Route 53
data "aws_route53_zone" "this" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "alias_record" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = "Z2FDTNDATAQYW2" # CloudFront 고정 Zone ID
    evaluate_target_health = false
  }
}