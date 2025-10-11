FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install common features
RUN su vscode -c "devcontainer features install 'ghcr.io/devcontainers-extra/features/neovim-apt-get:1'"
