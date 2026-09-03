#!/usr/bin/env bash

set -euo pipefail

EXPECTED_CONTEXT="${K8S_LOCAL_CONTEXT:-k3s-local}"
KUBECONFIG_PATH="${K8S_LOCAL_KUBECONFIG:-${HOME}/.kube/config}"
export KUBECONFIG="$KUBECONFIG_PATH"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Erreur : la commande '$1' est introuvable." >&2
    exit 1
  fi
}

load_json_config() {
  local config_file="$1"
  shift

  if [[ ! -f "$config_file" ]]; then
    return 0
  fi

  require_command jq
  if ! jq -e 'type == "object"' "$config_file" >/dev/null; then
    echo "Erreur : configuration JSON invalide : $config_file" >&2
    exit 1
  fi

  local mapping json_key variable_name value
  for mapping in "$@"; do
    json_key="${mapping%%=*}"
    variable_name="${mapping#*=}"

    if [[ -n "${!variable_name:-}" ]]; then
      continue
    fi

    if jq -e --arg key "$json_key" 'has($key)' "$config_file" >/dev/null; then
      value="$(jq -er --arg key "$json_key" '.[$key] | if type == "string" or type == "number" or type == "boolean" then tostring else error("invalid value") end' "$config_file")"
      printf -v "$variable_name" '%s' "$value"
      export "$variable_name"
    fi
  done
}

require_local_port() {
  local port="$1"
  local setting_name="$2"

  if [[ ! "$port" =~ ^[0-9]+$ ]] || (( port < 1 || port > 65535 )); then
    echo "Erreur : '$setting_name' doit être un port compris entre 1 et 65535 (valeur reçue : $port)." >&2
    exit 1
  fi
}

check_cluster() {
  require_command kubectl

  if [[ ! -f "$KUBECONFIG" ]]; then
    echo "Erreur : kubeconfig local introuvable : $KUBECONFIG" >&2
    exit 1
  fi

  local current_context
  current_context="$(kubectl config current-context 2>/dev/null || true)"
  if [[ "$current_context" != "$EXPECTED_CONTEXT" ]]; then
    echo "Erreur : contexte '$current_context' refusé. Contexte local attendu : '$EXPECTED_CONTEXT'." >&2
    echo "Kubeconfig utilisé : $KUBECONFIG" >&2
    exit 1
  fi

  local cluster_server
  cluster_server="$(kubectl config view --minify --raw -o jsonpath='{.clusters[0].cluster.server}')"
  if [[ ! "$cluster_server" =~ ^https?://(127\.0\.0\.1|localhost)(:|/|$) ]]; then
    echo "Erreur : API Kubernetes non locale refusée : $cluster_server" >&2
    exit 1
  fi

  if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "Erreur : cluster local inaccessible avec le kubeconfig $KUBECONFIG." >&2
    exit 1
  fi

  echo "Kubeconfig Kubernetes : $KUBECONFIG"
  echo "Contexte Kubernetes   : $current_context"
  echo "API Kubernetes locale : $cluster_server"
}

ensure_namespace() {
  local namespace="$1"

  kubectl create namespace "$namespace" --dry-run=client -o yaml | kubectl apply -f -
  kubectl label namespace "$namespace" app.kubernetes.io/managed-by=k8s-local --overwrite
}

delete_namespace() {
  kubectl delete namespace "$1" --ignore-not-found --wait=true
}