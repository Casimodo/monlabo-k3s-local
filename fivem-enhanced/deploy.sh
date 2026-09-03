#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"
source "$SCRIPT_DIR/../scripts/cfx-common.sh"
load_json_config "$SCRIPT_DIR/.env.json" \
	serverDownloadUrl=CFX_SERVER_DOWNLOAD_URL \
	localPort=CFX_LOCAL_PORT \
	licenseKey=CFX_LICENSE_KEY
deploy_cfx "$SCRIPT_DIR" fivem-enhanced 30121