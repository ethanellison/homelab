#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

PORTAINER_IMAGE="portainer/portainer-ce:latest"
CONTAINER_NAME="portainer"
PORT="9000"

print_message "Installing/Upgrading Portainer"

# Pull the latest image
docker pull "${PORTAINER_IMAGE}"

# Check if the container already exists (running or stopped)
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    print_message "Portainer container found. Stopping and removing old container for upgrade..."
    
    # Stop and remove existing container
    docker stop "${CONTAINER_NAME}" || true
    docker rm "${CONTAINER_NAME}" || true
fi

print_message "Running new Portainer container..."

# Run the new container, mounting necessary volumes.
# We use 'portainer_data' named volume for persistence.
# Portainer is accessible on host port 9000
docker run -d \
    -p "${PORT}":"${PORT}" \
    --name "${CONTAINER_NAME}" \
    --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    "${PORTAINER_IMAGE}"

print_message "Portainer setup complete. Access at http://localhost:${PORT}"
