#!/bin/bash
# deploy-compose.sh — Docker Compose deploy script for homelab
#
# Usage: deploy-compose.sh <host> [action] [--dry-run] [--service <name>]
#
# Actions:
#   up       Pull latest images and start services (default)
#   down     Stop and remove containers
#   restart  Restart running containers
#   logs     Tail container logs (last 100 lines, follow)
#   pull     Pull latest images only
#   ps       Show container status
#
# Flags:
#   --dry-run          Print resolved compose config; do not touch containers
#   --service <name>   Scope action to a single service
#
# Environment variables:
#   HOMELAB_ENV_FILE   Override path to .env file (required for non-local hosts)
#   HEALTH_TIMEOUT     Seconds to wait for healthy containers after 'up' (default: 120)

set -euo pipefail

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# === Helpers ===
info()  { echo -e "${GREEN}[deploy-compose]${NC} $*"; }
warn()  { echo -e "${YELLOW}[deploy-compose] WARNING:${NC} $*" >&2; }
error() { echo -e "${RED}[deploy-compose] ERROR:${NC} $*" >&2; exit 1; }

# === Prerequisites ===
command -v yq    &>/dev/null || error "yq is required but not found. Install via: https://github.com/mikefarah/yq"
command -v docker &>/dev/null || error "docker is required but not found."

# === Argument parsing ===
HOST=""
ACTION="up"
DRY_RUN=false
SERVICE_FILTER=""

# First positional arg is the host (if not a flag)
if [[ $# -ge 1 && "$1" != --* ]]; then
  HOST="$1"; shift
fi

# Remaining: optional action + flags (any order)
while [[ $# -gt 0 ]]; do
  case "$1" in
    up|down|restart|logs|pull|ps)
      ACTION="$1"; shift ;;
    --dry-run)
      DRY_RUN=true; shift ;;
    --service)
      [[ $# -ge 2 ]] || error "--service requires an argument"
      SERVICE_FILTER="$2"; shift 2 ;;
    -h|--help)
      sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
      exit 0 ;;
    *)
      error "Unknown argument: '$1'. Run with --help for usage." ;;
  esac
done

[[ -n "$HOST" ]] || error "Missing required argument: <host>. Usage: $0 <local|vps> [action] [--dry-run] [--service <name>]"

case "$HOST" in
  local|vps) ;;
  *) error "Unknown host '$HOST'. Valid hosts: local, vps" ;;
esac

# === Script and repo root resolution ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
COMPOSE_ROOT="${REPO_ROOT}/applications/compose"

# === Env file resolution ===
ENV_FILE="${HOMELAB_ENV_FILE:-}"
if [[ -z "$ENV_FILE" ]]; then
  if [[ "$HOST" == "local" ]]; then
    ENV_FILE="${COMPOSE_ROOT}/environments/local/.env"
  else
    error "HOMELAB_ENV_FILE must be set for host '$HOST'.\nExample: export HOMELAB_ENV_FILE=/path/to/secrets/vps.env"
  fi
fi

[[ -f "$ENV_FILE" ]] || error "Env file not found: $ENV_FILE"

# Security check — applies to ALL hosts
PERMS=$(stat -c "%a" "$ENV_FILE")
if [[ "$PERMS" != "400" && "$PERMS" != "600" ]]; then
  warn "Permissions on '$ENV_FILE' are $PERMS (too open). Recommended: 600.\n       Run: chmod 600 '$ENV_FILE'"
fi

# === Compose file assembly (array — safe with any path) ===
SERVICES_YAML="${COMPOSE_ROOT}/environments/${HOST}/services.yaml"
[[ -f "$SERVICES_YAML" ]] || error "Services file not found: $SERVICES_YAML"

