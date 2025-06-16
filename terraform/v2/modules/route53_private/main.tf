resource "aws_route53_record" "record" {
  zone_id = var.private_zone_id
  name    = "db-${var.common_tags.Environment}.internal.${var.apex_domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.db_ec2_private_dns]
}