#!/bin/bash
#
# Download Grafana plugins for offline installation
# Usage: ./download-plugins.sh [output_dir]
#
# Plugins are downloaded as ZIP files that can be:
# 1. Mounted into the Grafana pod
# 2. Copied to NFS/PVC manually
# 3. Used with an init container
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${1:-${SCRIPT_DIR}/../plugins}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Grafana base URL
GRAFANA_BASE="https://grafana.com"
GRAFANA_API="${GRAFANA_BASE}/api/plugins"

# Plugins to download
PLUGINS=(
    "digrich-bubblechart-panel"
    "grafana-clock-panel"
    "btplc-status-dot-panel"
    "grafana-polystat-panel"
    "grafana-piechart-panel"
    "marcusolsson-json-datasource"
    "yesoreyeram-infinity-datasource"
    "grafana-clickhouse-datasource"
    "grafana-opensearch-datasource"
    "redis-datasource"
)

download_plugin() {
    local plugin_name="$1"
    
    echo -e "${YELLOW}Downloading ${plugin_name}...${NC}"
    
    # Get plugin info
    local info
    info=$(curl -sS "${GRAFANA_API}/${plugin_name}" 2>/dev/null)
    if [[ -z "$info" ]]; then
        echo -e "${RED}  ✗ Failed to get plugin info${NC}"
        return 1
    fi
    
    # Parse using Python for reliable JSON handling
    local version download_path
    read -r version download_path <<< $(echo "$info" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    version = data.get('version', 'unknown')
    download_url = data.get('packages', {}).get('any', {}).get('downloadUrl', '')
    print(f'{version} {download_url}')
except:
    print('error error')
" 2>/dev/null)
    
    if [[ "$version" == "error" || -z "$download_path" ]]; then
        echo -e "${RED}  ✗ Failed to parse plugin info${NC}"
        return 1
    fi
    
    # Build full download URL
    local download_url="${GRAFANA_BASE}${download_path}"
    local filename="${plugin_name}-${version}.zip"
    local output_path="${OUTPUT_DIR}/${filename}"
    
    echo "  Version: ${version}"
    echo "  URL: ${download_url}"
    
    if curl -sS -L -o "${output_path}" "${download_url}"; then
        local size
        size=$(du -h "${output_path}" 2>/dev/null | cut -f1)
        
        # Verify it's a valid ZIP
        if file "${output_path}" | grep -q "Zip archive"; then
            echo -e "${GREEN}  ✓ Downloaded: ${filename} (${size})${NC}"
            # Create a latest symlink
            ln -sf "${filename}" "${OUTPUT_DIR}/${plugin_name}.zip" 2>/dev/null
            return 0
        else
            echo -e "${RED}  ✗ Invalid ZIP file${NC}"
            rm -f "${output_path}"
            return 1
        fi
    else
        echo -e "${RED}  ✗ Failed to download${NC}"
        return 1
    fi
}

main() {
    echo "========================================"
    echo "Grafana Plugin Downloader (Offline)"
    echo "========================================"
    echo ""
    echo "Output directory: ${OUTPUT_DIR}"
    echo ""
    
    mkdir -p "${OUTPUT_DIR}"
    
    local success=0
    local failed=0
    
    for plugin in "${PLUGINS[@]}"; do
        if download_plugin "$plugin"; then
            ((success++))
        else
            ((failed++))
        fi
        echo ""
        sleep 0.5
    done
    
    echo "========================================"
    echo "Summary"
    echo "========================================"
    echo -e "${GREEN}Downloaded: ${success}${NC}"
    [[ $failed -gt 0 ]] && echo -e "${RED}Failed: ${failed}${NC}"
    echo ""
    
    if ls "${OUTPUT_DIR}"/*.zip &>/dev/null; then
        echo "Downloaded files:"
        ls -lh "${OUTPUT_DIR}"/*.zip 2>/dev/null | grep -v '\->' | awk '{print "  " $9 " (" $5 ")"}'
        echo ""
        
        # Calculate total size
        local total_size
        total_size=$(du -sh "${OUTPUT_DIR}" 2>/dev/null | cut -f1)
        echo "Total size: ${total_size}"
    fi
    
    echo ""
    echo "========================================"
    echo "Installation Methods"
    echo "========================================"
    echo ""
    echo "Option 1: Copy to running pod"
    echo "  for zip in plugins/*.zip; do"
    echo '    kubectl cp "$zip" monitoring/monitoring-grafana-0:/var/lib/grafana/plugins/'
    echo "  done"
    echo '  kubectl exec monitoring-grafana-0 -n monitoring -- sh -c "cd /var/lib/grafana/plugins && for z in *.zip; do unzip -o \$z && rm \$z; done"'
    echo ""
    echo "Option 2: Pre-install on NFS (if accessible)"
    echo "  # Mount NFS and extract plugins directly"
    echo "  unzip -o 'plugins/*.zip' -d /path/to/nfs/grafana-data/plugins/"
}

main "$@"
