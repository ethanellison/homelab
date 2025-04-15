#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e
# set git config
git config --global user.email "e_21997@hotmail.com"
git config --global user.name "e21997-dev"

# check for existing k3d cluster
if k3d cluster list | grep -q "dev-cluster"; then
    echo "k3d cluster 'dev-cluster' already exists. Deleting it..."
    k3d cluster delete dev-cluster
else
    echo "No existing k3d cluster found."
fi
# Start k3d cluster
echo "Starting k3d cluster..."
k3d cluster create dev-cluster

# Install ArgoCD Kubernetes manifests
echo "Installing ArgoCD manifests..."
kubectl create namespace argocd || echo "Namespace 'argocd' already exists."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD server to be ready
echo "Waiting for ArgoCD server to be ready..."
kubectl wait --namespace argocd --for=condition=available --timeout=600s deployment/argocd-server

# Set up ArgoCD CLI to connect to Minikube cluster
echo "Configuring ArgoCD CLI to connect to Minikube cluster..."
argocd login cd.argoproj.io --core

# Output ArgoCD admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# set ArgoCD admin password to env variable
export ARGOCD_ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# expose argoCD server
echo "Exposing ArgoCD server..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &


echo