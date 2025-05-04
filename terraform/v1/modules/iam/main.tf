
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

