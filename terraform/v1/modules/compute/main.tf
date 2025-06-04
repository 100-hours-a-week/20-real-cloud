resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.instance_security_group_ids
  associate_public_ip_address = var.instance_associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile


  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-instance"
    }
  )
}

resource "aws_eip" "ec2_eip" {

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-eip"
    }
  )
}

# EIP 연결
resource "aws_eip_association" "ec2_eip" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.ec2_eip.id
}

# resource "aws_lb_target_group_attachment" "ec2" {
#   target_group_arn = var.alb_target_group_arn
#   target_id        = aws_instance.ec2.id
#   port             = var.instance_port
# }