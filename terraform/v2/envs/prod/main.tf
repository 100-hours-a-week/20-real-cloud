data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "ktb-20-terraform-backend-v2"
    key    = "envs/infra/terraform.tfstate"
    region = "ap-northeast-2"
  }
}

data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    bucket = "ktb-20-terraform-backend-v2"
    key    = "envs/dev/terraform.tfstate"
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
  nat_gateway_id             = data.terraform_remote_state.dev.outputs.nat_gateway_id
  create_nat_gateway         = var.create_nat_gateway

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

# module "alb" {
#   source            = "../../modules/alb"
#   subnet_ids        = module.network.public_subnet_ids
#   security_group_id = module.alb_sg.security_group_id

#   certificate_arn     = var.ap_acm_certificate_arn
#   target_group_vpc_id = module.network.vpc_id
#   target_group_port   = var.target_group_port

#   common_tags = local.common_tags
#   name_prefix = var.name_prefix
# }


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


module "compute" {
  source = "../../modules/compute"

  ec2_instances = var.ec2_instances
  lanch_templates = var.lanch_templates

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}
