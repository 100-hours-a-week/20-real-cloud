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