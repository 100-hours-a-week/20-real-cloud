locals {
  common_tags = {
    Project     = var.project_tag
    Environment = var.environment_tag
    Version     = var.version_tag
    Assignee    = var.assignee_tag
  }
  name_prefix = var.name_prefix
}
