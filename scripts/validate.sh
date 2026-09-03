#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/scripts/common.sh"

check_cluster
require_command openssl
require_command jq

find "$ROOT_DIR" -name '*.sh' -print0 | while IFS= read -r -d '' script; do
  bash -n "$script"
done

find "$ROOT_DIR" -name '.env-temp.json' -print0 | while IFS= read -r -d '' config; do
  jq -e 'type == "object"' "$config" >/dev/null
done

for manifests_dir in "$ROOT_DIR"/*/k8s; do
  if [[ -d "$manifests_dir" ]]; then
    kubectl apply --dry-run=client -f "$manifests_dir" >/dev/null
  fi
done

echo "Validation réussie."