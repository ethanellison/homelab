FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends ca-certificates wget \
    && wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq \
    && rm -rf /var/lib/apt/lists/*

# Install Kubernetes-specific features
RUN su vscode -c "devcontainer features install 'ghcr.io/devcontainers/features/kubectl-helm-minikube:1'"
RUN su vscode -c "devcontainer features install 'ghcr.io/devcontainers-extra/features/argo-cd:1'"
RUN su vscode -c "devcontainer features install 'ghcr.io/rio/features/k3d:1'"
RUN su vscode -c "devcontainer features install 'ghcr.io/rio/features/k9s:1'"
