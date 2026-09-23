#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RUNTIME_DIR="$MODULE_DIR/.runtime"
PID_FILE="$RUNTIME_DIR/server.pid"
LOG_FILE="$RUNTIME_DIR/server.log"
PYTHON="$MODULE_DIR/.venv/bin/python"

if [[ ! -x "$PYTHON" ]]; then
  echo "Erreur : environnement Python absent. Lancez ./deploy.sh." >&2
  exit 1
fi

read -r host port < <(cd "$MODULE_DIR" && "$PYTHON" -c 'from server.config import load_settings; s = load_settings(); print(s.host, s.port)')
base_url="http://$host:$port"

if [[ -f "$PID_FILE" ]]; then
  pid="$(cat "$PID_FILE")"
  if [[ "$pid" =~ ^[0-9]+$ ]] && kill -0 "$pid" 2>/dev/null; then
    echo "AI Generation est déjà démarré (PID $pid)."
    exit 0
  fi
  rm -f "$PID_FILE"
fi

mkdir -p "$RUNTIME_DIR"
cd "$MODULE_DIR"
nohup "$PYTHON" -m server.app >>"$LOG_FILE" 2>&1 &
pid=$!
printf '%s\n' "$pid" >"$PID_FILE"

for _ in {1..30}; do
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Erreur : le serveur s'est arrêté. Consultez $LOG_FILE" >&2
    rm -f "$PID_FILE"
    exit 1
  fi
  if "$PYTHON" -c "import json, urllib.request; json.load(urllib.request.urlopen('$base_url/api/health', timeout=1))" 2>/dev/null; then
    echo "AI Generation démarré sur $base_url (PID $pid)."
    exit 0
  fi
  sleep 1
done

echo "Erreur : le serveur ne répond pas sur $base_url." >&2
"$MODULE_DIR/scripts/stop.sh"
exit 1