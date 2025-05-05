output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet ID in VPC"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID belonging to VPC"
  value       = aws_internet_gateway.this.id
}