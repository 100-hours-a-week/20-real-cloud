#!/bin/bash
set -e

export TF_VAR_assignee_tag=denver

echo "🔁 Terraform Destroy 시작 (EC2 및 S3는 제외)"

# 안전하게 삭제할 모듈들만 지정
terraform destroy -target=module.cdn -auto-approve
terraform destroy -target=module.iam -auto-approve 
terraform destroy -target=module.ec2_sg -auto-approve
terraform destroy -target=module.network -auto-approve

echo "✅ 완료: EC2(instance), S3(bucket)는 유지됨"
