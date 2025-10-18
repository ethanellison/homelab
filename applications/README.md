# Applications

This directory contains all application definitions for both Kubernetes and Docker Compose deployments.

## Structure

- `kubernetes/`: Contains all Kubernetes application manifests
  - `base/`: Base configurations for all applications
  - `overlays/`: Environment-specific configurations
    - `dev/`: Development environment configurations
    - `staging/`: Staging environment configurations
    - `prod/`: Production environment configurations

- `compose/`: Contains all Docker Compose application definitions
  - `base/`: Base compose files and configurations
  - `environments/`: Environment-specific compose overrides
    - `local/`: Local development environment
    - `vps/`: VPS deployment environment