FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install common features
# RUN su vscode -c "devcontainer features install 'ghcr.io/devcontainers-extra/features/neovim-apt-get:1'"

# Install yq (mikefarah's yq) reliably on Ubuntu 22.04
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends ca-certificates wget \
    && wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    && chmod +x /usr/local/bin/yq \
    && rm -rf /var/lib/apt/lists/*