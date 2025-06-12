# modules/cloudfront/main.tf
resource "aws_cloudfront_origin_access_control" "static_oac" {
  name                              = "${var.name_prefix}-static-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront for ${var.apex_domain_name}"

  aliases = [
    var.apex_domain_name,
    "www.${var.apex_domain_name}"
  ]

  custom_error_response {
    error_code            = 502
    response_code         = 200
    response_page_path    = "/static/errorpage/502Error.html"
    error_caching_min_ttl = 30
  }

  custom_error_response {
    error_code            = 503
    response_code         = 200
    response_page_path    = "/static/errorpage/503Error.html"
    error_caching_min_ttl = 10
  }

  custom_error_response {
    error_code            = 504
    response_code         = 200
    response_page_path    = "/static/errorpage/504Error.html"
    error_caching_min_ttl = 30
  }

  origin {
    origin_id                = "s3-origin"
    domain_name              = var.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.static_oac.id
  }

  # ALB Origin (for backend)
  origin {
    origin_id   = "alb-origin"
    domain_name = var.alb_dns_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  ordered_cache_behavior {
    path_pattern           = "/static/*"
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

  ordered_cache_behavior {
    path_pattern           = "/static/errorpage/502Error.html"
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    
    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" 
  }

  ordered_cache_behavior {
    path_pattern           = "/static/errorpage/503Error.html"
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    
    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" 
  }

  ordered_cache_behavior {
    path_pattern           = "/static/errorpage/504Error.html"
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    
    compress = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6" 
  }

  price_class = "PriceClass_200"

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
