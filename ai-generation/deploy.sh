#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$MODULE_DIR/scripts/install.sh"
"$MODULE_DIR/scripts/start.sh"

read -r host port < <(cd "$MODULE_DIR" && .venv/bin/python -c 'from server.config import load_settings; s = load_settings(); print(s.host, s.port)')

echo
echo "Web UI : http://$host:$port"
echo "API    : http://$host:$port/api"