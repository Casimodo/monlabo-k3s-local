#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

NAMESPACE="k8s-local-nodejs-dev"
load_json_config "$SCRIPT_DIR/.env.json" syncIntervalSeconds=NODEJS_SYNC_INTERVAL_SECONDS
SYNC_INTERVAL_SECONDS="${NODEJS_SYNC_INTERVAL_SECONDS:-2}"

if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "--watch" ) ]]; then
  echo "Usage : $0 [--watch]" >&2
  exit 1
fi

check_cluster
require_command cksum
require_command tar

sync_source() {
  local pod
  pod="$(kubectl get pod -n "$NAMESPACE" -l app.kubernetes.io/name=nodejs-dev -o jsonpath='{.items[0].metadata.name}')"
  kubectl cp "$SCRIPT_DIR/app/." "$NAMESPACE/$pod:/app"
  kubectl exec -n "$NAMESPACE" "$pod" -- npm install
  echo "Sources synchronisées."
}

source_checksum() {
  find "$SCRIPT_DIR/app" -type f -exec cksum {} \; | cksum
}

sync_source

if [[ "${1:-}" == "--watch" ]]; then
  previous_checksum="$(source_checksum)"
  echo "Surveillance du dossier app. Arrêt : Ctrl+C"
  while true; do
    sleep "$SYNC_INTERVAL_SECONDS"
    current_checksum="$(source_checksum)"
    if [[ "$current_checksum" != "$previous_checksum" ]]; then
      sync_source
      previous_checksum="$current_checksum"
    fi
  done
fi