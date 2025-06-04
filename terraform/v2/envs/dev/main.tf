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

module "iam" {
  source = "../../modules/iam"

  static_bucket_arn         = var.static_bucket_arn
  log_bucket_arn            = var.log_bucket_arn
  fe_code_deploy_bucket_arn = var.next_prod_code_deploy_bucket_arn
  be_code_deploy_bucket_arn = var.spring_prod_code_deploy_bucket_arn

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}
module "ec2_sg" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = var.ec2_ingress_rules
  egress_rules  = var.ec2_egress_rules

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "sg_application" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = module.sg_application.ingress_rules
  egress_rules  = module.sg_application.egress_rules

  common_tags = local.common_tags
  name_prefix = "${local.name_prefix}-app"
}

module "sg_database" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = module.sg_database.ingress_rules
  egress_rules  = module.sg_database.egress_rules

  common_tags = local.common_tags
  name_prefix = "${local.name_prefix}-db"
}

module "sg_monitoring" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = module.sg_monitoring.ingress_rules
  egress_rules  = module.sg_monitoring.egress_rules

  common_tags = local.common_tags
  name_prefix = "${local.name_prefix}-mon"
}

module "compute" {
  source = "../../modules/compute"
  ec2_instances = {

    "application" = {
      ami                         = var.ami_id
      instance_type               = "t3.small"
      subnet_id                   = module.network.private_subnet_ids[0]
      key_name                    = var.key_name
      security_group_ids          = [module.sg_application.security_group_id]
      associate_public_ip_address = false
      iam_instance_profile        = module.iam.ec2_iam_instance_profile_name
      use_eip                     = false
      user_data                   = file("../../modules/compute/scripts/init_userdata.sh")
    }
    "database" = {
      ami                         = var.ami_id
      instance_type               = "t3.small"
      subnet_id                   = module.network.private_subnet_ids[1]
      key_name                    = var.key_name
      security_group_ids          = [module.sg_database.security_group_id]
      associate_public_ip_address = false
      iam_instance_profile        = module.iam.ssm_iam_instance_profile_name
      use_eip                     = false
      user_data                   = file("../../modules/compute/scripts/db_userdata.sh")
    }

  }

  # ASG + Launch Template 정의
  lanch_templates = {}

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}