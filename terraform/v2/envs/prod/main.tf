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

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "monitoring_frontend" {
  source = "../../modules/monitoring"

  service_name = var.front_service_name
  retention_in_days = var.retention_in_days
  log_group_names = var.front_log_group_names

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "monitoring_backend" {
  source = "../../modules/monitoring"

  service_name = var.back_service_name
  retention_in_days = var.retention_in_days
  log_group_names = var.back_log_group_names

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "monitoring_database" {
  source = "../../modules/monitoring"

  service_name = var.db_service_name
  retention_in_days = var.retention_in_days
  log_group_names = var.db_log_group_names
  
  common_tags = local.common_tags
  name_prefix = local.name_prefix
}