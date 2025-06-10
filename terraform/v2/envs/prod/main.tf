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

module "iam" {
  source = "../../modules/iam"

  static_bucket_arn         = var.static_bucket_arn
  log_bucket_arn            = var.log_bucket_arn
  fe_code_deploy_bucket_arn = module.deployment_next_prod.codedeploy_s3_bucket_arn
  be_code_deploy_bucket_arn = module.deployment_spring_prod.codedeploy_s3_bucket_arn

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

module "alb_sg" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = var.alb_ingress_rules
  egress_rules  = var.alb_egress_rules

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "database_sg" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = var.database_ingress_rules
  egress_rules  = var.database_egress_rules

  common_tags = local.common_tags
  name_prefix = "${local.name_prefix}-db"
}

module "application_sg" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = var.application_ingress_rules
  egress_rules  = var.application_egress_rules

  common_tags = local.common_tags
  name_prefix = "${local.name_prefix}-app"
}

module "monitoring_sg" {
  source = "../../modules/security_group"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  ingress_rules = var.monitoring_ingress_rules
  egress_rules  = var.monitoring_egress_rules

  common_tags = local.common_tags
  name_prefix = "${local.name_prefix}-mon"
}

module "alb" {
  source = "../../modules/alb"

  subnet_ids          = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  security_group_id   = module.alb_sg.security_group_id
  certificate_arn     = var.ap_acm_certificate_arn
  target_group_vpc_id = data.terraform_remote_state.infra.outputs.vpc_id

  back_target_group_port  = 8080
  front_target_group_port = 80

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "compute" {
  source = "../../modules/compute"
  ec2_instances = {
    "bastion" = {
      ami                         = var.ami_id
      instance_type               = "t3.micro"
      subnet_id                   = module.network.public_subnet_ids[0]
      key_name                    = var.key_name
      security_group_ids          = [module.ec2_sg.security_group_id]
      associate_public_ip_address = true
      iam_instance_profile        = module.iam.ssm_iam_instance_profile_name
      use_eip                     = true
      user_data                   = file("../../modules/compute/scripts/bastion_userdata.sh")
    }
    "monitoring" = {
      ami                         = var.ami_id
      instance_type               = "t3.micro"
      subnet_id                   = module.network.public_subnet_ids[0]
      key_name                    = var.key_name
      security_group_ids          = [module.monitoring_sg.security_group_id]
      associate_public_ip_address = true
      iam_instance_profile        = null
      use_eip                     = true
      user_data                   = file("../../modules/compute/scripts/monitoring_userdata.sh")
    }

    "database" = {
      ami                         = var.ami_id
      instance_type               = "t3.small"
      subnet_id                   = module.network.private_subnet_ids[2]
      key_name                    = var.key_name
      security_group_ids          = [module.database_sg.security_group_id]
      associate_public_ip_address = false
      iam_instance_profile        = module.iam.ssm_iam_instance_profile_name
      use_eip                     = false
      user_data                   = file("../../modules/compute/scripts/db_userdata.sh")
    }

  }

  # ASG + Launch Template 정의
  lanch_templates = {
    "front-blue" = {
      ami                  = var.ami_id
      instance_type        = "t3.small"
      key_name             = var.key_name
      user_data            = base64encode(file("../../modules/compute/scripts/init_userdata.sh"))
      security_group_ids   = [module.application_sg.security_group_id]
      iam_instance_profile = module.iam.ec2_iam_instance_profile_name
      alb_target_group_arn = module.alb.tg_front_blue_arn
      subnet_id            = module.network.private_subnet_ids[0]
    }

    "back-blue" = {
      ami                  = var.ami_id
      instance_type        = "t3.medium"
      key_name             = var.key_name
      user_data            = base64encode(file("../../modules/compute/scripts/init_userdata.sh"))
      security_group_ids   = [module.application_sg.security_group_id]
      iam_instance_profile = module.iam.ec2_iam_instance_profile_name
      alb_target_group_arn = module.alb.tg_back_blue_arn
      subnet_id            = module.network.private_subnet_ids[0]
    }
  }


  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "deployment_next_prod" {
  source = "../../modules/deployment"

  app_name               = "next"
  deployment_group_name  = "next-prod-deployment-group"
  service_role_arn       = module.iam.codedeploy_iam_role_arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_scaling_groups = ["${var.name_prefix}-front-blue-asg"]
  listener_arn        = module.alb.listener_front_arn
  target_group_blue   = module.alb.tg_front_blue_name

  blue_green = true

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "deployment_spring_prod" {
  source = "../../modules/deployment"

  app_name               = "spring"
  deployment_group_name  = "spring-prod-deployment-group"
  service_role_arn       = module.iam.codedeploy_iam_role_arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_scaling_groups = ["${var.name_prefix}-back-blue-asg"]
  listener_arn        = module.alb.listener_back_arn
  target_group_blue   = module.alb.tg_back_blue_name
  
  blue_green = true
  
  common_tags = local.common_tags
  name_prefix = local.name_prefix
}
