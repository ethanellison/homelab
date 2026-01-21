FROM ../../base.Dockerfile

# Install Kubernetes-specific features
RUN su vscode -c "devcontainer features install 'ghcr.io/devcontainers/features/kubectl-helm-minikube:1'"
RUN su vscode -c "devcontainer features install 'ghcr.io/devcontainers-extra/features/argo-cd:1'"
RUN su vscode -c "devcontainer features install 'ghcr.io/rio/features/k3d:1'"
RUN su vscode -c "devcontainer features install 'ghcr.io/rio/features/k9s:1'"
