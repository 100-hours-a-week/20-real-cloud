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
      Name = "${var.name_prefix}-${var.common_tags.Environment}-private-subnet-${var.az_name_map[var.availability_zones[count.index % length(var.availability_zones)]]}"
    }
  )
}

resource "aws_route_table" "public" {
  count  = var.is_infra_env ? 0 : length(var.public_subnet_cidr_blocks)
  vpc_id = local.selected_vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = local.selected_internet_gateway_id
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-public-route-table-${var.az_name_map[var.availability_zones[count.index]]}"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = var.is_infra_env ? 0 : length(var.public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
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

resource "aws_nat_gateway" "this" {
  count = (var.is_infra_env == false && var.create_nat_gateway == true) ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-nat-gateway"
    }
  )
}