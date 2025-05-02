resource "aws_security_group" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-securuty-group"
    }
  )
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


# S3 bucket IAM role
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "s3_reader_writer_role" {
  name               = "${var.name_prefix}-${var.common_tags.Environment}-s3-reader-writer-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-s3-reader-writer-role" }
  )
}

resource "aws_iam_instance_profile" "s3_reader_writer_profile" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-s3-reader-writer-profile"
  role = aws_iam_role.s3_reader_writer_role.name

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-s3-reader-writer-profile" }
  )
}

