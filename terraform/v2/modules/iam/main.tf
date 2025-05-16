resource "aws_iam_role" "cloudwatch_agent_role" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-cloudwatch-agent-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-cloudwatch-agent-role" }
  )
}

resource "aws_iam_policy" "cloudwatch_agent_policy" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-cloudwatch-agent-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-cloudwatch-agent-policy" }
  )
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_attachment" {
  role       = aws_iam_role.cloudwatch_agent_role.name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy.arn
}

resource "aws_iam_instance_profile" "cloudwatch_agent_profile" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-cloudwatch-agent-profile"
  role = aws_iam_role.cloudwatch_agent_role.name
}

# S3 bucket + SSM IAM role
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


# SSM IAM role
resource "aws_iam_role" "ssm_role" {
  name               = "${var.name_prefix}-${var.common_tags.Environment}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-ssm-role" }
  )
}


data "aws_iam_policy_document" "ssm_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["*"] # 또는 필요 시 제한된 파라미터 ARN
    effect    = "Allow"
  }
}

# SSM 정책 연결
resource "aws_iam_policy" "ssm_policy" {
  name   = "${var.name_prefix}-${var.common_tags.Environment}-ssm-policy"
  policy = data.aws_iam_policy_document.ssm_policy.json
}

resource "aws_iam_role_policy_attachment" "ssm_role_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn 
}

resource "aws_iam_role_policy_attachment" "attach_ssm_to_s3_role" {
  role       = aws_iam_role.s3_role.name
  policy_arn = aws_iam_policy.ssm_policy.arn
}

# SSM 인스턴스 프로파일
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-ssm-profile"
  role = aws_iam_role.ssm_role.name

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-ssm-profile" }
  )
}


