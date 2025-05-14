module "ecr" {
  source = "../../modules/registry"

  common_tags = local.common_tags
  name_prefix = local.name_prefix
}