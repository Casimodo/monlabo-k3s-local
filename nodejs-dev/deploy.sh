#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

NAMESPACE="k8s-local-nodejs-dev"

check_cluster
ensure_namespace "$NAMESPACE"

kubectl create configmap nodejs-dev-source -n "$NAMESPACE" \
  --from-file="$SCRIPT_DIR/app" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n "$NAMESPACE" -f "$SCRIPT_DIR/k8s"
kubectl rollout restart deployment/nodejs-dev -n "$NAMESPACE"
kubectl rollout status deployment/nodejs-dev -n "$NAMESPACE" --timeout=180s

echo
echo "Node.js est prêt. Ouvrez le tunnel local avec : $SCRIPT_DIR/connect.sh"
echo "Pour synchroniser les modifications : $SCRIPT_DIR/sync.sh --watch"