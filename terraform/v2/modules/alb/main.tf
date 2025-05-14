##ALB
# Application Load Balancer
resource "aws_lb" "this" {
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

# target group
resource "aws_lb_target_group" "back_blue" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-tg-back-blue"
  port     = var.back_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-tg-back-blue"
    }
  )
}

resource "aws_lb_target_group" "back_green" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-tg-back-green"
  port     = var.back_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-tg-back-green"
    }
  )
}

resource "aws_lb_target_group" "front_blue" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-tg-front-blue"
  port     = var.back_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-tg-front-blue"
    }
  )
}

resource "aws_lb_target_group" "front_green" {
  name     = "${var.name_prefix}-${var.common_tags.Environment}-tg-front-green"
  port     = var.front_target_group_port
  protocol = "HTTP"
  vpc_id   = var.target_group_vpc_id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-tg-front-green"
    }
  )
}

# listener
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
      Name = "${var.name_prefix}-${var.common_tags.Environment}-listener"
    }
  )

}

resource "aws_lb_listener" "fe_prod" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_blue.arn
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-fe-prod-listener"
    }
  )
}

resource "aws_lb_listener" "fe_test" {
  load_balancer_arn = aws_lb.this.arn
  port              = 1443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_green.arn
  }

  tags = {
    Name = "${var.name_prefix}-${var.common_tags.Environment}-fe-test-listener"
  }
}

resource "aws_lb_listener" "be_prod" {
  load_balancer_arn = aws_lb.this.arn
  port              = 9443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_blue.arn
  }

  tags = {
    Name = "${var.name_prefix}-${var.common_tags.Environment}-be-prod-listener"
  }
}

resource "aws_lb_listener" "be_test" {
  load_balancer_arn = aws_lb.this.arn
  port              = 19443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_green.arn
  }

  tags = {
    Name = "${var.name_prefix}-${var.common_tags.Environment}-be-test-listener"
  }
}






