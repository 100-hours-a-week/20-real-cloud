module "network" {
  source = "../../modules/network"

  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_cidr_blocks   = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks  = var.private_subnet_cidr_blocks
  availability_zones          = var.availability_zones
  private_subnet_names        = var.private_subnet_names
  public_subnet_environments  = var.public_subnet_environments
  private_subnet_environments = var.private_subnet_environments

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}

# module "ecr" {
#   source = "../../modules/registry"

#   common_tags = local.common_tags
#   name_prefix = local.name_prefix
# }

# module "alb_sg" {
#   source = "../../modules/security_group"

#   vpc_id = module.network.vpc_id

#   ingress_rules = var.alb_ingress_rules
#   egress_rules  = var.alb_egress_rules

#   common_tags = local.common_tags
#   name_prefix = local.name_prefix
# }

# module "alb" {
#   source = "../../modules/alb"

#   subnet_ids          = [module.network.public_subnet_ids[0], module.network.public_subnet_ids[1]]
#   security_group_id   = module.alb_sg.security_group_id
#   certificate_arn     = var.ap_acm_certificate_arn
#   target_group_vpc_id = module.network.vpc_id

#   back_target_group_port  = 8080
#   front_target_group_port = 3000

#   common_tags = local.common_tags
#   name_prefix = local.name_prefix
# }

# module "storage" {
#   source = "../../modules/storage"
# }

# module "cdn" {
#   source = "../../modules/cdn"

#   vpc_id = module.network.vpc_id
#   alb_dns_name = var.alb_dns_name
#   bucket_regional_domain_name = var.bucket_regional_domain_name
#   acm_certificate_arn = var.us_acm_certificate_arn
#   apex_domain_name = var.apex_domain_name
#   hosted_zone_id = var.hosted_zone_id
#   records = var.records

#   common_tags = local.common_tags
#   name_prefix = local.name_prefix
# }






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
