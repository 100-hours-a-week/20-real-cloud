output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}

output "eip_id" {
  value = aws_eip.nat.id
}

output "public_route_table_ids" {
  value = {
    dev  = aws_route_table.public_dev.id
    prod = aws_route_table.public_prod.id
  }
}

output "private_route_table_ids" {
  value = {
    dev  = aws_route_table.private_dev.id
    prod = aws_route_table.private_prod.id
  }
}
