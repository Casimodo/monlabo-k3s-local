#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/common.sh"

check_cluster

if [[ "${1:-}" == "--all" ]]; then
  echo "Ce mode supprime tous les namespaces utilisateur et les ressources du namespace default."
  read -r -p "Saisissez RESET pour confirmer : " confirmation
  if [[ "$confirmation" != "RESET" ]]; then
    echo "Annulé."
    exit 0
  fi

  reset_all=true
else
  reset_all=false
fi

if [[ $# -gt 0 && "${1:-}" != "--all" ]]; then
  echo "Usage : $0 [--all]" >&2
  exit 1
fi

protected_namespace() {
  case "$1" in
    default|kube-system|kube-public|kube-node-lease|local-path-storage)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

if [[ "$reset_all" == true ]]; then
  mapfile_command=(kubectl get namespaces -o 'jsonpath={range .items[*]}{.metadata.name}{"\n"}{end}')
else
  mapfile_command=(kubectl get namespaces -l app.kubernetes.io/managed-by=k8s-local -o 'jsonpath={range .items[*]}{.metadata.name}{"\n"}{end}')
fi

while IFS= read -r namespace; do
  if [[ -n "$namespace" ]] && ! protected_namespace "$namespace"; then
    delete_namespace "$namespace"
  fi
done < <("${mapfile_command[@]}")

if [[ "$reset_all" == true ]]; then
  kubectl delete all,configmap,secret,pvc,serviceaccount,ingress,job,cronjob \
    --all -n default --ignore-not-found
fi

if command -v docker >/dev/null 2>&1; then
  docker_endpoint="$(docker context inspect --format '{{.Endpoints.docker.Host}}' 2>/dev/null || true)"
  if [[ "$docker_endpoint" =~ ^(unix|npipe):// ]] && docker info >/dev/null 2>&1; then
    while IFS= read -r container_id; do
      if [[ -n "$container_id" ]]; then
        docker rm --force "$container_id" >/dev/null
      fi
    done < <(docker ps --all --quiet --filter label=app.kubernetes.io/managed-by=k8s-local)
  fi
fi
