resource "aws_route53_zone" "private" {
  name  = "internal.${var.apex_domain_name}"
  vpc {
    vpc_id = var.vpc_id
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-route53-private-zone"
    }
  )
}

resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.private.zone_id
  name    = "db-${var.common_tags.Environment}.internal.${var.apex_domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.db_ec2_private_dns]
}