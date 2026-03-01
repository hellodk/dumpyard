#!/bin/bash

# Directory containing the JSON dashboards
DASHBOARD_DIR="dashboards-custom"
# Output directory for the generated ConfigMaps
OUTPUT_DIR="dashboards-manifests"
# Namespace where ConfigMaps will be applied (should match where Grafana is running/watching)
NAMESPACE="monitoring"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Converting dashboards from $DASHBOARD_DIR to ConfigMaps in $OUTPUT_DIR..."

for file in "$DASHBOARD_DIR"/*.json; do
    [ -e "$file" ] || continue
    
    filename=$(basename "$file")
    name="${filename%.*}"
    # Kubernetes resource names must be lowercase, alphanumeric, -, or .
    # We replace spaces and underscores with dashes, and ensure lowercase
    safe_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9.-]/-/g')
    
    # Truncate if too long (max 253 chars for DNS subdomain, but let's be safe)
    safe_name="${safe_name:0:63}"
    
    output_file="$OUTPUT_DIR/${safe_name}-configmap.yaml"
    
    # Generate ConfigMap YAML
    cat <<EOF > "$output_file"
apiVersion: v1
kind: ConfigMap
metadata:
  name: dashboard-${safe_name}
  namespace: ${NAMESPACE}
  labels:
    grafana_dashboard: "1"
    app.kubernetes.io/part-of: kube-prometheus-stack
  annotations:
    k8s-sidecar-target-directory: "/tmp/dashboards/custom"
data:
  ${filename}: |-
EOF
    
    # Append JSON content, indented by 4 spaces
    sed 's/^/    /' "$file" >> "$output_file"
    
    echo "Generated $output_file"
done

echo "Conversion complete. Apply with: kubectl apply -f $OUTPUT_DIR"
