#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="dashboards-custom"
OUT_DIR="dashboards-yaml"
NAMESPACE="monitoring"
LABEL_KEY="grafana_dashboard"
LABEL_VALUE="1"

mkdir -p "$OUT_DIR"

for file in "$SRC_DIR"/*.json; do
  [ -e "$file" ] || continue

  fname=$(basename "$file")
  name="${fname%.json}"

  # sanitize for k8s name
  cm_name="grafana-dashboard-${name,,}"
  cm_name=$(echo "$cm_name" | sed 's/[^a-z0-9-]/-/g')

  out="$OUT_DIR/$cm_name.yaml"

  echo "Creating $out"

  cat > "$out" <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $cm_name
  namespace: $NAMESPACE
  labels:
    $LABEL_KEY: "$LABEL_VALUE"
data:
  $fname: |
EOF

  # indent JSON for YAML block
  sed 's/^/    /' "$file" >> "$out"

done

echo "Done. ConfigMaps written to: $OUT_DIR"
