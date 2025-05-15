terraform {
  backend "s3" {
    bucket         = "ktb-20-terraform-backend-v2"
    key            = "envs/infra/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "ktb-20-dynamo-lock-v2"
    encrypt        = true
  }
} 
