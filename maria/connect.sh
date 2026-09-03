#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

NAMESPACE="k8s-local-maria"

load_json_config "$SCRIPT_DIR/.env.json" localPort=MARIADB_LOCAL_PORT

LOCAL_PORT="${MARIADB_LOCAL_PORT:-3306}"

check_cluster
require_local_port "$LOCAL_PORT" localPort
echo "MariaDB sera accessible sur 127.0.0.1:$LOCAL_PORT. Arrêt du tunnel : Ctrl+C"
kubectl port-forward --address 127.0.0.1 -n "$NAMESPACE" service/mariadb "$LOCAL_PORT:3306"
