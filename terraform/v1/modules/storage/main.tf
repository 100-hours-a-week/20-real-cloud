# static bucket for image serving
resource "aws_s3_bucket" "static" {
  bucket = "${var.name_prefix}-${var.common_tags.Environment}-static"

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-static"
    }
  )

}

resource "aws_s3_bucket_policy" "s3_static_policy" {
  bucket = aws_s3_bucket.static.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowGetFromCloudFront",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = ["s3:GetObject"],
        Resource = ["${aws_s3_bucket.static.arn}/*"],
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = var.cloudfront_distribution_arn
          }
        }
      },
      {
        Sid    = "AllowListBucketToIAMRole",
        Effect = "Allow",
        Principal = {
          AWS = var.s3_iam_role_arn
        },
        Action   = ["s3:ListBucket"],
        Resource = ["${aws_s3_bucket.static.arn}"]
      },
      {
        Sid    = "AllowFullObjectAccessToIAMRole",
        Effect = "Allow",
        Principal = {
          AWS = var.s3_iam_role_arn
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = ["${aws_s3_bucket.static.arn}/*"]
      }
    ]
  })
}



# s3 bucket for save logs

resource "aws_s3_bucket" "log" {
  bucket = "${var.name_prefix}-${var.common_tags.Environment}-log"

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-log"
    }
  )
}

resource "aws_s3_bucket_versioning" "log_versioning" {
  bucket = aws_s3_bucket.log.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "log_logs" {
  bucket = aws_s3_bucket.log.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    filter { prefix = "" }
    expiration {
      days = var.s3_log_retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "s3_log_policy" {
  bucket = aws_s3_bucket.log.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowLogWriteOnly"
        Effect    = "Allow"
        Principal = { AWS = var.s3_iam_role_arn }
        Action    = ["s3:PutObject"]
        Resource  = "${aws_s3_bucket.log.arn}/*"
      }
    ]
  })
}
