#!/bin/bash
set -euo pipefail

# === Colors for output ===
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# === Variables ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# === Functions ===
print_message() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

check_prerequisites() {
    print_message "Checking prerequisites"
    
    # Check Docker
    if ! command -v docker &>/dev/null; then
        print_warning "Docker is not installed"
        exit 1
    fi
    
    # Check kubectl for Kubernetes deployments
    if ! command -v kubectl &>/dev/null; then
        print_warning "kubectl is not installed"
        exit 1
    fi
    
    # Check helm
    if ! command -v helm &>/dev/null; then
        print_warning "helm is not installed"
        exit 1
    fi
}

check_services() {
    print_message "Checking service status"
    
    # Check Docker service
    if ! systemctl is-active --quiet docker; then
        print_warning "Docker service is not running"
        exit 1
    fi
    
    # Check k3d cluster if exists
    if command -v k3d &>/dev/null; then
        if k3d cluster list 2>/dev/null | grep -q "dev-cluster"; then
            print_message "k3d cluster is running"
        else
            print_warning "k3d cluster is not running"
        fi
    fi
}

clean_docker() {
    print_message "Cleaning Docker resources"
    
    # Remove unused containers
    docker container prune -f
    
    # Remove unused images
    docker image prune -f
    
    # Remove unused volumes
    docker volume prune -f
    
    # Remove unused networks
    docker network prune -f
}

backup_volumes() {
    local backup_dir="${1:-/tmp/volume-backups}"
    print_message "Backing up Docker volumes to ${backup_dir}"
    
    mkdir -p "$backup_dir"
    
    # Get list of volumes
    docker volume ls --format "{{.Name}}" | while read -r volume; do
        print_message "Backing up volume: ${volume}"
        docker run --rm -v "${volume}:/source" -v "${backup_dir}:/backup" \
            alpine tar czf "/backup/${volume}.tar.gz" -C /source .
    done
}

restore_volumes() {
    local backup_dir="${1:-/tmp/volume-backups}"
    print_message "Restoring Docker volumes from ${backup_dir}"
    
    # Get list of backup files
    find "$backup_dir" -name "*.tar.gz" | while read -r backup_file; do
        local volume_name=$(basename "$backup_file" .tar.gz)
        print_message "Restoring volume: ${volume_name}"
        
        # Create volume if it doesn't exist
        docker volume create "$volume_name" >/dev/null
        
        # Restore data
        docker run --rm -v "${volume_name}:/target" -v "${backup_dir}:/backup" \
            alpine tar xzf "/backup/$(basename "$backup_file")" -C /target
    done
}

# === Main ===
case "${1:-}" in
    "check")
        check_prerequisites
        check_services
        ;;
    "clean")
        clean_docker
        ;;
    "backup")
        backup_volumes "${2:-}"
        ;;
    "restore")
        restore_volumes "${2:-}"
        ;;
    *)
        echo "Usage: $0 <command> [args]"
        echo "Commands:"
        echo "  check            - Check prerequisites and service status"
        echo "  clean            - Clean unused Docker resources"
        echo "  backup [dir]     - Backup Docker volumes"
        echo "  restore [dir]    - Restore Docker volumes"
        exit 1
        ;;
esac