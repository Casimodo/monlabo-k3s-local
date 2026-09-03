#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

check_cluster
require_command helm
helm uninstall rancher -n k8s-local-rancher --ignore-not-found --wait
delete_namespace k8s-local-rancher