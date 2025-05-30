# cloudwatch agent role
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

# S3 bucket + SSM + codedeploy IAM role
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

resource "aws_iam_role" "ec2_role" {
  name               = "${var.name_prefix}-${var.common_tags.Environment}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-ec2-role" }
  )
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = merge(
    local.default_tags,
    { Name = "${var.name_prefix}-${var.common_tags.Environment}-ec2-profile" }
  )
}

resource "aws_iam_role_policy_attachment" "attach_ecr_readonly_to_ec2_role" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach_codedeploy_deployer_to_ec2_role" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployDeployerAccess"
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

resource "aws_iam_role_policy_attachment" "attach_ssm_to_ec2_role" {
  role       = aws_iam_role.ec2_role.name
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

# Codedeploy IAM role
data "aws_iam_policy_document" "code_deploy_policy" {
  statement {
    sid    = "VisualEditor0"
    effect = "Allow"

    actions = [
      "iam:PassRole",
      "ec2:CreateTags",
      "ec2:RunInstances",
    ]
  }
}

resource "aws_iam_policy" "code_deploy_policy" {
  name   = "${var.name_prefix}-${var.common_tags.Environment}-code-deploy-policy"
  policy = data.aws_iam_policy_document.code_deploy_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_code_deploy_to_ec2_role" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.code_deploy_policy.arn
}

resource "aws_iam_role" "codedeploy_role" {
  name               = "${var.name_prefix}-${var.common_tags.Environment}-codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.code_deploy_policy.json
}


#Auto Scaling, EC2, ELB, CloudWatch, SNS, Tag role for codedeploy
data "aws_iam_policy_document" "code_deploy_advanced_policy" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DeleteLifecycleHook",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLifecycleHooks",
      "autoscaling:PutLifecycleHook",
      "autoscaling:RecordLifecycleActionHeartbeat",
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:CreateOrUpdateTags",
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:EnableMetricsCollection",
      "autoscaling:DescribePolicies",
      "autoscaling:DescribeScheduledActions",
      "autoscaling:DescribeNotificationConfigurations",
      "autoscaling:SuspendProcesses",
      "autoscaling:ResumeProcesses",
      "autoscaling:AttachLoadBalancers",
      "autoscaling:AttachLoadBalancerTargetGroups",
      "autoscaling:PutScalingPolicy",
      "autoscaling:PutScheduledUpdateGroupAction",
      "autoscaling:PutNotificationConfiguration",
      "autoscaling:PutWarmPool",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:DeleteAutoScalingGroup",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:SetInstanceHealth",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "ec2:TerminateInstances",
      "tag:GetResources",
      "sns:Publish",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DescribeTargetGroupAttributes",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeInstanceHealth",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "code_deploy_advanced_policy" {
  name   = "${var.name_prefix}-${var.common_tags.Environment}-code-deploy-advanced-policy"
  policy = data.aws_iam_policy_document.code_deploy_advanced_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_code_deploy_advanced_to_cd_role" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.code_deploy_advanced_policy.arn
}