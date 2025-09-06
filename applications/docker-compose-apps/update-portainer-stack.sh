#!/bin/bash
set -euo pipefail

# === CONFIGURATION ===
PORTAINER_URL="${PORTAINER_URL:-http://127.0.0.1:9000}"
PORTAINER_API_KEY="${PORTAINER_API_KEY:?Missing PORTAINER_API_KEY env variable}"
ENDPOINT_ID="${ENDPOINT_ID:-1}"

# === DYNAMIC PATHS ===
# Detect repo path as current working directory
REPO_PATH="$(pwd)"
STACK_FILE="$REPO_PATH/docker-compose.yaml"
STACK_NAME="$(basename "$REPO_PATH")" # use repo folder name as stack name

if [ ! -f "$STACK_FILE" ]; then
  echo "[ERROR] No docker-compose.yml found in $REPO_PATH"
  exit 1
fi

# === UPDATE REPO ===
if [ -d "$REPO_PATH/.git" ]; then
  echo "[INFO] Fetching latest changes from Git..."
  cd "$REPO_PATH"
  git fetch origin
  LOCAL_HASH=$(git rev-parse HEAD)
  REMOTE_HASH=$(git rev-parse @{u})

else
  echo "[WARN] $REPO_PATH is not a Git repo. Skipping git pull."
  LOCAL_HASH="x"
  REMOTE_HASH="y"
fi

# === PREPARE STACK FILE CONTENT ===
STACK_CONTENT=$(<"$STACK_FILE")
STACK_CONTENT_JSON=$(jq -Rs . <<<"$STACK_CONTENT")

# === CHECK IF STACK EXISTS ===
echo "[INFO] Checking if stack '$STACK_NAME' exists in Portainer..."
STACK_ID=$(curl -s \
  -H "x-api-key: $PORTAINER_API_KEY" \
  "$PORTAINER_URL/api/stacks" | jq -r ".[] | select(.Name==\"$STACK_NAME\") | .Id")

if [ -n "$STACK_ID" ] && [ "$STACK_ID" != "null" ]; then
  echo "[INFO] Stack exists (ID=$STACK_ID). Updating..."
  curl -s -X PUT \
    "$PORTAINER_URL/api/stacks/$STACK_ID?endpointId=$ENDPOINT_ID" \
    -H "x-api-key: $PORTAINER_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{
          \"StackFileContent\": $STACK_CONTENT_JSON,
          \"Prune\": true
        }" >/dev/null
  echo "[INFO] Stack '$STACK_NAME' updated successfully."
else
  echo "[INFO] Stack not found. Creating..."
  curl -s -X POST \
    "$PORTAINER_URL/api/stacks/create/standalone/file?endpointId=$ENDPOINT_ID" \
    -H "x-api-key: $PORTAINER_API_KEY" \
    -F "Name=$STACK_NAME" \
    -F "file=@$STACK_FILE" \
    -F 'Env=[]' |
    jq '.'
  echo "[INFO] Stack '$STACK_NAME' created successfully."
fi
