# GitOps Kubernetes Homelab Portfolio

This repository showcases a Gitops-driven Kubernetes homelab environment. It demonstrates infrastructure-as-code, automation, and maintainability for personal projects.

## Structure

- `clusters`: Contains cluster-specific configurations.
- `infrastructure`: Defines core infrastructure components.
- `applications`: Contains application-specific configurations, now including Pi-hole.
- `scripts`: Includes automation scripts.
- `docs`: Contains detailed documentation.

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

## Application Updates

The `automation` application (`applications/docker-compose-apps/automation/compose.yaml`) now utilizes PostgreSQL with the `pgvector` extension for enhanced database capabilities. Ensure `POSTGRES_PASSWORD` is set in your environment variables for this service.
