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
