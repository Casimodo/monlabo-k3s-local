#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"
source "$SCRIPT_DIR/../scripts/cfx-common.sh"
load_json_config "$SCRIPT_DIR/.env.json" localPort=CFX_LOCAL_PORT
connect_cfx redm 30122