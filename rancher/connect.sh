#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_json_config "$SCRIPT_DIR/.env.json" \
  localPort=RANCHER_LOCAL_PORT \
  hostname=RANCHER_HOSTNAME

NAMESPACE="cattle-system"
LOCAL_PORT="${RANCHER_LOCAL_PORT:-8443}"
HOSTNAME="${RANCHER_HOSTNAME:-127.0.0.1.sslip.io}"

check_cluster
require_local_port "$LOCAL_PORT" localPort
echo "Rancher Web : https://$HOSTNAME:$LOCAL_PORT"
echo "Arrêt du tunnel : Ctrl+C"
kubectl port-forward --address 127.0.0.1 -n "$NAMESPACE" service/rancher "$LOCAL_PORT:443"