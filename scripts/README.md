# Scripts

This directory contains automation scripts for managing the homelab infrastructure.

## Directory Structure

```
scripts/
├── setup/                  # Setup and initialization scripts
│   └── init-dev-environment.sh  # Initial development environment setup
├── deploy/                 # Deployment scripts
│   └── deploy.sh          # Universal deployment script for both K8s and Compose
└── utils/                 # Utility scripts
    └── homelab-utils.sh   # Common utilities for maintenance
```

## Setup Scripts

### init-dev-environment.sh
Sets up the complete development environment:
- Installs/upgrades Docker
- Installs development tools (kubectl, helm, k3d, argocd)
- Creates local k3d cluster
- Sets up ArgoCD

Usage:
```bash
sudo ./scripts/setup/init-dev-environment.sh
```

## Deployment Scripts

### deploy.sh
Universal deployment script for both Kubernetes and Docker Compose environments.

Usage:
```bash
# Deploy Docker Compose services
./scripts/deploy/deploy.sh local compose
./scripts/deploy/deploy.sh production compose

# Deploy Kubernetes applications
./scripts/deploy/deploy.sh local kubernetes
./scripts/deploy/deploy.sh production kubernetes
```

## Utility Scripts

### homelab-utils.sh
Common utilities for maintaining the homelab environment:
- Prerequisite checking
- Service status verification
- Docker cleanup
- Volume backup/restore

Usage:
```bash
# Check prerequisites and service status
./scripts/utils/homelab-utils.sh check

# Clean unused Docker resources
./scripts/utils/homelab-utils.sh clean

# Backup Docker volumes
./scripts/utils/homelab-utils.sh backup /path/to/backup/dir

# Restore Docker volumes
./scripts/utils/homelab-utils.sh restore /path/to/backup/dir
```

## Best Practices

1. Always make scripts executable:
   ```bash
   chmod +x scripts/**/*.sh
   ```

2. Use the appropriate environment:
   ```bash
   # Development
   ./scripts/deploy/deploy.sh local compose

   # Production
   ./scripts/deploy/deploy.sh production compose
   ```

3. Regular maintenance:
   ```bash
   # Weekly cleanup
   ./scripts/utils/homelab-utils.sh clean

   # Regular backups
   ./scripts/utils/homelab-utils.sh backup /mnt/backup/homelab
   ```

## Adding New Scripts

1. Choose the appropriate directory:
   - `setup/` for initialization scripts
   - `deploy/` for deployment scripts
   - `utils/` for utility scripts

2. Follow the template:
   ```bash
   #!/bin/bash
   set -euo pipefail

   # === Variables ===
   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

   # === Functions ===
   main() {
       # Your code here
   }

   main "$@"
   ```

3. Make it executable:
   ```bash
   chmod +x scripts/category/your-script.sh
   ```

4. Update this README with usage instructions