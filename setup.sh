#!/bin/bash

# Create the directory structure
mkdir -p clusters/base clusters/overlays/development clusters/overlays/staging clusters/overlays/production
mkdir -p infrastructure/cert-manager infrastructure/metallb infrastructure/networking
mkdir -p applications/app1/base applications/app2/base
mkdir -p scripts docs

# Create the files
touch README.md
touch clusters/base/kustomization.yaml clusters/base/namespace.yaml
touch clusters/overlays/development/kustomization.yaml clusters/overlays/staging/kustomization.yaml clusters/overlays/production/kustomization.yaml
touch infrastructure/cert-manager/kustomization.yaml infrastructure/metallb/kustomization.yaml infrastructure/networking/kustomization.yaml
touch applications/app1/base/deployment.yaml applications/app1/base/service.yaml applications/app1/base/kustomization.yaml
touch applications/app2/base/deployment.yaml applications/app2/base/service.yaml
touch scripts/deploy.sh scripts/update.sh
touch docs/architecture.md docs/setup.md docs/troubleshooting.md

# Output a message
echo "GitOps Kubernetes Homelab Portfolio structure created."
