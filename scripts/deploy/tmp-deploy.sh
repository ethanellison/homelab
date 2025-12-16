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

ENV_FILE="$HOMELAB_ENV_FILE"

if [ -z "$ENV_FILE" ]; then
  echo "Error: HOMELAB_ENV_FILE environment variable must be set to the absolute path of the environment file for $HOST." >&2
  echo "Example: export HOMELAB_ENV_FILE=/path/to/your/secrets/$HOST.env" >&2
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file not found at $ENV_FILE" >&2
  exit 1
fi

# Security Check: Ensure file is not group or world readable/writable.
# Permissions 400 (read-only for owner) or 600 (read/write for owner) are acceptable.
PERMS=$(stat -c "%a" "$ENV_FILE")
if [[ "$PERMS" != 400 ]] && [[ "$PERMS" != 600 ]]; then
  echo "Security Warning: Permissions for '$ENV_FILE' are too open ($PERMS). Recommended: 400 or 600." >&2
  echo "Run: chmod 600 '$ENV_FILE'" >&2
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
  docker compose $FILES --env-file "\$ENV_FILE" down
  exit 0
fi

set -x
docker compose $FILES --env-file "\$ENV_FILE" pull
docker compose $FILES --env-file "\$ENV_FILE" up -d
