data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "ktb-20-terraform-backend-v2"
    key    = "envs/infra/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

module "network" {
  source = "../../modules/network"

  is_infra_env               = var.is_infra_env
  vpc_id                     = data.terraform_remote_state.infra.outputs.vpc_id
  internet_gateway_id        = data.terraform_remote_state.infra.outputs.internet_gateway_id
  vpc_cidr_block             = var.vpc_cidr_block
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  availability_zones         = var.availability_zones
  private_subnet_names       = var.private_subnet_names
  create_nat_gateway         = var.create_nat_gateway
  nat_gateway_id             = var.nat_gateway_id

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

# module "iam" {
#   source = "../../modules/iam"

#   static_bucket_arn = var.static_bucket_arn
#   log_bucket_arn    = var.log_bucket_arn

#   common_tags = local.common_tags
#   name_prefix = local.name_prefix
# }
