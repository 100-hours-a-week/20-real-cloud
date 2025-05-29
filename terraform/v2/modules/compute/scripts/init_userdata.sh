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

# 5. Install SigNoz OpenTelemetry Collector Agent
SIGNOZ_ENDPOINT="http://<your-signoz-host>:4317"  # 🔁 여기를 실제 SigNoz 서버 주소로 변경

mkdir -p /opt/signoz
cd /opt/signoz

cat > otel-config.yaml <<EOF
receivers:
  otlp:
    protocols:
      grpc:
      http
  prometheus:
    config:
      scrape_configs:
        - job_name: 'spring-prod'
          metrics_path: /monitoring/prometheus
          static_configs:
            - targets: ['IP:8080']  # 🔁 Spring Boot 애플리케이션 포트

exporters:
  otlp:
    endpoint: "http://<your-signoz-host>:4317"
    tls:
      insecure: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [otlp]

    metrics:
      receivers: [prometheus]
      exporters: [otlp]

EOF

curl -L https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.97.0/otelcol_0.97.0_linux_amd64.tar.gz -o otelcol.tar.gz
tar -xzf otelcol.tar.gz
mv otelcol /usr/local/bin/otelcol

# Systemd 서비스 등록
cat > /etc/systemd/system/signoz-otel-agent.service <<EOF
[Unit]
Description=SigNoz OpenTelemetry Collector
After=network.target

[Service]
ExecStart=/usr/local/bin/otelcol --config /opt/signoz/otel-config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl enable signoz-otel-agent
systemctl start signoz-otel-agent

# Done
echo "✅ Setup complete: Docker + CodeDeploy Agent + CloudWatch Agent + SigNoz OTEL Agent"
