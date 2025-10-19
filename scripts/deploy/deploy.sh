#!/bin/bash
set -euo pipefail

# === Colors for output ===
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# === Variables ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ENVIRONMENT="${1:-}"
DEPLOYMENT_TYPE="${2:-}"

# === Functions ===
print_usage() {
  echo "Usage: $0 <environment> <type>"
  echo "Environment:"
  echo "  - local"
  echo "  - staging"
  echo "  - production"
  echo "Type:"
  echo "  - compose"
  echo "  - kubernetes"
  exit 1
}

print_message() {
  echo -e "${GREEN}=== $1 ===${NC}"
}

print_warning() {
  echo -e "${YELLOW}$1${NC}"
}

validate_environment() {
  case "$ENVIRONMENT" in
  local | staging | production | vps) ;;
  *)
    print_warning "Invalid environment: ${ENVIRONMENT}"
    print_usage
    ;;
  esac
}

validate_deployment_type() {
  case "$DEPLOYMENT_TYPE" in
  compose | kubernetes) ;;
  *)
    print_warning "Invalid deployment type: ${DEPLOYMENT_TYPE}"
    print_usage
    ;;
  esac
}

deploy_compose() {
  local env_path="${REPO_ROOT}/applications/compose/environments/${ENVIRONMENT}"
  local compose_file="${env_path}/docker-compose.yaml"
  local env_file="${env_path}/.env"

  if [ ! -f "$compose_file" ]; then
    print_warning "No docker-compose.yaml found for environment: ${ENVIRONMENT}"
    exit 1
  fi

  # Load environment variables if they exist
  if [ -f "$env_file" ]; then
    print_message "Loading environment variables from ${env_file}"
    set -o allexport
    source "$env_file"
    set +o allexport
  fi

  print_message "Deploying Docker Compose services for environment: ${ENVIRONMENT}"
  docker compose -f "$compose_file" pull
  docker compose -f "$compose_file" up -d --remove-orphans

  print_message "Verifying deployment"
  docker compose -f "$compose_file" ps
}

deploy_kubernetes() {
  local overlay_path="${REPO_ROOT}/applications/kubernetes/overlays/${ENVIRONMENT}"

  if [ ! -d "$overlay_path" ]; then
    print_warning "No Kubernetes overlay found for environment: ${ENVIRONMENT}"
    exit 1
  fi

  print_message "Deploying Kubernetes applications for environment: ${ENVIRONMENT}"

  # Apply infrastructure first
  print_message "Deploying infrastructure"
  kubectl apply -k "${REPO_ROOT}/infrastructure/kubernetes/overlays/${ENVIRONMENT}"

  # Wait for infrastructure to be ready
  print_message "Waiting for infrastructure to be ready"
  kubectl wait --for=condition=available --timeout=300s -n argocd deployment/argocd-server || true

  # Deploy applications
  print_message "Deploying applications"
  kubectl apply -k "$overlay_path"

  print_message "Verifying deployment"
  kubectl get pods -A
}

# === Main ===
if [ $# -lt 2 ]; then
  print_usage
fi

validate_environment
validate_deployment_type

case "$DEPLOYMENT_TYPE" in
compose)
  deploy_compose
  ;;
kubernetes)
  deploy_kubernetes
  ;;
esac

print_message "Deployment completed successfully"

