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
  create_nat_gateway         = var.create_nat_gateway
  nat_gateway_id             = var.nat_gateway_id

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "iam" {
  source = "../../modules/iam"

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "monitoring_bastion" {
  source = "../../modules/monitoring"

  service_name      = var.bastion_service_name
  retention_in_days = var.retention_in_days
  log_group_names   = var.bastion_log_group_names

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

module "ecr" {
  source = "../../modules/registry"

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

# module "codedeploy_next" {
#   source                = "../../modules/codedeploy"
#   app_name              = "next"
#   deployment_group_name = "next-bluegreen"
#   service_role_arn      = aws_iam_role.codedeploy.arn
#   target_group_blue     = aws_lb_target_group.next_blue.arn
#   target_group_green    = aws_lb_target_group.next_green.arn
#   listener_arn          = aws_lb_listener.frontend.arn
#   auto_scaling_groups   = [aws_autoscaling_group.next_asg.name]

#   common_tags = local.common_tags
#   name_prefix = local.name_prefix
# }

# module "codedeploy_springboot" {
#   source                = "../../modules/codedeploy"
#   app_name              = "springboot"
#   deployment_group_name = "springboot-bluegreen"
#   service_role_arn      = aws_iam_role.codedeploy.arn
#   target_group_blue     = aws_lb_target_group.spring_blue.arn
#   target_group_green    = aws_lb_target_group.spring_green.arn
#   listener_arn          = aws_lb_listener.frontend.arn
#   auto_scaling_groups   = [aws_autoscaling_group.spring_asg.name]

#   common_tags = local.common_tags
#   name_prefix = local.name_prefix
# }
