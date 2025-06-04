#!/bin/bash
set -e

# 1. Update & basic packages
yum update -y
yum install -y ruby wget unzip docker curl git amazon-cloudwatch-agent

# 2. Start Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# 3. Install CodeDeploy Agent (서울 리전)
cd /home/ec2-user
wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
chmod +x ./install
./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent

# 4. Start CloudWatch Agent (기본 설치, 설정은 이후 적용)
systemctl start amazon-cloudwatch-agent
systemctl enable amazon-cloudwatch-agent

cd /home/ec2-user
wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v1.38.0/opentelemetry-javaagent.jar -O otel-agent.jar

# Done
echo "✅ Setup complete: Docker + CodeDeploy Agent + CloudWatch Agent + SigNoz OTEL Agent"
