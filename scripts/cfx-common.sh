#!/usr/bin/env bash

set -euo pipefail

require_local_docker() {
  require_command docker

  local docker_endpoint
  docker_endpoint="$(docker context inspect --format '{{.Endpoints.docker.Host}}' 2>/dev/null || true)"
  if [[ ! "$docker_endpoint" =~ ^(unix|npipe):// ]]; then
    echo "Erreur : contexte Docker distant refusé : $docker_endpoint" >&2
    exit 1
  fi

  if ! docker info >/dev/null 2>&1; then
    echo "Erreur : moteur Docker local inaccessible." >&2
    exit 1
  fi
}

deploy_cfx() {
  local module_dir="$1"
  local profile="$2"
  local default_port="$3"
  local local_port="${CFX_LOCAL_PORT:-$default_port}"
  local image="k8s-local/$profile:local"
  local container="k8s-local-$profile"
  local root_dir
  root_dir="$(cd "$module_dir/.." && pwd)"

  require_local_port "$local_port" localPort

  if [[ -z "${CFX_SERVER_DOWNLOAD_URL:-}" || "$CFX_SERVER_DOWNLOAD_URL" == *CHANGE_ME* ]]; then
    echo "Erreur : renseignez serverDownloadUrl dans $module_dir/.env.json." >&2
    echo "Créez ce fichier depuis $module_dir/.env-temp.json." >&2
    echo "Copiez l'URL Linux recommandée depuis https://docs.fivem.net/docs/server-download/" >&2
    exit 1
  fi

  require_local_docker

  docker build --platform linux/amd64 \
    --build-arg "CFX_SERVER_DOWNLOAD_URL=$CFX_SERVER_DOWNLOAD_URL" \
    --tag "$image" \
    --file "$root_dir/scripts/cfx/Dockerfile" \
    "$root_dir/scripts/cfx"

  docker rm --force "$container" >/dev/null 2>&1 || true

  local run_args=(
    --detach
    --name "$container"
    --label app.kubernetes.io/managed-by=k8s-local
    --platform linux/amd64
    --restart unless-stopped
    --publish "127.0.0.1:$local_port:30120/tcp"
    --publish "127.0.0.1:$local_port:30120/udp"
    --volume "$module_dir/server-data:/server-data"
  )
  local server_args=(+exec server.cfg)
  if [[ -n "${CFX_LICENSE_KEY:-}" ]]; then
    server_args+=(+set sv_licenseKey "$CFX_LICENSE_KEY")
  fi

  docker run "${run_args[@]}" "$image" "${server_args[@]}" >/dev/null

  echo "$profile est démarré sur 127.0.0.1:$local_port (TCP et UDP)."
  echo "Logs : $module_dir/connect.sh"
}

connect_cfx() {
  local profile="$1"
  local default_port="$2"
  local local_port="${CFX_LOCAL_PORT:-$default_port}"

  require_local_port "$local_port" localPort
  require_local_docker
  echo "Connexion client : connect 127.0.0.1:$local_port"
  echo "API locale       : http://127.0.0.1:$local_port/info.json"
  echo "Arrêt des logs   : Ctrl+C"
  docker logs --follow "k8s-local-$profile"
}

restart_cfx() {
  require_local_docker
  docker restart "k8s-local-$1"
}

delete_cfx() {
  require_local_docker
  docker rm --force "k8s-local-$1" >/dev/null 2>&1 || true
  echo "Serveur supprimé. Les sources locales dans server-data sont conservées."
}