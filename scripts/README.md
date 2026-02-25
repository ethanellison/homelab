# Scripts

This directory contains automation scripts for managing the homelab infrastructure.

## Directory Structure

```
scripts/
├── setup/                      # Setup and initialization scripts
│   └── init-dev-environment.sh # Initial development environment setup
├── deploy/                     # Deployment scripts
│   ├── deploy.sh               # Universal entry point (Compose + Kubernetes)
│   └── deploy-compose.sh       # Docker Compose deploy script
└── utils/                      # Utility scripts
    └── homelab-utils.sh        # Common utilities for maintenance
```

## Setup Scripts

### init-dev-environment.sh

Sets up the complete development environment:
- Installs/upgrades Docker
- Installs development tools (kubectl, helm, k3d, argocd)
- Creates local k3d cluster
- Sets up ArgoCD

```bash
sudo ./scripts/setup/init-dev-environment.sh
```

## Deployment Scripts

### deploy.sh

Universal entry point for both Kubernetes and Docker Compose environments. Delegates Compose deployments to `deploy-compose.sh`.

```bash
# Deploy Docker Compose services
./scripts/deploy/deploy.sh local compose
./scripts/deploy/deploy.sh vps compose

# Deploy Kubernetes applications
./scripts/deploy/deploy.sh local kubernetes
./scripts/deploy/deploy.sh production kubernetes
```

### deploy-compose.sh

Production-quality Docker Compose deploy script. Reads `environments/<host>/services.yaml` to assemble the correct set of base and environment-specific compose files, then performs the requested action.

**Usage:**

```bash
./scripts/deploy/deploy-compose.sh <host> [action] [--dry-run] [--service <name>]
```

**Hosts:** `local`, `vps`

**Actions:**

| Action | Description |
|--------|-------------|
| `up` | Pull latest images and start all services (default) |
| `down` | Stop and remove containers |
| `restart` | Restart running containers |
| `logs` | Tail container logs (last 100 lines, follow) |
| `pull` | Pull latest images only, do not start |
| `ps` | Show container status |

**Flags:**

| Flag | Description |
|------|-------------|
| `--dry-run` | Print the fully-resolved compose config; do not touch any containers |
| `--service <name>` | Scope the action to a single named service |

**Environment variables:**

| Variable | Description |
|----------|-------------|
| `HOMELAB_ENV_FILE` | Path to `.env` file. Required for non-`local` hosts. Falls back to `environments/local/.env` for local. |
| `HEALTH_TIMEOUT` | Seconds to wait for containers to become healthy after `up` (default: `120`) |

**Examples:**

```bash
# Standard deploy to local
./scripts/deploy/deploy-compose.sh local

# Deploy to VPS (env file must be set)
HOMELAB_ENV_FILE=/path/to/secrets/vps.env ./scripts/deploy/deploy-compose.sh vps

# Preview the fully-merged compose config without deploying
HOMELAB_ENV_FILE=/path/to/secrets/vps.env ./scripts/deploy/deploy-compose.sh vps --dry-run

# Restart a single service on VPS
HOMELAB_ENV_FILE=/path/to/secrets/vps.env ./scripts/deploy/deploy-compose.sh vps restart --service budget

# Tail logs for a specific service
HOMELAB_ENV_FILE=/path/to/secrets/vps.env ./scripts/deploy/deploy-compose.sh vps logs --service pocket-id

# Bring down all services on local
./scripts/deploy/deploy-compose.sh local down

# Deploy with extended health timeout for slow-starting services
HEALTH_TIMEOUT=300 ./scripts/deploy/deploy-compose.sh local up
```

## Utility Scripts

### homelab-utils.sh

Common utilities for maintaining the homelab environment:
- Prerequisite checking
- Service status verification
- Docker cleanup
- Volume backup/restore

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

2. Never commit `.env` files. Use `.env.example` as the template:
   ```bash
   cp applications/compose/environments/local/.env.example \
      applications/compose/environments/local/.env
   ```

3. For VPS deployments, set `HOMELAB_ENV_FILE` to the absolute path of your secrets file and ensure permissions are `600`:
   ```bash
   chmod 600 /path/to/secrets/vps.env
   export HOMELAB_ENV_FILE=/path/to/secrets/vps.env
   ./scripts/deploy/deploy-compose.sh vps
   ```

4. Use `--dry-run` before any VPS deploy to verify the resolved configuration:
   ```bash
   HOMELAB_ENV_FILE=/path/to/secrets/vps.env ./scripts/deploy/deploy-compose.sh vps --dry-run
   ```

5. Regular maintenance:
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

2. Follow the existing template:
   ```bash
   #!/bin/bash
   set -euo pipefail

   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

   main() {
       # Your code here
   }

   main "$@"
   ```

3. Make it executable:
   ```bash
   chmod +x scripts/category/your-script.sh
   ```

4. Update this README with usage instructions.