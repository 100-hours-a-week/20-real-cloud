#!/bin/bash
set -e

# 1. 기본 패키지 설치
yum update -y
yum install -y awscli

# 2. 홈 디렉토리에 SSH 폴더 생성
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh

# 3. Parameter Store에서 PEM 키 값 가져오기
aws ssm get-parameter \
  --name "/bastion/ssh/secret-key" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > /home/ec2-user/.ssh/secret-key.pem

# 4. 퍼미션 설정
chmod 400 /home/ec2-user/.ssh/secret-key.pem
chown ec2-user:ec2-user /home/ec2-user/.ssh/secret-key.pem

# 완료 메시지
echo "✅ PEM 키 생성 완료. 'ssh -i /home/ec2-user/.ssh/secret-key.pem ec2-user@<ip>' 명령으로 대상 인스턴스에 접속할 수 있습니다."
