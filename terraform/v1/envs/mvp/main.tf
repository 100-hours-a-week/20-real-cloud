module "network" {
  source = "../../modules/network"

  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  availability_zone        = var.availability_zone
  gcp_cidr_block           = var.gcp_cidr_block

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "security" {
  source = "../../modules/security"

  vpc_id = module.network.vpc_id

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "storage" {
  source                  = "../../modules/storage"
  s3_frontend_bucket_name = var.domain_name

  s3_reader_writer_iam_role_arn  = module.security.s3_reader_writer_iam_role_arn
  s3_reader_writer_iam_role_name = module.security.s3_reader_writer_iam_role_name
  s3_image_prefix            = var.s3_image_prefix
  s3_log_prefix              = var.s3_log_prefix
  s3_log_retention_days      = var.s3_log_retention_days

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "cdn" {
  source                      = "../../modules/cdn"
  bucket_name                 = var.domain_name
  bucket_arn                  = module.storage.frontend_bucket_arn
  bucket_regional_domain_name = module.storage.frontend_bucket_regional_domain_name
  domain_name                 = var.domain_name
  acm_certificate_arn         = var.acm_certificate_arn

  common_tags = local.common_tags
  name_prefix = local.name_prefix

}