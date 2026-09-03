#!/usr/bin/env bash

set -euo pipefail

if [[ -x /opt/cfx/run.sh ]]; then
  exec /opt/cfx/run.sh "$@"
fi

if [[ -x /opt/cfx/cfx-server ]]; then
  exec /opt/cfx/cfx-server "$@"
fi

if [[ -x /opt/cfx/FXServer ]]; then
  exec /opt/cfx/FXServer "$@"
fi

echo "Erreur : exécutable Cfx introuvable dans l'artefact." >&2
exit 1