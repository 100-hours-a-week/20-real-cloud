resource "aws_instance" "ec2" {
  for_each = var.ec2_instances

  ami                         = each.value.ami
  instance_type               = each.value.instance_type
  subnet_id                   = each.value.subnet_id
  key_name                    = each.value.key_name
  vpc_security_group_ids      = each.value.security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  iam_instance_profile        = each.value.iam_instance_profile
  user_data                   = each.value.user_data


  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-instance-${each.key}"
    }
  )
}

resource "aws_eip" "ec2_eip" {
  for_each = {
    for key, value in var.ec2_instances : key => value
    if value.use_eip
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-eip-${each.key}"
    }
  )
}

# EIP 연결
resource "aws_eip_association" "ec2_eip" {
  for_each = aws_eip.ec2_eip

  instance_id   = aws_instance.ec2[each.key].id
  allocation_id = each.value.id

}

#Lanch template
resource "aws_launch_template" "this" {
  for_each = var.lanch_templates

  image_id               = each.value.ami
  instance_type          = each.value.instance_type
  key_name               = each.value.key_name
  user_data              = each.value.user_data
  vpc_security_group_ids = each.value.security_group_ids

  iam_instance_profile {
    name = each.value.iam_instance_profile
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.default_tags, {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-lt-${each.key}"
    })
  }
}

# automatic scaling group ASG
resource "aws_autoscaling_group" "fe_blue" {
  for_each = var.lanch_templates

  name                      = "${var.name_prefix}-${each.key}-asg"
  vpc_zone_identifier       = [each.value.subnet_id]
  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_type         = "EC2"
  health_check_grace_period = 30

  launch_template {
    id      = aws_launch_template.this[each.key].id
    version = "$Latest"
  }

  target_group_arns = [each.value.alb_target_group_arn]

  lifecycle {
    create_before_destroy = true
  }

  dynamic "tag" {
    for_each = merge(
      local.default_tags,
      {
        Name = "${var.name_prefix}-${var.common_tags.Environment}-instance-${each.key}"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
