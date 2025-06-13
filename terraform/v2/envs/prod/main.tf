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

module "iam" {
  source = "../../modules/iam"

  static_bucket_arn         = var.static_bucket_arn
  log_bucket_arn            = var.log_bucket_arn
  fe_code_deploy_bucket_arn = module.deployment_next_prod.codedeploy_s3_bucket_arn
  be_code_deploy_bucket_arn = module.deployment_spring_prod.codedeploy_s3_bucket_arn

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "alb_envs" {
  source = "../../modules/alb_envs"

  https_listener_arn                 = data.terraform_remote_state.infra.outputs.https_listener_arn
  alb_arn                            = data.terraform_remote_state.infra.outputs.alb_arn
  https_front_listener_rule_priority = var.https_front_listener_rule_priority
  https_back_listener_rule_priority  = var.https_back_listener_rule_priority
  https_ws_listener_rule_priority    = var.https_ws_listener_rule_priority
  host_header_values                 = var.host_header_values
  back_target_group_port             = var.back_target_group_port
  front_target_group_port            = var.front_target_group_port
  ws_target_group_port               = var.ws_target_group_port
  metric_target_group_port           = var.metric_target_group_port
  target_group_vpc_id                = data.terraform_remote_state.infra.outputs.vpc_id
  certificate_arn                    = var.ap_acm_certificate_arn

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

module "compute" {
  source = "../../modules/compute"
  ec2_instances = {
    "bastion" = {
      ami                         = var.ami_id
      instance_type               = "t3.micro"
      subnet_id                   = data.terraform_remote_state.infra.outputs.public_subnet_ids[0]
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
      subnet_id                   = data.terraform_remote_state.infra.outputs.public_subnet_ids[0]
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
      subnet_id                   = data.terraform_remote_state.infra.outputs.private_subnet_ids[3]
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
      alb_target_group_arn = module.alb_envs.tg_front_blue_arn
      subnet_id            = data.terraform_remote_state.infra.outputs.private_subnet_ids[0]
    }

    "back-blue" = {
      ami                  = var.ami_id
      instance_type        = "t3.medium"
      key_name             = var.key_name
      user_data            = base64encode(file("../../modules/compute/scripts/init_userdata.sh"))
      security_group_ids   = [module.application_sg.security_group_id]
      iam_instance_profile = module.iam.ec2_iam_instance_profile_name
      alb_target_group_arn = module.alb_envs.tg_back_blue_arn
      subnet_id            = data.terraform_remote_state.infra.outputs.private_subnet_ids[0]
    }
  }


  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "route53_private" {
  source = "../../modules/route53_private"

  vpc_id = data.terraform_remote_state.infra.outputs.vpc_id
  db_ec2_private_dns = module.compute.db_ec2_private_dns
  apex_domain_name = var.apex_domain_name

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
  target_group_blue   = module.alb_envs.tg_front_blue_name

  blue_green = true

  depends_on = [module.compute]

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
  target_group_blue   = module.alb_envs.tg_back_blue_name

  blue_green = true

  depends_on = [module.compute]

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}
