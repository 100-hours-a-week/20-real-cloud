#!/bin/bash
set -e

# 1. Update & basic packages
yum update -y
yum install -y ruby wget unzip docker

# 2. Start Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user

# 3. Install CodeDeploy Agent
cd /home/ec2-user
wget https://bucket-name.s3.region-identifier.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto
systemctl start codedeploy-agent
systemctl enable codedeploy-agent
systemctl status codedeploy-agent


# 4. Install CloudWatch Agent
yum install -y amazon-cloudwatch-agent
# 이후 설정값 작성

# Done!
echo "✅ Setup complete: Docker + CodeDeploy Agent + CloudWatch Agent"
