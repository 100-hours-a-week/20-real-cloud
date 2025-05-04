module "network" {
  source = "../../modules/network"

  vpc_cidr_block           = var.vpc_cidr_block
  public_subnet_cidr_block = var.public_subnet_cidr_block
  availability_zone        = var.availability_zone
  gcp_cidr_block           = var.gcp_cidr_block

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "ec2_sg" {
  source = "../../modules/security_group"

  vpc_id = module.network.vpc_id

  ingress_rules = var.ec2_ingress_rules
  egress_rules  = var.ec2_egress_rules

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

module "iam" {
  source = "../../modules/iam"

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}


module "storage" {
  source                  = "../../modules/storage"
  s3_frontend_bucket_name = var.domain_name

  s3_reader_writer_iam_role_arn = module.iam.s3_reader_writer_iam_role_arn
  s3_image_prefix               = var.s3_image_prefix
  s3_log_prefix                 = var.s3_log_prefix
  s3_log_retention_days         = var.s3_log_retention_days

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
  alb_dns_name                = module.alb.alb_dns_name

  common_tags = local.common_tags
  name_prefix = local.name_prefix

}

module "compute" {
  source = "../../modules/compute"

  ami_id                               = var.ami_id
  instance_type                        = var.instance_type
  subnet_id                            = module.network.public_subnet_id
  vpc_id                               = module.network.vpc_id
  key_name                             = var.key_name
  instance_security_group_ids          = [module.ec2_sg.security_group_id]
  instance_associate_public_ip_address = var.instance_associate_public_ip_address
  iam_instance_profile                 = module.iam.s3_reader_writer_iam_instance_profile_name

  alb_target_group_arn = module.alb.target_group_arn
  instance_port        = var.target_group_port

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "alb" {
  source            = "../../modules/alb"
  subnet_ids        = [module.network.public_subnet_id]
  security_group_id = module.alb_sg.security_group_id

  certificate_arn     = var.acm_certificate_arn
  target_group_vpc_id = module.network.vpc_id
  target_group_port   = var.target_group_port

  common_tags = local.common_tags
  name_prefix = var.name_prefix
}