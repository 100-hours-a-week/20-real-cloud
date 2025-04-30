output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "Public subnet ID in VPC"
  value       = aws_subnet.this.id
}

output "internet_gateway_id" {
  description = "Internet Gateway ID belonging to VPC"
  value       = aws_internet_gateway.this.id
}