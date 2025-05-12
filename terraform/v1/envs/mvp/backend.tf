terraform {
  backend "s3" {
    bucket         = "ktb-20-terraform-backend-v1"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "ktb-20-dynamo-lock-v1"
  }
}
