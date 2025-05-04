locals {
  default_tags = merge(
    var.common_tags,
    {
      Module = var.module_name
    }
  )
}
