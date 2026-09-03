#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_json_config "$SCRIPT_DIR/.env.json" \
  chartVersion=RANCHER_CHART_VERSION \
  hostname=RANCHER_HOSTNAME \
  replicas=RANCHER_REPLICAS \
  localPort=RANCHER_LOCAL_PORT

NAMESPACE="k8s-local-rancher"
CHART_VERSION="${RANCHER_CHART_VERSION:-2.15.1}"
HOSTNAME="${RANCHER_HOSTNAME:-127.0.0.1.sslip.io}"
REPLICAS="${RANCHER_REPLICAS:-1}"

check_cluster
require_command helm
require_command openssl
ensure_namespace "$NAMESPACE"

if ! kubectl get secret rancher-bootstrap -n "$NAMESPACE" >/dev/null 2>&1; then
  bootstrap_password="$(openssl rand -hex 16)"
  kubectl create secret generic rancher-bootstrap -n "$NAMESPACE" \
    --from-literal="password=$bootstrap_password"
fi

bootstrap_password="$(kubectl get secret rancher-bootstrap -n "$NAMESPACE" -o jsonpath='{.data.password}' | openssl base64 -d -A)"

helm repo add rancher-stable https://releases.rancher.com/server-charts/stable --force-update
helm repo update rancher-stable
helm upgrade --install rancher rancher-stable/rancher \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION" \
  --set "hostname=$HOSTNAME" \
  --set "replicas=$REPLICAS" \
  --set ingress.enabled=false \
  --set ingress.tls.source=secret \
  --set "bootstrapPassword=$bootstrap_password" \
  --wait \
  --timeout 10m

echo
echo "Rancher Web est prêt. Affichez les accès avec : $SCRIPT_DIR/credentials.sh"
echo "Ouvrez le tunnel local avec : $SCRIPT_DIR/connect.sh"