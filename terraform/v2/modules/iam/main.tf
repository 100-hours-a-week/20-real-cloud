
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

resource "aws_iam_role" "s3_role" {
  name               = "${var.name_prefix}-${var.common_tags.Environment}-s3-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-s3-role" }
  )
}

resource "aws_iam_instance_profile" "s3_profile" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-s3-profile"
  role = aws_iam_role.s3_role.name

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-s3-profile" }
  )
}

