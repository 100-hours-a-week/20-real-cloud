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
  value = var.enable_natgw && !var.is_shared ? aws_nat_gateway.this[0].id : null
}

output "eip_id" {
  value = var.enable_natgw && !var.is_shared ? aws_eip.nat[0].id : null
}

# output "public_route_table_ids" {
#   value = {
#     dev  = aws_route_table.public_dev.id
#     prod = aws_route_table.public_prod.id
#   }
# }

# output "private_route_table_ids" {
#   value = {
#     dev  = aws_route_table.private_dev.id
#     prod = aws_route_table.private_prod.id
#   }
# }
