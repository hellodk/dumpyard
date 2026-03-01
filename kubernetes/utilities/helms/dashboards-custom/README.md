# Custom Grafana Dashboards

This folder contains custom Grafana dashboards that are added to the kube-prometheus-stack Helm chart.

## Structure

- **JSON Files**: Dashboard JSON files are stored here with the naming convention: `{dashboard-id}-{dashboard-name}.json`
- **ConfigMap Templates**: Corresponding Helm templates are created in `templates/grafana/dashboards-custom-{id}.yaml`

## Added Dashboards

### Dashboard ID: 11802
- **Name**: Kubernetes cluster overview
- **File**: `11802-kubernetes-cluster-overview.json`
- **Template**: `templates/grafana/dashboards-custom-11802.yaml`
- **Source**: https://grafana.com/grafana/dashboards/11802
- **Description**: This dashboard can help troubleshooting issue in Kubernetes cluster at cluster, node and namespace level.

### Dashboard ID: 13125
- **Name**: Kubernetes / Capacity Planning / Limits
- **File**: `13125-kubernetes-capacity-planning-limits.json`
- **Template**: `templates/grafana/dashboards-custom-13125.yaml`
- **Source**: https://grafana.com/grafana/dashboards/13125
- **Description**: Provides information relevant to fine-tuning container resource limits in Kubernetes

## How to Add More Dashboards

1. Fetch the dashboard JSON from Grafana.com:
   ```bash
   curl -s https://grafana.com/api/dashboards/{DASHBOARD_ID}/revisions/1/download > dashboards-custom/{DASHBOARD_ID}-{dashboard-name}.json
   ```

2. Create a ConfigMap template in `templates/grafana/dashboards-custom-{ID}.yaml` following the pattern of existing templates.

3. The dashboards will be automatically loaded by Grafana's sidecar when the Helm chart is deployed.

## Notes

- Dashboards are automatically discovered by Grafana's sidecar when ConfigMaps have the label `grafana_dashboard: "1"`
- The templates follow the same pattern as the built-in dashboards in `templates/grafana/dashboards-1.14/`
- JSON files are loaded using Helm's `.Files.Get` function
