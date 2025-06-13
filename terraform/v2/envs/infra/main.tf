module "network" {
  source = "../../modules/network"

  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_cidr_blocks   = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks  = var.private_subnet_cidr_blocks
  availability_zones          = var.availability_zones
  private_subnet_names        = var.private_subnet_names
  public_subnet_environments  = var.public_subnet_environments
  private_subnet_environments = var.private_subnet_environments

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "alb_sg" {
  source = "../../modules/security_group"

  vpc_id = module.network.vpc_id

  ingress_rules = var.alb_ingress_rules
  egress_rules  = var.alb_egress_rules

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "alb_infra" {
  source = "../../modules/alb_infra"

  subnet_ids        = [module.network.public_subnet_ids[0], module.network.public_subnet_ids[1], module.network.public_subnet_ids[2]]
  security_group_id = module.alb_sg.security_group_id
  target_group_vpc_id = module.network.vpc_id
  certificate_arn     = var.ap_acm_certificate_arn

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

# module "stroage"
# 이후에 S3 마이그레이션 시 추가 필요

module "cdn" {
  source = "../../modules/cdn"

  alb_dns_name                = module.alb_infra.alb_dns_name
  bucket_regional_domain_name = var.bucket_regional_domain_name
  acm_certificate_arn         = var.us_acm_certificate_arn
  apex_domain_name            = var.apex_domain_name

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "route53_public" {
  source = "../../modules/route53_public"

  apex_domain_name       = var.apex_domain_name
  alb_dns_name           = module.alb_infra.alb_dns_name
  alb_zone_id            = module.alb_infra.alb_zone_id
  cloudfront_domain_name = module.cdn.cloudfront_domain_name


  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "ecr" {
  source = "../../modules/registry"

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

// 이후에 S3 마이그레이션 시 추가 필요
# module "storage" {
#   source = "../../modules/storage"
# }
