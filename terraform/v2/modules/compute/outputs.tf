output "db_ec2_private_dns" {
  value = aws_instance.ec2["database"].private_dns
}