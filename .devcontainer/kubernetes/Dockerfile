ARG VARIANT="ubuntu-22.04"
FROM mcr.microsoft.com/devcontainers/base:${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends neovim

# [Optional] Install Kubernetes tools
ARG KUBECTL_VERSION="latest"
ARG HELM_VERSION="latest"
ARG MINIKUBE_VERSION="latest"
# Install kubectl, helm, minikube
RUN if [ "${KUBECTL_VERSION}" != "none" ]; then curl -sSL https://aka.ms/install-kubectl-linux | bash ; fi \
    && if [ "${HELM_VERSION}" != "none" ]; then curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ; fi \
    && if [ "${MINIKUBE_VERSION}" != "none" ]; then curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/v1.28.0/minikube-linux-amd64 && install minikube /usr/local/bin/ ; fi

# [Optional] Install Argo CD CLI
ARG ARGOCD_VERSION="latest"
RUN if [ "${ARGOCD_VERSION}" != "none" ]; then curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && chmod +x /usr/local/bin/argocd ; fi

# [Optional] Install K3d
ARG K3D_VERSION="latest"
RUN if [ "${K3D_VERSION}" != "none" ]; then curl -sSL https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash ; fi

# [Optional] Install K9s
ARG K9S_VERSION="latest"
RUN if [ "${K9S_VERSION}" != "none" ]; then curl -sSL https://github.com/derailed/k9s/releases/download/v0.27.3/k9s_Linux_amd64.tar.gz | tar -xz -C /usr/local/bin k9s ; fi

