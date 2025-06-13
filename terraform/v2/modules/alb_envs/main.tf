# target group
resource "aws_lb_target_group" "back" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-back-tg"
  port     = var.back_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/api/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-back-tg"
    }
  )
}

resource "aws_lb_target_group" "front" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-front-tg"
  port     = var.front_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-front-tg"
    }
  )
}

resource "aws_lb_target_group" "ws" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-ws-tg"
  port     = var.ws_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
  
    tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-ws-tg"
    }
  )
}

resource "aws_lb_target_group" "metric" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-metric-tg"
  port     = var.metric_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/monitoring-${var.common_tags.Environment}/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-metric-tg"
    }
  )
}

resource "aws_lb_listener_rule" "https_ws_rule" {
  listener_arn = var.https_listener_arn
  priority     = var.https_ws_listener_rule_priority 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ws.arn
  }

  condition {
    path_pattern {
      values = ["/ws/*"]
    }
    host_header {
      values = var.host_header_values.ws
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-https-ws-listener-rule"
    }
  )
}

resource "aws_lb_listener_rule" "https_front_rule" {
  listener_arn = var.https_listener_arn
  priority     = var.https_front_listener_rule_priority 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
    host_header {
      values = var.host_header_values.front
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-https-front-listener-rule"
    }
  )
}

resource "aws_lb_listener_rule" "https_back_rule" {
  listener_arn = var.https_listener_arn
  priority     = var.https_back_listener_rule_priority 

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
    host_header {
      values = var.host_header_values.back
    }
  }
}