locals {
  default_tags = merge(
    var.common_tags,
    {
      Module = var.module_name
    }
  )
}

locals {
  selected_vpc_id              = var.is_infra_env ? aws_vpc.this[0].id : var.vpc_id
  selected_internet_gateway_id = var.is_infra_env ? aws_internet_gateway.this[0].id : var.internet_gateway_id
  selected_nat_gateway_id      = var.create_nat_gateway ? aws_nat_gateway.this[0].id : var.nat_gateway_id
}