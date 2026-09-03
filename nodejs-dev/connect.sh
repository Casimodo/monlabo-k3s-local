#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_json_config "$SCRIPT_DIR/.env.json" localPort=NODEJS_LOCAL_PORT

NAMESPACE="k8s-local-nodejs-dev"
LOCAL_PORT="${NODEJS_LOCAL_PORT:-3000}"

check_cluster
require_local_port "$LOCAL_PORT" localPort
echo "Site Node.js : http://127.0.0.1:$LOCAL_PORT"
echo "Arrêt du tunnel : Ctrl+C"
kubectl port-forward --address 127.0.0.1 -n "$NAMESPACE" service/nodejs-dev "$LOCAL_PORT:3000"