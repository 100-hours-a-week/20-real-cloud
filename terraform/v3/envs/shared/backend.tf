terraform {
  backend "s3" {
    bucket         = "ktb-20-terraform-backend-v3"
    key            = "envs/shared/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "ktb-20-dynamo-lock-v3"
    encrypt        = true
  }
}
