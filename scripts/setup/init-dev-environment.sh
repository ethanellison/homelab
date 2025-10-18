#!/usr/bin/env bash
set -e

# === Colors for output ===
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# === Function to print messages ===
print_message() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

# === Check Root ===
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_warning "This script must be run as root (use sudo)"
        exit 1
    fi
}

# === Detect OS and architecture ===
detect_system() {
    OS_CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    ARCH="$(dpkg --print-architecture)"
    
    echo "Detected OS codename: $OS_CODENAME"
    echo "Detected architecture: $ARCH"
}

# === Docker Installation ===
install_docker() {
    print_message "Installing Docker"
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
    print_message "Upgrading Docker to latest version"
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

# === Development Tools Installation ===
install_dev_tools() {
    print_message "Installing development tools"
    
    # Install k3d
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
    
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    mv kubectl /usr/local/bin/
    
    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    
    # Install ArgoCD CLI
    curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
    install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
    rm argocd-linux-amd64
}

# === Development Environment Setup ===
setup_dev_environment() {
    print_message "Setting up development environment"
    
    # Create k3d cluster if it doesn't exist
    if ! k3d cluster list | grep -q "dev-cluster"; then
        print_message "Creating k3d cluster"
        k3d cluster create dev-cluster
    else
        print_warning "k3d cluster 'dev-cluster' already exists"
    fi
    
    # Install ArgoCD
    print_message "Installing ArgoCD"
    kubectl create namespace argocd 2>/dev/null || true
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for ArgoCD server
    print_message "Waiting for ArgoCD server to be ready"
    kubectl wait --namespace argocd --for=condition=available --timeout=600s deployment/argocd-server
    
    # Get ArgoCD password
    print_message "ArgoCD admin password:"
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    echo
}

# === Main Script ===
main() {
    check_root
    detect_system
    
    # Install or upgrade Docker
    if command -v docker &>/dev/null; then
        upgrade_docker
    else
        install_docker
    fi
    
    systemctl enable docker
    systemctl start docker
    
    # Install development tools
    install_dev_tools
    
    # Setup development environment
    setup_dev_environment
    
    print_message "Installation complete"
    docker --version
    kubectl version --client
    helm version
    argocd version --client
}

main "$@"