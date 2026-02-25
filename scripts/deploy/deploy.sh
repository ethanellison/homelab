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
  local deploy_script="${SCRIPT_DIR}/deploy-compose.sh"

  if [ ! -f "$deploy_script" ]; then
    print_warning "deploy-compose.sh not found at: ${deploy_script}"
    exit 1
  fi

  if [ -z "${HOMELAB_ENV_FILE:-}" ] && [ "$ENVIRONMENT" = "local" ]; then
    export HOMELAB_ENV_FILE="${REPO_ROOT}/applications/compose/environments/local/.env"
  fi

  print_message "Deploying Docker Compose services for environment: ${ENVIRONMENT}"
  bash "$deploy_script" "$ENVIRONMENT" up
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

