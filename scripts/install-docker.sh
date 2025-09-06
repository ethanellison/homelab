#!/usr/bin/env bash
set -e

# === Colors for output ===
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Docker + Portainer Installer/Updater for Raspberry Pi (Raspbian) ===${NC}"

# === Ensure root ===
if [[ $EUID -ne 0 ]]; then
  echo -e "${YELLOW}This script must be run as root (use sudo)${NC}"
  exit 1
fi

# === Detect OS and architecture ===
OS_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
ARCH="$(dpkg --print-architecture)"

echo "Detected OS codename: $OS_CODENAME"
echo "Detected architecture: $ARCH"

# === Docker functions ===
install_docker() {
  echo -e "${GREEN}Installing Docker...${NC}"
  apt-get update
  apt-get install -y ca-certificates curl gnupg lsb-release

  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

  echo \
    "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      ${OS_CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null

  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

upgrade_docker() {
  echo -e "${GREEN}Upgrading Docker to latest version...${NC}"
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# === Portainer functions ===
install_portainer() {
  echo -e "${GREEN}Installing Portainer...${NC}"
  docker volume create portainer_data
  docker run -d \
    -p 8000:8000 -p 9443:9443 -p 9000:9000 \
    --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v portainer_data:/data \
    portainer/portainer-ce:latest
}

upgrade_portainer() {
  echo -e "${GREEN}Upgrading Portainer to latest version...${NC}"
  docker pull portainer/portainer-ce:latest
  docker stop portainer || true
  docker rm portainer || true
  install_portainer
}

# === Main Docker logic ===
if command -v docker &>/dev/null; then
  echo -e "${YELLOW}Docker is already installed. Upgrading...${NC}"
  upgrade_docker
else
  install_docker
fi

systemctl enable docker
systemctl start docker

# === Main Portainer logic ===
if docker ps -a --format '{{.Names}}' | grep -q '^portainer$'; then
  echo -e "${YELLOW}Portainer is already installed. Upgrading...${NC}"
  upgrade_portainer
else
  install_portainer
fi

echo -e "${GREEN}Installation/upgrade complete.${NC}"
docker --version
echo -e "${GREEN}Portainer is available at:${NC} https://<ip>:9443"
