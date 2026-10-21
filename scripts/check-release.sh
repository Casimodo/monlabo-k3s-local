#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "$ROOT_DIR/VERSION" || ! -s "$ROOT_DIR/RELEASE.md" ]]; then
  echo "VERSION et RELEASE.md sont requis pour publier une release." >&2
  exit 1
fi

VERSION="$(cat "$ROOT_DIR/VERSION")"
if [[ ! "$VERSION" =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]] || [[ "$(wc -l < "$ROOT_DIR/VERSION" | tr -d ' ')" != "1" ]]; then
  echo "VERSION doit contenir une seule ligne X.Y.Z terminee par un saut de ligne." >&2
  exit 1
fi

IFS= read -r RELEASE_TITLE < "$ROOT_DIR/RELEASE.md"
if [[ "$RELEASE_TITLE" != "# v$VERSION" ]]; then
  echo "Le titre de RELEASE.md doit correspondre a VERSION." >&2
  exit 1
fi

echo "Release v$VERSION valide."