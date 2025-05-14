module "network" {
  source = "../../modules/network"

  is_infra_env               = var.is_infra_env
  internet_gateway_id        = var.internet_gateway_id
  vpc_id                     = var.vpc_id
  vpc_cidr_block             = var.vpc_cidr_block
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones         = var.availability_zones
  private_subnet_names       = var.private_subnet_names

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}