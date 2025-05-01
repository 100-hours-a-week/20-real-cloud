# VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr_block

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-vpc"
    }
  )
}

# Public Subnet
resource "aws_subnet" "this" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = var.availability_zone

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-public-subnet"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-internet-gateway"
    }
  )
}

# Route Table
resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-route-table"
    }
  )
}

# Subnet에 Route Table 연결
resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}