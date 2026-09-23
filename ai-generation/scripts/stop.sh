#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_FILE="$MODULE_DIR/.runtime/server.pid"

if [[ ! -f "$PID_FILE" ]]; then
  echo "AI Generation est déjà arrêté."
  exit 0
fi

pid="$(cat "$PID_FILE")"
if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
  echo "Erreur : fichier PID invalide : $PID_FILE" >&2
  exit 1
fi

if kill -0 "$pid" 2>/dev/null; then
  kill "$pid"
  for _ in {1..15}; do
    process_state="$(ps -o state= -p "$pid" 2>/dev/null | tr -d '[:space:]')"
    if ! kill -0 "$pid" 2>/dev/null || [[ "$process_state" == Z* ]]; then
      break
    fi
    sleep 1
  done
  process_state="$(ps -o state= -p "$pid" 2>/dev/null | tr -d '[:space:]')"
  if kill -0 "$pid" 2>/dev/null && [[ "$process_state" != Z* ]]; then
    echo "Erreur : le processus $pid ne s'est pas arrêté proprement." >&2
    exit 1
  fi
fi

rm -f "$PID_FILE"
echo "AI Generation arrêté."