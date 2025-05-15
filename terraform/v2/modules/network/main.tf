resource "aws_vpc" "this" {
  count                = var.is_infra_env ? 1 : 0
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-vpc"
    }
  )
}

resource "aws_internet_gateway" "this" {
  count  = var.is_infra_env ? 1 : 0
  vpc_id = local.selected_vpc_id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-internet-gateway"
    }
  )
}

resource "aws_subnet" "public" {
  count             = var.is_infra_env ? 0 : length(var.public_subnet_cidr_blocks)
  vpc_id            = local.selected_vpc_id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-public-subnet-${var.az_name_map[var.availability_zones[count.index]]}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = var.is_infra_env ? 0 : length(var.private_subnet_cidr_blocks)
  vpc_id            = local.selected_vpc_id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-private-subnet-${var.private_subnet_names[count.index]}-${var.az_name_map[var.availability_zones[count.index % length(var.availability_zones)]]}"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-nat-gateway"
    }
  )
}

resource "aws_route_table" "public" {
  count  = var.is_infra_env ? 0 : 1
  vpc_id = local.selected_vpc_id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-public-route-table"
    }
  )
}

resource "aws_route" "public_internet_route" {
  count                  = (!var.is_infra_env && local.selected_internet_gateway_id != null) ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = local.selected_internet_gateway_id
}

resource "aws_route_table_association" "public" {
  count          = var.is_infra_env ? 0 : length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table" "private" {
  count  = var.is_infra_env ? 0 : 1
  vpc_id = local.selected_vpc_id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-private-route-table"
    }
  )
}

resource "aws_route" "private_nat_route" {
  count                  = var.is_infra_env ? 0 : 1
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = local.selected_nat_gateway_id
}

resource "aws_route_table_association" "private" {
  count          = var.is_infra_env ? 0 : length(var.private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_eip" "nat" {
  count = (var.is_infra_env == false && var.create_nat_gateway == true) ? 1 : 0

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-eip"
    }
  )
}