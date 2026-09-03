#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_json_config "$SCRIPT_DIR/.env.json" \
  database=MARIADB_DATABASE \
  user=MARIADB_USER \
  localPort=MARIADB_LOCAL_PORT

MARIADB_DATABASE="${MARIADB_DATABASE:-app}"
MARIADB_USER="${MARIADB_USER:-app}"
NAMESPACE="k8s-local-maria"

check_cluster
require_command openssl

ensure_namespace "$NAMESPACE"

if ! kubectl get secret mariadb-credentials -n "$NAMESPACE" >/dev/null 2>&1; then
  mariadb_password="$(openssl rand -hex 24)"
  mariadb_root_password="$(openssl rand -hex 24)"
  kubectl create secret generic mariadb-credentials -n "$NAMESPACE" \
    --from-literal="database=$MARIADB_DATABASE" \
    --from-literal="username=$MARIADB_USER" \
    --from-literal="password=$mariadb_password" \
    --from-literal="root-password=$mariadb_root_password"
fi

kubectl apply -n "$NAMESPACE" -f "$SCRIPT_DIR/k8s"
kubectl rollout status deployment/mariadb -n "$NAMESPACE" --timeout=180s

echo
echo "MariaDB est prête. Affichez les accès avec : $SCRIPT_DIR/credentials.sh"
echo "Ouvrez le tunnel local avec : $SCRIPT_DIR/connect.sh"
