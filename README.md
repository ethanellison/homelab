# GitOps Kubernetes and Docker Compose Homelab

This repository implements a GitOps-driven homelab environment supporting both Kubernetes and Docker Compose deployments. It provides a unified approach to managing infrastructure and applications across different environments.

## Repository Structure

```
homelab/
├── applications/          # Application definitions
│   ├── kubernetes/       # K8s applications
│   │   ├── base/        # Base configurations
│   │   └── overlays/    # Environment overlays
│   └── compose/         # Docker Compose apps
│       ├── base/        # Base services
│       └── environments/# Environment-specific configs
├── infrastructure/       # Core infrastructure
│   ├── kubernetes/      # K8s infrastructure
│   └── compose/         # Compose infrastructure
├── platform/            # Platform configurations
│   ├── argocd/         # ArgoCD setup
│   └── secrets/        # Secrets management
└── scripts/            # Automation scripts
```

## Prerequisites

- For Kubernetes deployments:
  - kubectl
  - kustomize
  - ArgoCD CLI
  - Access to a Kubernetes cluster

- For Docker Compose deployments:
  - Docker Engine
  - Docker Compose V2
  - SSH access (for remote deployments)

## Deployment Processes

### Kubernetes Deployments (GitOps with ArgoCD)

1. **Initial Setup**
   ```bash
   # Install ArgoCD in your cluster
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   
   # Login to ArgoCD
   argocd login --core
   ```

2. **Deploy Infrastructure**
   ```bash
   # Apply the infrastructure application
   kubectl apply -f platform/argocd/applications/infrastructure.yaml
   
   # Verify deployment
   argocd app get infrastructure
   ```

3. **Deploy Applications**
   ```bash
   # Apply the applications for your environment
   kubectl apply -f platform/argocd/applications/applications.yaml
   
   # Verify deployment
   argocd app get applications
   ```

4. **Monitor Sync Status**
   ```bash
   # Check sync status
   argocd app list
   
   # View detailed sync info
   argocd app get <app-name>
   ```

### Docker Compose Deployments

1. **Local Development**
   ```bash
   # Deploy local environment
   ./scripts/deploy-compose.sh local
   
   # View logs
   docker compose -f applications/compose/environments/local/docker-compose.yaml logs -f
   ```

2. **VPS Deployment**
   ```bash
   # Deploy to VPS environment
   ./scripts/deploy-compose.sh vps
   
   # Check service status
   docker compose -f applications/compose/environments/vps/docker-compose.yaml ps
   ```

## Environment Management

### Kubernetes Environments

- **Development**: `applications/kubernetes/overlays/dev/`
- **Staging**: `applications/kubernetes/overlays/staging/`
- **Production**: `applications/kubernetes/overlays/prod/`

To modify environment-specific configs:
1. Edit the appropriate overlay directory
2. Commit and push changes
3. ArgoCD will automatically sync changes

### Docker Compose Environments

- **Local**: `applications/compose/environments/local/`
- **VPS**: `applications/compose/environments/vps/`

To modify environment-specific configs:
1. Edit the appropriate environment directory
2. Run the deploy script for your environment

## Secrets Management

This repository uses External Secrets Operator (ESO) for Kubernetes secrets and environment files for Docker Compose secrets.

### Kubernetes Secrets
1. Store secrets in your external secret provider
2. Configure secret store in `platform/secrets/stores/`
3. Create ExternalSecret resources in your applications

### Docker Compose Secrets
1. Create `.env` file in your environment directory
2. Reference secrets in your compose files
3. Never commit `.env` files (they're gitignored)

## CI/CD Pipeline

The repository includes GitHub Actions workflows for:
1. Validation of Kubernetes manifests
2. Validation of Docker Compose files
3. Automated deployment to environments

Pipeline status: ![CI/CD Pipeline](https://github.com/ethanellison/homelab/actions/workflows/ci-cd.yaml/badge.svg)

## Adding New Applications

### Kubernetes Applications
1. Create base configuration in `applications/kubernetes/base/`
2. Create overlays in `applications/kubernetes/overlays/`
3. Update ArgoCD application definitions

### Docker Compose Applications
1. Add service definition to `applications/compose/base/`
2. Add environment-specific configs
3. Update deployment scripts if needed

## Monitoring and Logging

- Kubernetes monitoring via Prometheus/Grafana
- Docker logging via container logs
- Infrastructure monitoring via node_exporter

## Contributing

1. Create a new branch
2. Make your changes
3. Test using the appropriate deployment process
4. Submit a pull request

## Troubleshooting

For common issues and solutions, see `docs/troubleshooting.md`

## Usage

Refer to the `docs` directory for detailed setup and usage instructions.

## Devcontainer Configurations

This repository provides two devcontainer configurations tailored for different development needs:

### 1. Kubernetes Devcontainer

This configuration is ideal for working with Kubernetes-specific tasks. It includes:

- **Base Image:** Ubuntu 22.04
- **Features:** Neovim, Kubectl, Helm, Minikube, Argo CD, K3d, K9s
- **Extensions:** Prettier, Markdownlint, Remote-Containers, GitHub Pull Request, Kubernetes Tools, YAML

**When to use:** Choose this option if you are primarily developing, deploying, or managing Kubernetes resources within the homelab.

**How to select in VS Code:**
1. Open the command palette (Ctrl+Shift+P or Cmd+Shift+P).
2. Type and select \"Dev Containers: Open Folder in Container...\"
3. Choose the `.devcontainer/kubernetes` option.

### 2. Docker Compose Devcontainer

This configuration is suitable for general Docker-based development, especially when working with `docker-compose.yml` files directly. It includes:

- **Base Image:** Ubuntu 22.04
- **Features:** Neovim, Docker-in-Docker
- **Extensions:** Prettier, Markdownlint, Remote-Containers, GitHub Pull Request, Docker

**When to use:** Select this if your focus is on Docker Compose-based services, local development requiring Docker, or if you don't need the full suite of Kubernetes tools.

**How to select in VS Code:**
1. Open the command palette (Ctrl+Shift+P or Cmd+Shift+P).
2. Type and select \"Dev Containers: Open Folder in Container...\"
3. Choose the `.devcontainer/docker-compose` option.
