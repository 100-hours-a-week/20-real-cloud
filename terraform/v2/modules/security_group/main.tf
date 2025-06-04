resource "aws_security_group" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-securuty-group"
    }
  )
}

resource "aws_security_group" "application" {
  name   = "${var.name_prefix}-app-sg"
  vpc_id = var.vpc_id

  tags = merge(local.default_tags, {
    Name = "${var.name_prefix}-application-sg"
  })
}

resource "aws_security_group" "monitoring" {
  name   = "${var.name_prefix}-monitoring-sg"
  vpc_id = var.vpc_id

  tags = merge(local.default_tags, {
    Name = "${var.name_prefix}-monitoring-sg"
  })
}

resource "aws_security_group" "database" {
  name   = "${var.name_prefix}-db-sg"
  vpc_id = var.vpc_id

  tags = merge(local.default_tags, {
    Name = "${var.name_prefix}-database-sg"
  })
}

resource "aws_security_group_rule" "app_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "app_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "app_ingress_server" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "app_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.application.id
}



resource "aws_security_group_rule" "db_ingress_mysql" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.database.id
}

resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.database.id
}

resource "aws_security_group_rule" "db_ingress_redis" {
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = aws_security_group.database.id
}

# 인바운드 포트 규칙
resource "aws_security_group_rule" "monitoring_ingress" {
  for_each = {
    "otel-grpc"     = 4317
    "otel-http"     = 4318
    "ssh"           = 22
    "grafana"       = 8080
    "node-exporter" = 3301
  }

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = each.key
  security_group_id = aws_security_group.monitoring.id
}

resource "aws_security_group_rule" "monitoring_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring.id
}

# Ingress Rules
resource "aws_security_group_rule" "ingress" {
  count             = length(var.ingress_rules)
  type              = "ingress"
  from_port         = var.ingress_rules[count.index].from_port
  to_port           = var.ingress_rules[count.index].to_port
  protocol          = var.ingress_rules[count.index].protocol
  cidr_blocks       = var.ingress_rules[count.index].cidr_blocks
  description       = var.ingress_rules[count.index].description
  security_group_id = aws_security_group.this.id
}

# Egress Rules
resource "aws_security_group_rule" "egress" {
  count             = length(var.egress_rules)
  type              = "egress"
  from_port         = var.egress_rules[count.index].from_port
  to_port           = var.egress_rules[count.index].to_port
  protocol          = var.egress_rules[count.index].protocol
  cidr_blocks       = var.egress_rules[count.index].cidr_blocks
  description       = var.egress_rules[count.index].description
  security_group_id = aws_security_group.this.id
}