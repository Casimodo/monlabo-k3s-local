#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

load_json_config "$SCRIPT_DIR/.env.json" \
  localPort=RANCHER_LOCAL_PORT \
  hostname=RANCHER_HOSTNAME

check_cluster
require_command openssl

if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--reset" ) ]]; then
  echo "Usage : $0 [--reset]" >&2
  exit 1
fi

if [[ "${1:-}" == "--reset" ]]; then
  reset_output="$(mktemp)"
  trap 'rm -f "$reset_output"' EXIT
  chmod 600 "$reset_output"

  kubectl exec -n cattle-system deployment/rancher -- reset-password >"$reset_output"
  password="$(tail -n 1 "$reset_output" | tr -d '\r\n')"
  if [[ -z "$password" || "${#password}" -lt 12 ]]; then
    echo "Erreur : impossible de lire le mot de passe généré par Rancher." >&2
    exit 1
  fi

  kubectl create secret generic rancher-bootstrap -n cattle-system \
    --from-literal="password=$password" --dry-run=client -o yaml | kubectl apply -f - >/dev/null
  kubectl create secret generic bootstrap-secret -n cattle-system \
    --from-literal="bootstrapPassword=$password" --dry-run=client -o yaml | kubectl apply -f - >/dev/null
fi

echo "URL             : https://${RANCHER_HOSTNAME:-127.0.0.1.sslip.io}:${RANCHER_LOCAL_PORT:-8443}"
echo "Utilisateur     : admin"
echo "Mot de passe    : $(kubectl get secret rancher-bootstrap -n cattle-system -o jsonpath='{.data.password}' | openssl base64 -d -A)"