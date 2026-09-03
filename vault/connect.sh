#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

NAMESPACE="k8s-local-vault"
load_json_config "$SCRIPT_DIR/.env.json" localPort=VAULT_LOCAL_PORT
LOCAL_PORT="${VAULT_LOCAL_PORT:-8200}"

check_cluster
require_command openssl
require_local_port "$LOCAL_PORT" localPort
ROOT_TOKEN="$(kubectl get secret vault-credentials -n "$NAMESPACE" -o jsonpath='{.data.root-token}' | openssl base64 -d -A)"

echo "URL   : http://127.0.0.1:$LOCAL_PORT"
echo "Token : $ROOT_TOKEN"
echo "Arrêt du tunnel : Ctrl+C"
kubectl port-forward --address 127.0.0.1 -n "$NAMESPACE" service/vault "$LOCAL_PORT:8200"
