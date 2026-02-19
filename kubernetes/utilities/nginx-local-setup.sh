#!/usr/bin/env bash
set -e

echo "🚀 Bootstrapping full OTEL + Grafana + Geo observability stack..."

mkdir -p grafana/dashboards grafana/provisioning otel

#################################
# NGINX CONFIG
#################################

cat > nginx.conf <<'EOF'
worker_processes auto;

events { worker_connections 65535; }

http {
  geoip2 /usr/share/GeoIP/GeoLite2-City.mmdb {
    $geoip_country_code country iso_code;
    $geoip_city city names en;
    $geoip_lat location latitude;
    $geoip_lon location longitude;
  }

  log_format json escape=json
  '{'
    '"ts":"$time_iso8601",'
    '"status":$status,'
    '"rt":$request_time,'
    '"method":"$request_method",'
    '"path":"$uri",'
    '"country":"$geoip_country_code",'
    '"city":"$geoip_city",'
    '"lat":$geoip_lat,'
    '"lon":$geoip_lon'
  '}';

  access_log /var/log/nginx/access.log json;

  upstream backend { server backend:8080; }

  server {
    listen 80;
    location / { proxy_pass http://backend; }
  }
}
EOF

#################################
# OTEL COLLECTOR
#################################

cat > otel/otel.yaml <<'EOF'
receivers:
  filelog:
    include: [/var/log/nginx/*.log]
    operators:
      - type: json_parser

processors:
  batch:

exporters:
  prometheus:
    endpoint: "0.0.0.0:9464"

  loki:
    endpoint: http://loki:3100/loki/api/v1/push

service:
  pipelines:
    logs:
      receivers: [filelog]
      processors: [batch]
      exporters: [loki]

    metrics:
      receivers: []
      processors: [batch]
      exporters: [prometheus]
EOF

#################################
# GRAFANA DASHBOARD
#################################

cat > grafana/dashboards/nginx-geo.json <<'EOF'
{
  "title": "NGINX Geo Traffic",
  "panels": [
    {
      "type": "geomap",
      "title": "Requests by Location",
      "targets": [
        { "expr": "count_over_time({job=\"nginx\"}[1m])" }
      ]
    },
    {
      "type": "timeseries",
      "title": "Request Latency",
      "targets": [
        { "expr": "avg_over_time(nginx_request_time[1m])" }
      ]
    }
  ]
}
EOF

#################################
# DOCKER COMPOSE
#################################

cat > docker-compose.yml <<'EOF'
version: "3.9"

volumes:
  geodb:

services:

  geodb:
    image: ghcr.io/maxmind/geoipupdate
    environment:
      GEOIPUPDATE_EDITION_IDS: GeoLite2-City
      GEOIPUPDATE_ACCOUNT_ID: "000000"
      GEOIPUPDATE_LICENSE_KEY: "dummy"
    volumes:
      - geodb:/usr/share/GeoIP

  backend:
    image: hashicorp/http-echo
    command: ["-listen=:8080","-text=OK"]

  nginx:
    image: docker.io/hellodk/avika-agent:latest
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - geodb:/usr/share/GeoIP:ro
      - ./logs:/var/log/nginx
    depends_on: [backend, geodb]
    deploy:
      replicas: 4

  otel:
    image: otel/opentelemetry-collector-contrib
    volumes:
      - ./otel/otel.yaml:/etc/otel.yaml
      - ./logs:/var/log/nginx
    command: ["--config=/etc/otel.yaml"]

  loki:
    image: grafana/loki:2.9.0
    command: -config.file=/etc/loki/local-config.yaml

  prometheus:
    image: prom/prometheus

  grafana:
    image: grafana/grafana
    ports:
      - "4000:3000"
    volumes:
      - ./grafana:/etc/grafana
EOF

#################################
# START
#################################

mkdir -p logs
docker compose up -d

echo "✅ Stack live"
echo "📊 Grafana: http://localhost:4000  (admin/admin)"
