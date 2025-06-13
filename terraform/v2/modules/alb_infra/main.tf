# Application Load Balancer
resource "aws_lb" "this" {
  name               = "${var.name_prefix}-${var.common_tags.Environment}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = [var.security_group_id]

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-alb"
    }
  )
}

resource "aws_lb_target_group" "signoz_monitor" {
  name     = "${var.name_prefix}-signoz-monitor-tg"
  port     = 8080
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
      Name = "${var.name_prefix}-signoz-monitor-tg"
    }
  )
}

resource "aws_lb_target_group" "signoz_collector" {
  name     = "${var.name_prefix}-signoz-collector-tg"
  port     = 4318
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 5
    unhealthy_threshold = 2
    port                = 13133
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-signoz-monitor-tg"
    }
  )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-http-listener"
    }
  )
}

resource "aws_lb_listener" "https" { 
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type           = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "잘못된 경로 입니다..."
      status_code  = "404"
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-https-listener"
    }
  )
}

resource "aws_lb_listener_rule" "https_monitor_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 997

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.signoz_monitor.arn
  }

  condition {
    host_header {
      values = ["monitor.kakaotech.com"]
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-https-monitor-listener-rule"
    }
  )
}

resource "aws_lb_listener_rule" "https_collector_rule" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 998

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.signoz_collector.arn
  }

  condition {
    host_header {
      values = ["collector.kakaotech.com"]
    }
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-https-collector-listener-rule"
    }
  )
}
