#!/bin/bash
set -e

# 1. 필수 패키지 설치
yum update -y
yum install -y docker curl git unzip

# 2. Docker 설치 및 실행
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# 3. Docker Compose 설치 (v2)
curl -L "https://github.com/docker/compose/releases/download/v2.24.4/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# 4. Signoz 설치
cd /home/ec2-user
git clone -b main https://github.com/SigNoz/signoz.git
cd signoz/deploy/docker

cp config/prometheus/prometheus.yml.sample config/prometheus/prometheus.yml
cp .env.example .env

# 기본 포트 사용:
# - Frontend: 3301
# - Collector: 4317 (gRPC), 4318 (HTTP)
# - Prometheus Receiver: scrape 설정 가능

# 5. Docker Compose 실행
docker-compose up -d

# 6. 완료 메시지
echo "✅ SigNoz Monitoring Server 설치 완료. 포트 3301에서 웹 UI 접근 가능."
