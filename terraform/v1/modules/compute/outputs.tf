output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "instance_public_ip" {
  description = "Public IP address assigned to the instance"
  value       = aws_instance.ec2.public_ip
}