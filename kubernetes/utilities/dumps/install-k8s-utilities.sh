#!/usr/bin/env bash
set -u -o pipefail

### ===== CONFIG =====
HELM_DIR="$HOME/Documents/git/dumpyard/kubernetes/utilities/helms"
MANIFEST_DIR="$HOME/Documents/git/dumpyard/kubernetes/utilities"

### ===== STATE =====
SUCCEEDED=()
FAILED=()

### ===== UTILS =====
log() { echo -e "\n🔹 $1\n"; }

exists() { command -v "$1" >/dev/null 2>&1; }

run_step() {
  local name="$1"
  shift
  echo "▶️  $name"
  if "$@"; then
    SUCCEEDED+=("$name")
    echo "✅ $name"
  else
    FAILED+=("$name")
    echo "❌ $name (failed, continuing)"
  fi
}

safe_cd() {
  cd "$1" || return 1
}

### ===== BASIC TOOLS =====
log "Checking base tools..."

for tool in kubectl helm curl tar; do
  run_step "Check tool: $tool" exists "$tool"
done

### ===== INSTALL KREW =====
if ! kubectl krew >/dev/null 2>&1; then
  log "Installing krew..."

  run_step "Create temp dir" mktemp -d
  tmp=$(mktemp -d || true)

  if [[ -n "${tmp:-}" ]]; then
    safe_cd "$tmp" || true

    OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ARCH="$(uname -m | sed \
      -e 's/x86_64/amd64/' \
      -e 's/aarch64/arm64/' \
      -e 's/armv.*/arm/')"

    KREW="krew-${OS}_${ARCH}"

    run_step "Download krew" curl -fsSLO \
      "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"

    run_step "Extract krew" tar zxvf "${KREW}.tar.gz"

    run_step "Install krew" ./"${KREW}" install krew

    export PATH="$HOME/.krew/bin:$PATH"
  else
    FAILED+=("Install krew (tmp dir)")
  fi
else
  SUCCEEDED+=("krew already installed")
fi

### ===== INSTALL KREW PLUGINS =====
log "Installing kubectl plugins..."

PLUGINS=(krew ns ctx)

for p in "${PLUGINS[@]}"; do
  run_step "Install krew plugin: $p" kubectl krew install "$p"
done

### ===== INSTALL K9S =====
if ! exists k9s; then
  log "Installing k9s..."
  run_step "Install k9s" bash -c "curl -fsSL https://webinstall.dev/k9s | bash"
else
  SUCCEEDED+=("k9s already installed")
fi

### ===== INSTALL KUSTOMIZE =====
if ! exists kustomize; then
  log "Installing kustomize..."
  run_step "Install kustomize" bash -c "curl -fsSL https://webinstall.dev/kustomize | bash"
else
  SUCCEEDED+=("kustomize already installed")
fi

### ===== NAMESPACES =====
log "Creating namespaces..."

run_step "Create namespace monitoring" kubectl get ns monitoring >/dev/null 2>&1 || kubectl create ns monitoring
run_step "Create namespace utilities" kubectl get ns utilities >/dev/null 2>&1 || kubectl create ns utilities

### ===== HELM DEPLOYMENTS =====
log "Deploying Helm charts..."

run_step "Helm install nfs provisioner" helm upgrade --install \
  nfs-subdir-external-provisioner \
  "$HELM_DIR/nfs-subdir-external-provisioner-4.0.18" \
  -n kube-system

run_step "Helm install kube-prometheus-stack" helm upgrade --install \
  monitoring \
  "$HELM_DIR/kube-prometheus-stack" \
  -f "$HELM_DIR/kube-prometheus-stack/values-minikube-1.34.yaml" \
  -n monitoring

### ===== APPLY CORE MANIFESTS =====
log "Applying cluster manifests..."

safe_cd "$MANIFEST_DIR" || FAILED+=("cd MANIFEST_DIR")

run_step "Apply nginx-lab-with-agent" kubectl apply -f nginx-lab-with-agent.yaml
run_step "Apply guacamole" kubectl apply -f guacamole2.yaml
run_step "Apply jenkins" kubectl apply -f jenkins
run_step "Apply otel collector" kubectl apply -f otel-collector-gateway.yaml

### ===== METRICS SERVER =====
log "Installing Metrics Server..."

run_step "Install metrics-server" kubectl apply -f \
  https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

### ===== FINAL REPORT =====
echo
echo "================ BOOTSTRAP REPORT ================"
echo "✅ Succeeded:"
for s in "${SUCCEEDED[@]}"; do
  echo "  - $s"
done

echo
echo "❌ Failed:"
for f in "${FAILED[@]}"; do
  echo "  - $f"
done

echo
echo "📊 Summary:"
echo "  Success: ${#SUCCEEDED[@]}"
echo "  Failed : ${#FAILED[@]}"
echo "================================================="
