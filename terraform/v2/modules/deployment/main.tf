resource "aws_codedeploy_app" "this" {
  name             = "${var.name_prefix}-${var.app_name}-deployment"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = var.service_role_arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  auto_scaling_groups = var.auto_scaling_groups

  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }
    green_fleet_provisioning_option {
      action = "DISCOVER_EXISTING"
    }
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = var.target_group_blue
      }
      target_group {
        name = var.target_group_green
      }
      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }
    }
  }
}
