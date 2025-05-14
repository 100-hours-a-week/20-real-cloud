resource "aws_ecr_repository" "this" {
  name = "${var.name_prefix}-${var.common_tags.Environment}-ecr"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.name_prefix}-${var.common_tags.Environment}-ecr"
    }
  )
} 