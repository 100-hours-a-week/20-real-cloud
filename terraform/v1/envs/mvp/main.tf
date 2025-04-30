terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 추후 모듈 개발시, versions.tf로 해당 내용 이관

# network 관련 코드
module "network" {
  source = "../../modules/network"

  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  availability_zone         = var.availability_zone
  gcp_cidr_block            = var.gcp_cidr_block
}

module "security" {
  source = "../../modules/security"

  security_group_name        = var.security_group_name
  security_group_description = var.security_group_description
  vpc_id                     = module.network.vpc_id

  ingress_rules = var.ingress_rules
  egress_rules  = var.egress_rules
}