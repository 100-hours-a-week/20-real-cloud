# frontend bucket for static website hosting
resource "aws_s3_bucket_cors_configuration" "frontend_cors" {
  bucket = var.s3_frontend_bucket_name
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket = var.s3_frontend_bucket_name

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-frontend"
    }
  )

}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}


# s3 bucket for save images & logs

resource "aws_s3_bucket" "backend" {
  bucket = "${var.name_prefix}-${var.common_tags.Environment}-backend"

  tags = merge(
    local.default_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-backend"
    }
  )
}

resource "aws_s3_bucket_acl" "backend_acl" {
  bucket = aws_s3_bucket.backend.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.backend.id

  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_lifecycle_configuration" "backend_logs" {
  bucket = aws_s3_bucket.backend.id

  rule {
    id     = "log-expiration"
    status = "Enabled"

    filter {
      prefix = var.s3_log_prefix
    }

    expiration {
      days = var.s3_log_retention_days
    }
  }
}

resource "aws_s3_bucket_policy" "s3_reader_writer_policy" {
  bucket = aws_s3_bucket.backend.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowImageFullAccess"
        Effect    = "Allow"
        Principal = { AWS = var.s3_reader_writer_iam_role_arn }
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.backend.arn,
          "${aws_s3_bucket.backend.arn}/${var.s3_image_prefix}/*"
        ]
      },
      {
        Sid       = "AllowLogWriteOnly"
        Effect    = "Allow"
        Principal = { AWS = var.s3_reader_writer_iam_role_arn }
        Action    = ["s3:PutObject"]
        Resource  = "${aws_s3_bucket.backend.arn}/${var.s3_log_prefix}/*"
      }
    ]
  })
}
