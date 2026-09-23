#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

"$MODULE_DIR/scripts/stop.sh"

if [[ "${1:-}" == "--all" ]]; then
  echo "Cette opération supprimera l'environnement Python et toutes les générations."
  read -r -p "Saisissez DELETE pour confirmer : " confirmation
  if [[ "$confirmation" != "DELETE" ]]; then
    echo "Suppression annulée."
    exit 0
  fi
  rm -rf "$MODULE_DIR/.venv" "$MODULE_DIR/.runtime" "$MODULE_DIR/outputs"
  mkdir -p "$MODULE_DIR/outputs/images" "$MODULE_DIR/outputs/videos"
  echo "AI Generation et ses sorties ont été supprimés."
elif [[ -n "${1:-}" ]]; then
  echo "Usage : ./delete.sh [--all]" >&2
  exit 1
else
  rm -rf "$MODULE_DIR/.runtime"
  echo "Les modèles, l'environnement Python et les générations sont conservés."
fi