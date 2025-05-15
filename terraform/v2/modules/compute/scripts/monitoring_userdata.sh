#!/bin/bash
set -e

# 1. 시스템 패키지 설치
yum update -y
yum install -y docker curl git

# 2. Docker 시작 및 ec2-user 권한 추가
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# 3. Docker Compose 설치 (v2)
curl -L "https://github.com/docker/compose/releases/download/v2.24.4/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose