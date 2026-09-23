#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$MODULE_DIR/.runtime/server.pid"

if [[ ! -f "$PID_FILE" ]] || ! kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo "Erreur : AI Generation n'est pas démarré. Lancez ./deploy.sh." >&2
  exit 1
fi

read -r host port < <(cd "$MODULE_DIR" && .venv/bin/python -c 'from server.config import load_settings; s = load_settings(); print(s.host, s.port)')
base_url="http://$host:$port"

echo "AI Generation Lab"
echo
echo "Web UI:"
echo "$base_url"
echo
echo "API:"
echo "$base_url/api"
echo
echo "Health:"
echo "$base_url/api/health"

if [[ "$(uname -s)" == "Darwin" ]] && command -v open >/dev/null 2>&1; then
  open "$base_url"
fi