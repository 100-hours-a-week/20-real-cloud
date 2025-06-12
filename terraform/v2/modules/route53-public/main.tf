resource "aws_route53_zone" "public" {
  name  = var.apex_domain_name

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-route53-public-zone"
    }
  )
}

resource "aws_route53_record" "www_record" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "www.${var.apex_domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_record" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "api.${var.apex_domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cadev_record" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "cadev.${var.apex_domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "collector_record" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "collector.${var.apex_domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "monitor_record" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "monitor.${var.apex_domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}