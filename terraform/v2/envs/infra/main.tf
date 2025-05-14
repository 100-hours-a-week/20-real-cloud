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