resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.instance_security_group_ids
  associate_public_ip_address = var.instance_associate_public_ip_address
  iam_instance_profile        = var.iam_instance_profile


  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-instance"
    }
  )
}
