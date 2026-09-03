#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

NAMESPACE="k8s-local-vault"

check_cluster
require_command openssl

ensure_namespace "$NAMESPACE"

if ! kubectl get secret vault-credentials -n "$NAMESPACE" >/dev/null 2>&1; then
  root_token="$(openssl rand -hex 24)"
  kubectl create secret generic vault-credentials -n "$NAMESPACE" \
    --from-literal="root-token=$root_token"
fi

kubectl apply -n "$NAMESPACE" -f "$SCRIPT_DIR/k8s"
kubectl rollout status deployment/vault -n "$NAMESPACE" --timeout=180s

echo
echo "Vault est prêt en mode développement. Ouvrez l'interface avec : $SCRIPT_DIR/connect.sh"
