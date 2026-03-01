# Custom Grafana Dashboards

This directory contains Grafana dashboard JSON files that are provisioned as ConfigMaps
by the kube-prometheus-stack Helm chart.

## Why ConfigMaps Instead of gnetId?

The original approach using `grafana.dashboards.<name>.gnetId` has drawbacks:

| Approach | Pros | Cons |
|----------|------|------|
| **gnetId** (runtime download) | Simple config, auto-updates | Requires internet, depends on Grafana.com availability, dashboards may change unexpectedly |
| **ConfigMap** (this approach) | Offline capable, version controlled, consistent deployments | Requires manual updates, more files to manage |

## ConfigMap Size Limit

Kubernetes ConfigMaps are limited to **1MiB (1,048,576 bytes)**. Each dashboard is stored
in its own ConfigMap to avoid hitting this limit.

### Dashboard Sizes Reference

| Dashboard | gnetId | Typical Size | Status |
|-----------|--------|--------------|--------|
| Node Exporter Full | 1860 | 200-400KB | ✅ Safe |
| Kubernetes Cluster Overview | 11802 | 100-150KB | ✅ Safe |
| Kubernetes Views Global | 15757 | 80-120KB | ✅ Safe |
| cAdvisor | 14282 | 50-100KB | ✅ Safe |

All dashboards in this set are well under the limit when stored individually.

## Dashboard List

Source: `dashboards-hellodk.yaml`

### Prometheus
- `19268-prometheus-server.json` - Prometheus Server Overview

### Popular Kubernetes Dashboards
- `11802-kubernetes-cluster-overview.json` - Kubernetes Cluster Advanced
- `1860-node-exporter-full.json` - Node Exporter Full (comprehensive node metrics)
- `7249-kubernetes-cluster-summary.json` - Kubernetes Cluster Summary
- `6417-kubernetes-pods.json` - Kubernetes Pods

### Infrastructure
- `14282-cadvisor.json` - cAdvisor Container Metrics
- `10557-kubernetes-capacity.json` - Kubernetes Capacity Planning
- `13332-kube-state-metrics.json` - Kube State Metrics

### Kubernetes Addons / System
- `19105-kubernetes-addons-prometheus.json` - K8s Addons Prometheus
- `16337-trivy-operator.json` - Trivy Operator (Security scanning)
- `15761-kubernetes-system-api-server.json` - API Server
- `15762-kubernetes-system-coredns.json` - CoreDNS

### Kubernetes Views (dotdc dashboards)
- `15757-kubernetes-views-global.json` - Global View
- `15758-kubernetes-views-namespaces.json` - Namespace View
- `15759-kubernetes-views-nodes.json` - Node View
- `15760-kubernetes-views-pods.json` - Pod View

### Capacity Planning
- `13125-kubernetes-capacity-planning-limits.json` - Capacity Planning / Limits

## How to Update Dashboards

### Option 1: Download Script (Recommended)

```bash
# Download all dashboards
cd kube-prometheus-stack
./scripts/download-dashboards.sh

# Download to custom location
./scripts/download-dashboards.sh /path/to/output
```

### Option 2: Manual Download

1. Visit the dashboard on Grafana.com (e.g., https://grafana.com/grafana/dashboards/11802)
2. Click "Download JSON"
3. Save to this directory with naming convention: `{gnetId}-{description}.json`
4. Post-process to fix datasource references (replace `${DS_PROMETHEUS}` with `Prometheus`)

### Option 3: Export from Running Grafana

```bash
# Export dashboard via API
curl -s "http://admin:prom-operator@localhost:3000/api/dashboards/uid/DASHBOARD_UID" \
  | jq '.dashboard' > dashboard.json
```

## Adding a New Dashboard

1. Download the dashboard JSON (using methods above)
2. Save it to this directory: `{gnetId}-{description}.json`
3. Create a template in `templates/grafana/dashboards-hellodk/`:

```yaml
# templates/grafana/dashboards-hellodk/dashboard-{gnetId}.yaml
{{- $kubeTargetVersion := default .Capabilities.KubeVersion.GitVersion .Values.kubeTargetVersionOverride }}
{{- if and (or .Values.grafana.enabled .Values.grafana.forceDeployDashboards) (semverCompare ">=1.14.0-0" $kubeTargetVersion) (semverCompare "<9.9.9-9" $kubeTargetVersion) .Values.grafana.defaultDashboardsEnabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: {{ template "kube-prometheus-stack-grafana.namespace" . }}
  name: {{ printf "%s-%s" (include "kube-prometheus-stack.fullname" $) "dashboard-{gnetId}" | trunc 63 | trimSuffix "-" }}
  annotations:
{{ toYaml .Values.grafana.sidecar.dashboards.annotations | indent 4 }}
  labels:
    {{- if $.Values.grafana.sidecar.dashboards.label }}
    {{ $.Values.grafana.sidecar.dashboards.label }}: {{ ternary $.Values.grafana.sidecar.dashboards.labelValue "1" (not (empty $.Values.grafana.sidecar.dashboards.labelValue)) | quote }}
    {{- end }}
    app: {{ template "kube-prometheus-stack.name" $ }}-grafana
{{ include "kube-prometheus-stack.labels" $ | indent 4 }}
data:
  {dashboard-name}.json: |-
{{ .Files.Get "dashboards-custom/{gnetId}-{description}.json" | indent 4 }}
{{- end }}
```

4. Deploy with Helm:
```bash
helm upgrade --install monitoring . -f values-minikube-1.34.yaml -n monitoring
```

## Datasource Configuration

All dashboards reference `Prometheus` as the datasource. The download script automatically
converts variables like `${DS_PROMETHEUS}` to the literal string `Prometheus`.

If your Prometheus datasource has a different name, update the JSON files accordingly.

## Troubleshooting

### Dashboard not appearing in Grafana

1. Check ConfigMap exists:
   ```bash
   kubectl get configmap -n monitoring -l grafana_dashboard=1
   ```

2. Check Grafana sidecar logs:
   ```bash
   kubectl logs -n monitoring deployment/monitoring-grafana -c grafana-sc-dashboard
   ```

3. Verify label selector matches:
   ```yaml
   # In values file
   sidecar:
     dashboards:
       label: grafana_dashboard
       labelValue: "1"
   ```

### Dashboard shows "No Data"

1. Verify Prometheus datasource is configured
2. Check that required metrics exist:
   ```bash
   kubectl port-forward -n monitoring svc/monitoring-prometheus 9090:9090
   # Open http://localhost:9090 and query metrics
   ```

3. Some dashboards require specific exporters (e.g., node-exporter, kube-state-metrics)

## File Naming Convention

```
{gnetId}-{kebab-case-description}.json
```

Examples:
- `1860-node-exporter-full.json`
- `11802-kubernetes-cluster-overview.json`
- `15757-kubernetes-views-global.json`
