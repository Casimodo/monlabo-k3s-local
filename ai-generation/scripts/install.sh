#!/usr/bin/env bash

set -euo pipefail

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$MODULE_DIR/.venv"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Erreur : AI Generation nécessite macOS." >&2
  exit 1
fi

if [[ "$(uname -m)" != "arm64" ]]; then
  echo "Erreur : une puce Apple Silicon est requise." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Erreur : Python 3 est introuvable." >&2
  exit 1
fi

python_version="$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')"
if ! python3 -c 'import sys; raise SystemExit(sys.version_info < (3, 10))'; then
  echo "Erreur : Python 3.10 ou supérieur est requis (version actuelle : $python_version)." >&2
  exit 1
fi

if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/python" -m pip install --upgrade pip
"$VENV_DIR/bin/python" -m pip install -r "$MODULE_DIR/server/requirements.txt"

mkdir -p "$MODULE_DIR/outputs/images" "$MODULE_DIR/outputs/videos" "$MODULE_DIR/.runtime"

echo "Environnement AI Generation prêt avec Python $python_version."
echo "Le modèle sera téléchargé lors de la première génération."