mapfile -t SERVICES < <(yq -r '.services[]' "$SERVICES_YAML")
[[ ${#SERVICES[@]} -gt 0 ]] || error "No services found in $SERVICES_YAML"

COMPOSE_FILES=()
for S in "${SERVICES[@]}"; do
  BASE_FILE="${COMPOSE_ROOT}/base/${S}/compose.yaml"
  [[ -f "$BASE_FILE" ]] || error "Base compose file not found for service '$S': $BASE_FILE"
  COMPOSE_FILES+=("-f" "$BASE_FILE")
done
COMPOSE_FILES+=("-f" "${COMPOSE_ROOT}/environments/${HOST}/docker-compose.yaml")

# Convenience wrapper — all compose calls go through here
run_compose() {
  docker compose "${COMPOSE_FILES[@]}" --env-file "$ENV_FILE" "$@"
}

# Service filter: populated only when --service is given
SVC_ARGS=()
[[ -n "$SERVICE_FILTER" ]] && SVC_ARGS=("$SERVICE_FILTER")

# === Dry-run ===
if $DRY_RUN; then
  info "DRY RUN — resolved compose config for host: $HOST"
  info "Compose files: ${COMPOSE_FILES[*]}"
  info "Env file: $ENV_FILE"
  echo ""
  run_compose config
  exit 0
fi

# === Main dispatch ===
info "Host: $HOST | Action: $ACTION${SERVICE_FILTER:+ | Service: $SERVICE_FILTER}"

case "$ACTION" in
  up)
    info "Pulling latest images..."
    run_compose pull "${SVC_ARGS[@]}"

    info "Bringing up services..."
    run_compose up -d "${SVC_ARGS[@]}"

    # Post-deploy health check
    # Only fails for containers that HAVE a healthcheck defined and go unhealthy.
    # Containers with no healthcheck (health=none) are skipped — they're healthy by definition.
    HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-120}"
    info "Waiting up to ${HEALTH_TIMEOUT}s for containers to become healthy..."
    DEADLINE=$(( $(date +%s) + HEALTH_TIMEOUT ))
    FAILED_CONTAINERS=()

    while true; do
      STILL_STARTING=()
      FAILED_CONTAINERS=()

      while IFS= read -r CID; do
        [[ -z "$CID" ]] && continue
        HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "$CID" 2>/dev/null || echo "unknown")
        NAME=$(docker inspect --format='{{.Name}}' "$CID" 2>/dev/null | sed 's|^/||' || echo "$CID")
        case "$HEALTH" in
          healthy|none)
            ;;
          starting)
            STILL_STARTING+=("$NAME")
            ;;
          unhealthy)
            FAILED_CONTAINERS+=("$NAME")
            ;;
        esac
      done < <(run_compose ps -q "${SVC_ARGS[@]}" 2>/dev/null)

      if [[ ${#STILL_STARTING[@]} -eq 0 && ${#FAILED_CONTAINERS[@]} -eq 0 ]]; then
        info "All containers healthy."
        break
      fi

      if [[ $(date +%s) -ge $DEADLINE ]]; then
        if [[ ${#FAILED_CONTAINERS[@]} -gt 0 ]]; then
          error "Health check failed after ${HEALTH_TIMEOUT}s. Unhealthy containers: ${FAILED_CONTAINERS[*]}"
        else
          warn "Health timeout after ${HEALTH_TIMEOUT}s. Still starting: ${STILL_STARTING[*]}. Check logs with: $0 $HOST logs"
        fi
        break
      fi

      sleep 5
    done

    info "Deployment complete."
    run_compose ps "${SVC_ARGS[@]}"
    ;;

  down)
    info "Bringing down services..."
    run_compose down "${SVC_ARGS[@]}"
    ;;

  restart)
    info "Restarting services..."
    run_compose restart "${SVC_ARGS[@]}"
    ;;

  logs)
    run_compose logs -f --tail=100 "${SVC_ARGS[@]}"
    ;;

  pull)
    info "Pulling latest images..."
    run_compose pull "${SVC_ARGS[@]}"
    ;;

  ps)
    run_compose ps "${SVC_ARGS[@]}"
    ;;
esac
