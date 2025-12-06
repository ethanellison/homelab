#!/bin/bash
set -euo pipefail
# Ensure yq is installed
if ! command -v yq &>/dev/null; then
  echo "yq is required but not found. Please install yq." >&2
  exit 1
fi

HOST="$1"

if [ -z "$HOST" ]; then
  echo "Usage: ./deploy.sh <local|vps> [up|down]"
  exit 1
fi

ROOT="$(dirname "$0")/../../applications/compose"
cd "$ROOT"

SERVICES=$(yq -r '.services[]' "environments/$HOST/services.yaml")

FILES=""
for S in $SERVICES; do
  FILES="$FILES -f base/$S/compose.yaml"
done

FILES="$FILES -f environments/$HOST/docker-compose.yaml"

echo "Deploying to host: $HOST"
echo "Compose files: $FILES"

ACTION="${2:-up}"

if [ "$ACTION" = "down" ]; then
  echo "Bringing down deployment for host: $HOST"
  set -x
  docker compose $FILES --env-file environments/$HOST/.env down
  exit 0
fi

set -x
docker compose $FILES --env-file environments/$HOST/.env pull
docker compose $FILES --env-file environments/$HOST/.env up -d
