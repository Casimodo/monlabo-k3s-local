#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

NAMESPACE="k8s-local-maria"

load_json_config "$SCRIPT_DIR/.env.json" localPort=MARIADB_LOCAL_PORT

secret_value() {
  kubectl get secret mariadb-credentials -n "$NAMESPACE" -o "jsonpath={.data.$1}" | openssl base64 -d -A
}

check_cluster
require_command openssl

echo "Hôte        : 127.0.0.1"
echo "Port         : ${MARIADB_LOCAL_PORT:-3306}"
echo "Base         : $(secret_value database)"
echo "Utilisateur  : $(secret_value username)"
echo "Mot de passe : $(secret_value password)"
echo "Root         : $(secret_value root-password)"
