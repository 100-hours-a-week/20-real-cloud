resource "aws_vpc" "this" {
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

resource "aws_eip" "nat" {
  count = var.enable_natgw && !var.is_shared ? 1 : 0
  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-nat-eip"
    }
  )
}

resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidr_blocks)
  vpc_id            = aws_vpc.this.id
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
  count             = var.is_shared ? 0 : length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-private-subnet-${var.private_subnet_names[count.index]}-${var.az_name_map[var.availability_zones[count.index % length(var.availability_zones)]]}"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-internet-gateway"
    }
  )
}

resource "aws_nat_gateway" "this" {
  count         = var.enable_natgw && !var.is_shared ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-nat-gateway"
    }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-public-route-table"
    }
  )
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = {
    for idx, subnet in aws_subnet.public :
    idx => {
      subnet_id   = subnet.id
    }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.is_shared ? 0 : 1
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-private-route-table"
    }
  )
}

resource "aws_route" "private_nat_route" {
  count                  = var.enable_natgw && !var.is_shared ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[0].id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for idx, subnet in aws_subnet.private :
    idx => {
      subnet_id   = subnet.id
    }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.private[0].id
}