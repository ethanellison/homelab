#!/bin/bash
set -euo pipefail

REPO_PATH="$(pwd)"
STACK_FILE="$REPO_PATH/applications/docker-compose-apps/docker-compose.yaml"
STACK_NAME="$(basename "$REPO_PATH/application/docker-compose-apps")" # use repo folder name as stack name

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

  if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo "[INFO] Pulling new changes..."
    git pull --rebase
  else
    echo "[INFO] Repo already up to date."
  fi
else
  echo "[WARN] $REPO_PATH is not a Git repo. Skipping git pull."
fi

# source relevant env configurations
set -o allexport
source "/etc/n8n.env"
set +o allexport
# === DEPLOY STACK WITH DOCKER COMPOSE ===
echo "[INFO] Deploying stack '$STACK_NAME' using docker-compose..."
docker compose -f "$STACK_FILE" up -d --build

echo "[INFO] Stack '$STACK_NAME' deployed successfully."
