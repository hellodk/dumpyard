#!/bin/bash
#
# Download Grafana dashboards from Grafana.com
# Usage: ./download-dashboards.sh [output_dir]
#
# This script downloads dashboard JSON files for use with kube-prometheus-stack.
# Dashboards are stored individually to avoid ConfigMap size limits (1MiB).
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${1:-${SCRIPT_DIR}/../dashboards-custom}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Grafana.com API endpoint
GRAFANA_API="https://grafana.com/api/dashboards"

download_dashboard() {
    local gnet_id="$1"
    local revision="$2"
    local filename="$3"
    local output_path="${OUTPUT_DIR}/${filename}"
    
    echo -e "${YELLOW}Downloading dashboard ${gnet_id} (revision ${revision})...${NC}"
    
    # Download from Grafana.com API
    local url="${GRAFANA_API}/${gnet_id}/revisions/${revision}/download"
    
    if curl -sS -f -o "${output_path}" "${url}"; then
        # Get file size
        local size
        size=$(wc -c < "${output_path}" 2>/dev/null | tr -d ' ')
        
        # Check if size exceeds ConfigMap limit warning threshold (800KB)
        if [[ -n "${size}" ]] && [[ ${size} -gt 819200 ]]; then
            echo -e "${YELLOW}  Warning: ${filename} is ${size} bytes (>800KB) - approaching ConfigMap limit${NC}"
        fi
        
        echo -e "${GREEN}  ✓ Saved: ${filename} (${size} bytes)${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Failed to download dashboard ${gnet_id}${NC}"
        return 1
    fi
}

# Post-process dashboard JSON to fix datasource references
postprocess_dashboard() {
    local filepath="$1"
    
    if command -v python3 &>/dev/null; then
        python3 - "${filepath}" <<'PYTHON'
import json
import sys

filepath = sys.argv[1]

try:
    with open(filepath, 'r') as f:
        dashboard = json.load(f)
    
    def fix_datasource(obj):
        if isinstance(obj, dict):
            for key, value in obj.items():
                if key == 'datasource':
                    if isinstance(value, str) and '${DS_' in value:
                        obj[key] = 'Prometheus'
                    elif isinstance(value, dict) and 'uid' in value:
                        if '${DS_' in str(value.get('uid', '')):
                            value['uid'] = 'prometheus'
                            value['type'] = 'prometheus'
                else:
                    fix_datasource(value)
        elif isinstance(obj, list):
            for item in obj:
                fix_datasource(item)
        return obj
    
    dashboard = fix_datasource(dashboard)
    dashboard.pop('id', None)
    
    with open(filepath, 'w') as f:
        json.dump(dashboard, f, indent=2)
    
    print(f"  ✓ Post-processed: {filepath}")
except Exception as e:
    print(f"  Warning: Could not post-process {filepath}: {e}", file=sys.stderr)
PYTHON
    fi
}

main() {
    echo "========================================"
    echo "Grafana Dashboard Downloader"
    echo "========================================"
    echo ""
    echo "Output directory: ${OUTPUT_DIR}"
    echo ""
    
    mkdir -p "${OUTPUT_DIR}"
    
    local success_count=0
    local fail_count=0
    
    # Dashboard definitions: gnetId revision filename
    declare -a DASHBOARDS=(
        "19268 1 19268-prometheus-server.json"
        "11802 1 11802-kubernetes-cluster-overview.json"
        "1860 37 1860-node-exporter-full.json"
        "7249 1 7249-kubernetes-cluster-summary.json"
        "6417 1 6417-kubernetes-pods.json"
        "14282 1 14282-cadvisor.json"
        "10557 1 10557-kubernetes-capacity.json"
        "13332 1 13332-kube-state-metrics.json"
        "19105 1 19105-kubernetes-addons-prometheus.json"
        "16337 1 16337-trivy-operator.json"
        "15761 1 15761-kubernetes-system-api-server.json"
        "15762 1 15762-kubernetes-system-coredns.json"
        "15757 1 15757-kubernetes-views-global.json"
        "15758 1 15758-kubernetes-views-namespaces.json"
        "15759 1 15759-kubernetes-views-nodes.json"
        "15760 1 15760-kubernetes-views-pods.json"
        "13125 1 13125-kubernetes-capacity-planning-limits.json"
    )
    
    for entry in "${DASHBOARDS[@]}"; do
        read -r gnet_id revision filename <<< "${entry}"
        
        if download_dashboard "${gnet_id}" "${revision}" "${filename}"; then
            postprocess_dashboard "${OUTPUT_DIR}/${filename}"
            ((success_count++)) || true
        else
            ((fail_count++)) || true
        fi
        
        sleep 0.3
    done
    
    echo ""
    echo "========================================"
    echo "Summary"
    echo "========================================"
    echo -e "${GREEN}Successfully downloaded: ${success_count}${NC}"
    if [[ ${fail_count} -gt 0 ]]; then
        echo -e "${RED}Failed: ${fail_count}${NC}"
    fi
    echo ""
    
    echo "Downloaded files:"
    ls -lh "${OUTPUT_DIR}"/*.json 2>/dev/null | awk '{print $5, $9}' || echo "No files found"
    
    echo ""
    local total_size
    total_size=$(du -sh "${OUTPUT_DIR}" 2>/dev/null | cut -f1)
    echo "Total size: ${total_size}"
}

main "$@"
