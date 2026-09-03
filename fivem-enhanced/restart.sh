#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"
source "$SCRIPT_DIR/../scripts/cfx-common.sh"
restart_cfx fivem-enhanced