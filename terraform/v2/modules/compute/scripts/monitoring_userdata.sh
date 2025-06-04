#!/bin/bash
set -e

# 1. 필수 패키지 설치
yum update -y
yum install -y docker git unzip

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

# 🔧 5. OTEL Collector 설정 파일 추가
cat > otel-collector-config.yaml << 'EOF'
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
  prometheus:
    config:
      global:
        scrape_interval: 60s
      scrape_configs:
        - job_name: "spring-boot-app"
          metrics_path: "/monitoring/prometheus"
          static_configs:
            - targets: ['13.124.215.18:9292']
        - job_name: otel-collector
          static_configs:
          - targets:
              - localhost:8888
            labels:
              job_name: otel-collector
processors:
  batch:
    send_batch_size: 10000
    send_batch_max_size: 11000
    timeout: 10s
  resourcedetection:
    detectors: [env, system]
    timeout: 2s
  signozspanmetrics/delta:
    metrics_exporter: clickhousemetricswrite, signozclickhousemetrics
    metrics_flush_interval: 60s
    latency_histogram_buckets: [100us, 1ms, 2ms, 6ms, 10ms, 50ms, 100ms, 250ms, 500ms, 1000ms, 1400ms, 2000ms, 5s, 10s, 20s, 40s, 60s ]
    dimensions_cache_size: 100000
    aggregation_temporality: AGGREGATION_TEMPORALITY_DELTA
    enable_exp_histogram: true
    dimensions:
      - name: service.namespace
        default: default
      - name: deployment.environment
        default: default
      - name: signoz.collector.id
      - name: service.version
      - name: browser.platform
      - name: browser.mobile
      - name: k8s.cluster.name
      - name: k8s.node.name
      - name: k8s.namespace.name
      - name: host.name
      - name: host.type
      - name: container.name
extensions:
  health_check:
    endpoint: 0.0.0.0:13133
  pprof:
    endpoint: 0.0.0.0:1777
exporters:
  clickhousetraces:
    datasource: tcp://clickhouse:9000/signoz_traces
    low_cardinal_exception_grouping: ${env:LOW_CARDINAL_EXCEPTION_GROUPING}
    use_new_schema: true
  clickhousemetricswrite:
    endpoint: tcp://clickhouse:9000/signoz_metrics
    disable_v2: true
    resource_to_telemetry_conversion:
      enabled: true
  clickhousemetricswrite/prometheus:
    endpoint: tcp://clickhouse:9000/signoz_metrics
    disable_v2: true
  signozclickhousemetrics:
    dsn: tcp://clickhouse:9000/signoz_metrics
  clickhouselogsexporter:
    dsn: tcp://clickhouse:9000/signoz_logs
    timeout: 10s
    use_new_schema: true
  otlp:
    endpoint: signoz:4317
    tls:
      insecure: true
service:
  telemetry:
    logs:
      encoding: json
    metrics:
      address: 0.0.0.0:8888
  extensions:
    - health_check
    - pprof
  pipelines:
    traces:
      receivers: [otlp]
      processors: [signozspanmetrics/delta, batch]
      exporters: [clickhousetraces]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [clickhousemetricswrite, signozclickhousemetrics]
    metrics/prometheus:
      receivers: [prometheus]
      processors: [batch]
      exporters: [clickhousemetricswrite, signozclickhousemetrics]
    logs:
      receivers: [otlp]
      processors: [batch]
      exporters: [clickhouselogsexporter]
EOF

# 6. Docker Compose 실행
docker-compose up -d

# ✅ 완료 메시지
echo "✅ SigNoz Collector + Docker Compose 설정 완료"