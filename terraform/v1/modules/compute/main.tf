resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = var.instance_associate_public_ip_address

  tags = {
    Name        = "ktb-20-terraform-instance-v1"
    Project     = "choon-assistant"
    Environment = "mvp"     # v1은 mvp, 이후 버전은 dev, prod 등으로 구분
    Module      = "compute" # 모듈명 (network, compute, database, security, monitoring 등)
    Version     = "v1"      # Terraform 코드 버전
    Assignee    = "nilla"   # nilla, river, denver
  }
}
