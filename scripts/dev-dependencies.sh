#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

docker network create minikube || echo "Network 'minikube' already exists."
# set git config
git config --global user.email "e_21997@hotmail.com"
git config --global user.name "e21997-dev"

# Start Minikube
echo "Starting Minikube..."
minikube start --driver=docker

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
echo