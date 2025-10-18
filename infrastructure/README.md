# Infrastructure

This directory contains all infrastructure-level components and configurations.

## Structure

- `kubernetes/`: Kubernetes infrastructure components
  - `base/`: Base infrastructure configurations
    - `cert-manager/`: Certificate management
    - `monitoring/`: Monitoring stack (Prometheus, Grafana)
    - `secret-manager/`: Secret management solutions
    - `tailscale-operator/`: Tailscale networking
  - `overlays/`: Environment-specific infrastructure configs

- `compose/`: Docker Compose infrastructure
  - `base/`: Base infrastructure services
  - `environments/`: Environment-specific configurations