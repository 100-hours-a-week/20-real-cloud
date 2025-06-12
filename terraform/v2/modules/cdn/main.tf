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

# # Route 53
# resource "aws_route53_zone" "public" {
#   name  = var.apex_domain_name

#   tags = merge(
#     local.default_tags,
#     {
#       Name = "${var.name_prefix}-${var.common_tags.Environment}-route53-public-zone"
#     }
#   )
# }

# resource "aws_route53_zone" "private" {
#   name  = "internal.${var.apex_domain_name}"
#   vpc {
#     vpc_id = var.vpc_id
#   }
#   private_zone = true

#   tags = merge(
#     local.default_tags,
#     {
#       Name = "${var.name_prefix}-${var.common_tags.Environment}-route53-private-zone"
#     }
#   )
# }

# resource "aws_route53_record" "records" {
#   for_each = {
#     for record in var.records : record.name => record
#   }

#   zone_id = var.hosted_zone_id
#   name    = each.value.name
#   type    = each.value.type
#   ttl     = each.value.ttl
#   records = [each.value.record_value]
# }


# // 밑 부분 수정해야됨

# # resource "aws_route53_record" "www_record" {
# #   zone_id = aws_route53_zone.public.zone_id
# #   name    = "www.${var.apex_domain_name}"
# #   type    = "A"

# #   alias {
# #     name                   = aws_cloudfront_distribution.this.domain_name
# #     zone_id                = "Z2FDTNDATAQYW2"
# #     evaluate_target_health = false
# #   }
# # }

# # resource "aws_route53_record" "api_record" {
# #   zone_id = aws_route53_zone.public.zone_id
# #   name    = "api.${var.apex_domain_name}"
# #   type    = "A"

# #   alias {
# #     name                   = var.alb_dns_name
# #     zone_id                = var.alb_zone_id
# #     evaluate_target_health = true
# #   }
# # }

# # resource "aws_route53_record" "cadev_record" {
# #   zone_id = aws_route53_zone.public.zone_id
# #   name    = "cadev.${var.apex_domain_name}"
# #   type    = "A"

# #   alias {
# #     name                   = var.alb_dns_name
# #     zone_id                = var.alb_zone_id
# #     evaluate_target_health = true
# #   }
# # }

# # resource "aws_route53_record" "collector_record" {
# #   zone_id = aws_route53_zone.public.zone_id
# #   name    = "collector.${var.apex_domain_name}"
# #   type    = "A"

# #   alias {
# #     name                   = var.alb_dns_name
# #     zone_id                = var.alb_zone_id
# #     evaluate_target_health = true
# #   }
# # }

# # resource "aws_route53_record" "monitor_record" {
# #   zone_id = aws_route53_zone.public.zone_id
# #   name    = "monitor.${var.apex_domain_name}"
# #   type    = "A"

# #   alias {
# #     name                   = var.alb_dns_name
# #     zone_id                = var.alb_zone_id
# #     evaluate_target_health = true
# #   }
# # }

# # resource "aws_route53_record" "db_dev_record" {
# #   zone_id = aws_route53_zone.private.zone_id
# #   name    = "db-dev.internal.${var.apex_domain_name}"
# #   type    = "CNAME"
# #   ttl     = 300
# #   records = [var.database_instance.private_dns]
# # }