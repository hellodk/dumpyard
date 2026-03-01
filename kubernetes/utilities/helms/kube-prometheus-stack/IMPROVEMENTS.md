# Kube-Prometheus-Stack Implementation Review & Improvements

**Review Date:** February 2026  
**Reviewer:** Principal SRE/DevOps  
**Scope:** kube-prometheus-stack Helm chart customization for Minikube environment

---

## Quick Start

### Installation Command

```bash
helm upgrade --install monitoring kube-prometheus-stack \
  -f kube-prometheus-stack/values-minikube-1.34.yaml \
  -n monitoring --create-namespace
```

### Update Dashboards

```bash
cd kubernetes/utilities/helms/kube-prometheus-stack
./scripts/download-dashboards.sh
```

### Plugins

Plugins are automatically installed via an init container defined in `values-minikube-1.34.yaml`.
The init container:
- Downloads plugins from grafana.com on first deployment
- Skips download if plugin already exists on the PVC (smart caching)
- Survives pod restarts without re-downloading

**To add new plugins**, edit the `PLUGINS` list in `extraInitContainers` section of the values file.

**For air-gapped environments**, use the offline plugin ZIPs:

```bash
# Download plugins locally
./scripts/download-plugins.sh

# Copy to running pod (if init container can't reach grafana.com)
for zip in plugins/*.zip; do
    [[ -L "$zip" ]] && continue
    kubectl cp "$zip" monitoring/monitoring-grafana-0:/var/lib/grafana/plugins/
done
kubectl exec monitoring-grafana-0 -n monitoring -c grafana -- \
    sh -c 'cd /var/lib/grafana/plugins && for z in *.zip; do unzip -o "$z" && rm "$z"; done'
```

---

## Executive Summary

This document provides a comprehensive review of the kube-prometheus-stack implementation with actionable recommendations categorized by priority. The implementation is generally well-structured but has several areas requiring attention for production readiness.

---

## Table of Contents

