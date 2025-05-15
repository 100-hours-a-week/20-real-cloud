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
