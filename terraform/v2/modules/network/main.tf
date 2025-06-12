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
  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-nat-eip"
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
      Name = "${var.name_prefix}-${var.public_subnet_environments[count.index]}-public-subnet-${var.az_name_map[var.availability_zones[count.index]]}"
    }
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.private_subnet_environments[count.index]}-private-subnet-${var.private_subnet_names[count.index]}-${var.az_name_map[var.availability_zones[count.index % length(var.availability_zones)]]}"
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
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-nat-gateway"
    }
  )
}

resource "aws_route_table" "public_prod" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-prod-public-route-table"
    }
  )
}

resource "aws_route_table" "public_dev" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-dev-public-route-table"
    }
  )
}

resource "aws_route" "public_internet_route_prod" {
  route_table_id         = aws_route_table.public_prod.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route" "public_internet_route_dev" {
  route_table_id         = aws_route_table.public_dev.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = {
    for idx, subnet in aws_subnet.public :
    idx => {
      subnet_id   = subnet.id
      environment = var.public_subnet_environments[idx]
    }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.environment == "prod" ? aws_route_table.public_prod.id : aws_route_table.public_dev.id
}

resource "aws_route_table" "private_prod" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-prod-private-route-table"
    }
  )
}

resource "aws_route_table" "private_dev" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-dev-private-route-table"
    }
  )
}

resource "aws_route" "private_nat_route_prod" {
  route_table_id         = aws_route_table.private_prod.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route" "private_nat_route_dev" {
  route_table_id         = aws_route_table.private_dev.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "private" {
  for_each = {
    for idx, subnet in aws_subnet.private :
    idx => {
      subnet_id   = subnet.id
      environment = var.private_subnet_environments[idx]
    }
  }
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.environment == "prod" ? aws_route_table.private_prod.id : aws_route_table.private_dev.id
}