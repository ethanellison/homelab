# GitOps Kubernetes Homelab Portfolio

This repository showcases a Gitops-driven Kubernetes homelab environment. It demonstrates infrastructure-as-code, automation, and maintainability for personal projects.

## Structure

- `clusters`: Contains cluster-specific configurations.
- `infrastructure`: Defines core infrastructure components.
- `applications`: Contains application-specific configurations.
- `scripts`: Includes automation scripts.
- `docs`: Contains detailed documentation.

## Devcontainer Options

This repository provides two Devcontainer configurations to cater to different development needs:

- **Kubernetes Devcontainer**: Located in `.devcontainer/kubernetes`, this configuration is designed for developing and testing Kubernetes-native applications. It includes `kubectl`, `helm`, `k3d`, `k9s`, `ArgoCD`, and relevant VS Code extensions like Kubernetes Tools and YAML support.

  **Use Case**: Ideal for working on Helm charts, Kubernetes manifests, or applications that interact directly with a Kubernetes cluster.

- **Docker Compose Devcontainer**: Located in `.devcontainer/docker-compose`, this configuration is tailored for Docker Compose-based development. It provides a Docker-in-Docker environment and the VS Code Docker extension.

  **Use Case**: Suitable for developing microservices, backend services, or any application that uses Docker Compose for local orchestration.

### How to Choose a Devcontainer in VS Code

When opening the repository in VS Code, you will be prompted to choose a Devcontainer configuration if multiple are detected. You can also manually select a configuration:

1. Open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`).
2. Search for `Dev Containers: Open Folder in Container...`.
3. Select the desired Devcontainer configuration from the list (e.g., `kubernetes` or `docker-compose`).

## Usage

Refer to the `docs` directory for detailed setup and usage instructions.
