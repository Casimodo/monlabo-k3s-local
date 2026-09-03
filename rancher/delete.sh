#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

check_cluster
require_command helm

for namespace in k8s-local-rancher cattle-system; do
	helm uninstall rancher -n "$namespace" --ignore-not-found --wait
	delete_namespace "$namespace"
done