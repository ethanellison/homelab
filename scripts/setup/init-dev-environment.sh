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
    print_usage() {
        cat <<EOF
Usage: $0 [options...]

Positional commands:
  docker        Install or upgrade Docker (installs if not present, upgrades if present)
  dev-tools     Install development tools (k3d, kubectl, helm, argocd)
  kube          Setup Kubernetes dev environment (k3d cluster, ArgoCD)
  portainer     Install/Upgrade Portainer

Long options:
  --install-docker     Install Docker
  --upgrade-docker     Upgrade Docker
  --dev-tools          Install development tools
  --setup-env          Setup development environment
  --install-portainer  Install/Upgrade Portainer
  --all                Run all steps (install/upgrade docker, dev tools, setup env, portainer)
  --help, -h           Show this help
EOF
    }


    detect_system

    DO_INSTALL_DOCKER=0
    DO_UPGRADE_DOCKER=0
    DO_DEV_TOOLS=0
    DO_SETUP_ENV=0
    DO_PORTAINER=0
    DO_ALL=0

    if [[ $# -eq 0 ]]; then
        print_warning "No arguments provided. Exiting (non-interactive mode)."
        print_usage
        exit 1
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            docker)
                if command -v docker &>/dev/null; then
                    DO_UPGRADE_DOCKER=1
                else
                    DO_INSTALL_DOCKER=1
                fi
                ;;
            dev-tools|--dev-tools)
                DO_DEV_TOOLS=1
                ;;
            kube|--setup-env)
                DO_SETUP_ENV=1
                ;;
            portainer|--install-portainer)
                DO_PORTAINER=1
                ;;
            --install-docker)
                DO_INSTALL_DOCKER=1
                ;;
            --upgrade-docker)
                DO_UPGRADE_DOCKER=1
                ;;
            --all|all)
                DO_ALL=1
                ;;
            --help|-h)
                print_usage
                exit 0
                ;;
            *)
                print_warning "Unknown option/command: $1"
                print_usage
                exit 2
                ;;
        esac
        shift
    done


    # If --all selected, set individual flags
    if [[ $DO_ALL -eq 1 ]]; then
        if command -v docker &>/dev/null; then
            DO_UPGRADE_DOCKER=1
        else
            DO_INSTALL_DOCKER=1
        fi
        DO_DEV_TOOLS=1
        DO_SETUP_ENV=1
        DO_PORTAINER=1
    fi

    # Docker actions
    if [[ $DO_INSTALL_DOCKER -eq 1 || $DO_UPGRADE_DOCKER -eq 1 ]]; then
        if [[ $DO_INSTALL_DOCKER -eq 1 ]]; then
            install_docker
        else
            upgrade_docker
        fi

        # Try to enable and start docker if systemctl is available
        if command -v systemctl &>/dev/null; then
            systemctl enable docker || print_warning "systemctl enable docker failed"
            systemctl start docker || print_warning "systemctl start docker failed"
        else
            print_warning "systemctl not available; please ensure Docker is started manually"
        fi
    fi

    # Development tools
    if [[ $DO_DEV_TOOLS -eq 1 ]]; then
        install_dev_tools
    fi

    # Portainer
    if [[ $DO_PORTAINER -eq 1 ]]; then
        print_message "Setting up Portainer"
        /bin/bash "$(dirname "$0")/install-portainer.sh"
    fi

    # Setup development environment
    if [[ $DO_SETUP_ENV -eq 1 ]]; then
        setup_dev_environment
    fi

    print_message "Requested operations complete"

    # Show versions for installed tools (ignore errors)
    if command -v docker &>/dev/null; then docker --version || true; fi
    if command -v kubectl &>/dev/null; then kubectl version --client --short || true; fi
    if command -v helm &>/dev/null; then helm version --short || true; fi
    if command -v argocd &>/dev/null; then argocd version --client || true; fi
}

main "$@"