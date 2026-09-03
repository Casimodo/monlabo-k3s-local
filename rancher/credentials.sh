#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_json_config "$SCRIPT_DIR/.env.json" \
  localPort=RANCHER_LOCAL_PORT \
  hostname=RANCHER_HOSTNAME

check_cluster
require_command openssl

echo "URL             : https://${RANCHER_HOSTNAME:-127.0.0.1.sslip.io}:${RANCHER_LOCAL_PORT:-8443}"
echo "Utilisateur     : admin"
echo "Mot de passe    : $(kubectl get secret rancher-bootstrap -n k8s-local-rancher -o jsonpath='{.data.password}' | openssl base64 -d -A)"