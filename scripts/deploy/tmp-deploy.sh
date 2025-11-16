#!/bin/bash
set -euo pipefail
# Ensure yq is installed
if ! command -v yq &>/dev/null; then
  echo "yq is required but not found. Please install yq." >&2
  exit 1
fi

HOST="$1"

if [ -z "$HOST" ]; then
  echo "Usage: ./deploy.sh <pi|vps>"
  exit 1
fi

ROOT="$(dirname "$0")/.."
cd "$ROOT"

SERVICES=$(yq '.services[]' "hosts/$HOST/services.yaml")

FILES=""
for S in $SERVICES; do
  FILES="$FILES -f services/$S/compose.yaml"
done

FILES="$FILES -f hosts/$HOST/compose.yaml"

echo "Deploying to host: $HOST"
echo "Compose files: $FILES"

set -x
docker compose $FILES --env-file hosts/$HOST/.env pull
docker compose $FILES --env-file hosts/$HOST/.env up -d
