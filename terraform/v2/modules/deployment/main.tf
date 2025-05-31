resource "aws_s3_bucket" "codedeploy_bucket" {
  bucket = "${var.name_prefix}-${var.app_name}-codedeploy-bucket"

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.app_name}-codedeploy-bucket"
    }
  )
}

resource "aws_codedeploy_app" "this" {
  name             = "${var.name_prefix}-${var.app_name}-deployment"
  compute_platform = "Server"

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.app_name}-deployment"
    }
  )
}

resource "aws_codedeploy_deployment_group" "this" {
  app_name               = aws_codedeploy_app.this.name
  deployment_group_name  = var.deployment_group_name
  service_role_arn       = var.service_role_arn
  deployment_config_name = var.deployment_config_name

  autoscaling_groups = var.auto_scaling_groups

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }

    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
    }


    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 60
    }
  }

  load_balancer_info {

      target_group_info {
        name = var.target_group_blue
      }

    
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.deployment_group_name}"
    }
  )
}
