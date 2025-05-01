module "network" {
  source = "../../modules/network"

  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  availability_zone        = var.availability_zone
  gcp_cidr_block           = var.gcp_cidr_block

}

module "security" {
  source = "../../modules/security"
  
  vpc_id = module.network.vpc_id

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}

module "storage" {
  source      = "../../modules/storage"
  bucket_name = var.domain_name

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "cdn" {
  source                      = "../../modules/cdn"
  bucket_name                 = var.domain_name
  bucket_arn                  = module.storage.bucket_arn
  bucket_regional_domain_name = module.storage.bucket_regional_domain_name
  domain_name                 = var.domain_name
  acm_certificate_arn         = var.acm_certificate_arn

  common_tags = local.common_tags
  name_prefix = local.name_prefix

}