1. [Critical Issues](#critical-issues)
2. [Security Improvements](#security-improvements)
3. [Operational Improvements](#operational-improvements)
4. [Dashboard Management](#dashboard-management)
5. [Performance & Scalability](#performance--scalability)
6. [Monitoring Best Practices](#monitoring-best-practices)
7. [Implementation Checklist](#implementation-checklist)

---

## Critical Issues

### 1. Missing Dashboard JSON Files (BLOCKER)

**Issue:** Custom dashboard templates reference non-existent JSON files.

```
templates/grafana/dashboards-custom-11802.yaml → dashboards-custom/11802-kubernetes-cluster-overview.json
templates/grafana/dashboards-custom-13125.yaml → dashboards-custom/13125-kubernetes-capacity-planning-limits.json
```

**Impact:** Helm install/upgrade will fail with empty dashboard ConfigMaps.

**Resolution:**
```bash
# Create directory and download dashboards
mkdir -p dashboards-custom
./scripts/download-dashboards.sh
```

### 2. Hardcoded Admin Credentials (SECURITY)

**Issue:** Grafana admin password is in plaintext in values file.

```yaml
# Current (INSECURE)
adminUser: admin
adminPassword: prom-operator
```

**Resolution:** Use Kubernetes Secrets with Helm:

```yaml
# Option 1: Reference existing secret
admin:
  existingSecret: "grafana-admin-credentials"
  userKey: admin-user
  passwordKey: admin-password

# Option 2: Use sealed-secrets or external-secrets operator
```

---

## Security Improvements

### 1. Network Policies

**Recommendation:** Add NetworkPolicies to restrict traffic flow.

```yaml
# Add to values file
networkPolicy:
  enabled: true
  
# Or create separate NetworkPolicy manifests for:
# - Prometheus → only allow scrape targets
# - Grafana → only allow ingress traffic
# - Alertmanager → only allow Prometheus
```

### 2. Pod Security Standards

**Current:** Not explicitly configured.

**Recommendation:** Enable Pod Security Standards:

```yaml
# Add to Prometheus, Grafana, Alertmanager configurations
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 65534
  fsGroup: 65534
  seccompProfile:
    type: RuntimeDefault

containerSecurityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
      - ALL
```

### 3. TLS/mTLS Configuration

**Recommendation:** Enable TLS for internal communication:

```yaml
prometheus:
  prometheusSpec:
    web:
      tlsConfig:
        cert:
          secret:
            name: prometheus-tls
            key: tls.crt
        keySecret:
          name: prometheus-tls
          key: tls.key
```

### 4. RBAC Audit

**Recommendation:** Review and minimize RBAC permissions:
- Ensure ServiceAccounts use least-privilege principle
- Remove cluster-admin bindings if present
- Use namespace-scoped roles where possible

---

## Operational Improvements

### 1. Resource Requests and Limits

**Issue:** Default resource configurations may not be optimal.

**Recommendation:**

```yaml
prometheus:
  prometheusSpec:
    resources:
      requests:
        memory: 2Gi
        cpu: 500m
      limits:
        memory: 4Gi
        cpu: 2000m

grafana:
  resources:
    requests:
      memory: 256Mi
      cpu: 100m
    limits:
      memory: 512Mi
      cpu: 500m

alertmanager:
  alertmanagerSpec:
    resources:
      requests:
        memory: 128Mi
        cpu: 50m
      limits:
        memory: 256Mi
        cpu: 200m
```

### 2. Prometheus Data Retention

**Current:** Default 10d retention.

**Recommendation:** Configure based on storage capacity:

```yaml
prometheus:
  prometheusSpec:
    retention: 15d
    retentionSize: 45GB  # Stop before filling disk
    
    # Enable WAL compression for better performance
    walCompression: true
```

### 3. Alertmanager Configuration

**Recommendation:** Configure proper alerting routes:

```yaml
alertmanager:
  config:
    global:
      resolve_timeout: 5m
      slack_api_url: '<slack-webhook-url>'
    
    route:
      group_by: ['alertname', 'namespace', 'severity']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 4h
      receiver: 'default-receiver'
      routes:
        - match:
            severity: critical
          receiver: 'critical-alerts'
          continue: true
    
    receivers:
      - name: 'default-receiver'
        slack_configs:
          - channel: '#alerts'
      - name: 'critical-alerts'
        slack_configs:
          - channel: '#critical-alerts'
        pagerduty_configs:
          - service_key: '<pagerduty-key>'
```

### 4. High Availability Setup

**For Production:** Enable HA for Prometheus and Alertmanager:

```yaml
prometheus:
  prometheusSpec:
    replicas: 2
    replicaExternalLabelName: prometheus_replica
    
alertmanager:
  alertmanagerSpec:
    replicas: 3
```

### 5. Persistent Volume Claims

**Current:** Using `nfs-client` StorageClass.

**Recommendation:** Verify storage class exists and consider:

```yaml
prometheus:
  prometheusSpec:
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: nfs-client
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
```

---

## Dashboard Management

### Current Approach Analysis

The `dashboards-hellodk.yaml` uses Grafana's `gnetId` approach which:
- **Pros:** Simple configuration, automatic updates
- **Cons:** Requires internet access, dependent on Grafana.com availability, dashboards may change unexpectedly

### Recommended Approach: ConfigMap-Based Dashboards

**Advantages:**
1. **Offline capability** - No internet required at deployment
2. **Version control** - Dashboard JSON tracked in Git
3. **Consistency** - Same dashboard version across deployments
4. **Size management** - One dashboard per ConfigMap avoids 1MiB limit

**Implementation:**
- Use the provided `scripts/download-dashboards.sh` to fetch dashboards
- Templates in `templates/grafana/dashboards-hellodk/` create ConfigMaps
- Each dashboard is a separate ConfigMap (~50-300KB each)

### ConfigMap Size Limits

**Kubernetes Limit:** 1MiB (1,048,576 bytes) per ConfigMap

**Dashboard Size Reference:**
| Dashboard | gnetId | Typical Size |
|-----------|--------|--------------|
| Node Exporter Full | 1860 | ~200-400KB |
| K8s Cluster Advanced | 11802 | ~100-150KB |
| K8s Views Global | 15757 | ~80-120KB |

**Mitigation Strategy:**
1. One dashboard per ConfigMap (already implemented)
2. Minify JSON if needed (removes whitespace)
3. Split extremely large dashboards (rare, >500KB)

---

## Performance & Scalability

### 1. Scrape Configuration Optimization

```yaml
prometheus:
  prometheusSpec:
    scrapeInterval: 30s      # Default is fine for most cases
    scrapeTimeout: 10s       # Should be < scrapeInterval
    evaluationInterval: 30s  # Match scrapeInterval
```

### 2. Query Performance

**Recommendation:** Enable query logging for optimization:

```yaml
prometheus:
  prometheusSpec:
    enableFeatures:
      - memory-snapshot-on-shutdown
      - new-service-discovery-manager
    
    additionalArgs:
      - --query.max-concurrency=20
      - --query.timeout=2m
```

### 3. ServiceMonitor Optimization

**Recommendation:** Use relabeling to reduce cardinality:

```yaml
# Example: Drop high-cardinality labels
additionalServiceMonitors:
  - name: example
    selector:
      matchLabels:
        app: myapp
    endpoints:
      - port: metrics
        metricRelabelings:
          - sourceLabels: [__name__]
            regex: 'go_.*'
            action: drop  # Drop Go runtime metrics if not needed
```

---

## Monitoring Best Practices

### 1. Recording Rules

Add recording rules for frequently queried expressions:

```yaml
additionalPrometheusRulesMap:
  recording-rules:
    groups:
      - name: node-recording-rules
        rules:
          - record: instance:node_cpu_utilisation:rate5m
            expr: |
              1 - avg without(cpu) (
                rate(node_cpu_seconds_total{mode="idle"}[5m])
              )
          - record: instance:node_memory_utilisation:ratio
            expr: |
              1 - (
                node_memory_MemAvailable_bytes /
                node_memory_MemTotal_bytes
              )
```

### 2. Alert Severity Standards

Adopt consistent severity levels:

| Severity | Response Time | Examples |
|----------|---------------|----------|
| critical | 5 minutes | Service down, data loss risk |
| warning | 30 minutes | High resource usage, degraded performance |
| info | Next business day | Optimization opportunities |

### 3. Dashboard Organization

```
Grafana Folders:
├── Infrastructure/
│   ├── Node Exporter Full
│   ├── Kubernetes Capacity
│   └── cAdvisor
├── Kubernetes/
│   ├── Cluster Overview
│   ├── Namespace Views
│   └── Pod Views
├── Applications/
│   └── (Custom app dashboards)
└── System/
    ├── Prometheus
    ├── Alertmanager
    └── CoreDNS
```

---

## Implementation Checklist

### Immediate Actions (P0)

- [ ] Create `dashboards-custom/` directory
- [ ] Run `./scripts/download-dashboards.sh` to fetch dashboard JSONs
- [ ] Move admin credentials to Kubernetes Secret
- [ ] Verify `nfs-client` StorageClass exists

### Short-term (P1)

- [ ] Configure resource requests/limits
- [ ] Set up Alertmanager receivers (Slack/PagerDuty)
- [ ] Enable recording rules for common queries
- [ ] Review and test all dashboards after deployment

### Medium-term (P2)

- [ ] Implement NetworkPolicies
- [ ] Enable TLS for internal communication
- [ ] Set up backup for Prometheus data
- [ ] Configure remote write for long-term storage (optional)

### Long-term (P3)

- [ ] Implement multi-cluster monitoring (if needed)
- [ ] Set up Grafana Teams and folder permissions
- [ ] Create custom dashboards for applications
- [ ] Performance baseline and capacity planning

---

## File Structure After Implementation

```
kube-prometheus-stack/
├── Chart.yaml
├── Chart.lock
├── values.yaml
├── values-minikube-1.34.yaml
├── values-minikube-1.34.yaml.backup         # Backup of original values
├── IMPROVEMENTS.md                          # This document
├── dashboards-custom/                       # Dashboard JSON files
│   ├── README.md
│   ├── avika-placeholder.json               # Placeholder for Avika folder
│   ├── 1860-node-exporter-full.json
│   ├── 6417-kubernetes-pods.json
│   ├── 7249-kubernetes-cluster-summary.json
│   ├── 10557-kubernetes-capacity.json
│   ├── 11802-kubernetes-cluster-overview.json
│   ├── 13125-kubernetes-capacity-planning-limits.json
│   ├── 13332-kube-state-metrics.json
│   ├── 14282-cadvisor.json
│   ├── 15757-kubernetes-views-global.json
│   ├── 15758-kubernetes-views-namespaces.json
│   ├── 15759-kubernetes-views-nodes.json
│   ├── 15760-kubernetes-views-pods.json
│   ├── 15761-kubernetes-system-api-server.json
│   ├── 15762-kubernetes-system-coredns.json
│   ├── 16337-trivy-operator.json
│   ├── 19105-kubernetes-addons-prometheus.json
│   └── 19268-prometheus-server.json
├── plugins/                                 # Offline plugin ZIPs (247MB)
│   ├── README.md
│   ├── btplc-status-dot-panel-0.2.4.zip
│   ├── digrich-bubblechart-panel-2.0.1.zip
│   ├── grafana-clickhouse-datasource-4.13.0.zip
│   ├── grafana-clock-panel-3.2.1.zip
│   ├── grafana-opensearch-datasource-2.32.4.zip
│   ├── grafana-piechart-panel-1.6.4.zip
│   ├── grafana-polystat-panel-2.1.16.zip
│   ├── marcusolsson-json-datasource-1.3.27.zip
│   ├── redis-datasource-2.2.0.zip
│   └── yesoreyeram-infinity-datasource-3.7.1.zip
├── scripts/
│   ├── download-dashboards.sh               # Dashboard download script
│   └── download-plugins.sh                  # Plugin download script
└── templates/
    └── grafana/
        ├── dashboards-1.14/                 # Default dashboards (General folder)
        └── dashboards-hellodk/              # Organized dashboard templates
            ├── avika/                       # Avika folder dashboards
            │   └── dashboard-avika-placeholder.yaml
            ├── infrastructure/              # Infrastructure folder dashboards
            │   ├── dashboard-1860.yaml      # Node Exporter Full
            │   ├── dashboard-10557.yaml     # Kubernetes Capacity
            │   └── dashboard-14282.yaml     # cAdvisor
            ├── kubernetes-cluster/          # Kubernetes/Cluster folder
            │   ├── dashboard-6417.yaml      # Kubernetes Pods
            │   ├── dashboard-7249.yaml      # Cluster Summary
            │   ├── dashboard-11802.yaml     # Cluster Overview
            │   └── dashboard-13332.yaml     # Kube State Metrics
            ├── kubernetes-views/            # Kubernetes/Views folder (dotdc)
            │   ├── dashboard-15757.yaml     # Global View
            │   ├── dashboard-15758.yaml     # Namespaces View
            │   ├── dashboard-15759.yaml     # Nodes View
            │   └── dashboard-15760.yaml     # Pods View
            ├── kubernetes-system/           # Kubernetes/System folder
            │   ├── dashboard-15761.yaml     # API Server
            │   └── dashboard-15762.yaml     # CoreDNS
            ├── monitoring/                  # Monitoring folder
            │   ├── dashboard-19105.yaml     # K8s Addons Prometheus
            │   └── dashboard-19268.yaml     # Prometheus Server
            └── security/                    # Security folder
                └── dashboard-16337.yaml     # Trivy Operator
```

### Grafana Folder Structure

Dashboards are organized into the following Grafana folders:

| Folder | Dashboards |
|--------|------------|
| **Avika** | Welcome placeholder (for custom dashboards) |
| **Infrastructure** | Node Exporter Full, cAdvisor, Kubernetes Capacity |
| **Kubernetes/Cluster** | Cluster Overview, Cluster Summary, Pods, Kube State Metrics |
| **Kubernetes/Views** | Global, Namespaces, Nodes, Pods (dotdc dashboards) |
| **Kubernetes/System** | API Server, CoreDNS |
| **Monitoring** | Prometheus Server, K8s Addons Prometheus |
| **Security** | Trivy Operator |
| **General** | Default kube-prometheus-stack dashboards |

---

## References

- [Prometheus Operator Documentation](https://prometheus-operator.dev/)
- [Grafana Sidecar Documentation](https://github.com/grafana/helm-charts/tree/main/charts/grafana)
- [Kubernetes ConfigMap Limits](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/dashboards/build-dashboards/best-practices/)

---

*Document maintained by: SRE Team*  
*Last updated: February 2026*
