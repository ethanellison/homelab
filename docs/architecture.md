# Architecture Overview

This document describes the high-level architecture of our homelab environment, which combines Kubernetes and Docker Compose deployments in a GitOps workflow.

## Core Components

### 1. Application Layer
```
applications/
├── kubernetes/           # Kubernetes applications
│   ├── base/            # Base configurations
│   └── overlays/        # Environment-specific overlays
└── compose/             # Docker Compose applications
    ├── base/            # Base service definitions
    └── environments/    # Environment-specific configurations
```

### 2. Infrastructure Layer
```
infrastructure/
├── kubernetes/          # Kubernetes infrastructure
│   ├── base/           # Core infrastructure components
│   └── overlays/       # Environment-specific infrastructure
└── compose/            # Docker Compose infrastructure
    ├── base/           # Base infrastructure services
    └── environments/   # Environment-specific configurations
```

### 3. Platform Layer
```
platform/
├── argocd/             # ArgoCD configurations
│   └── applications/   # Application definitions
└── secrets/            # Secrets management
    └── stores/         # Secret store configurations
```

## Deployment Workflows

### Kubernetes GitOps Flow
1. Changes pushed to repository
2. ArgoCD detects changes
3. Changes are validated
4. Infrastructure changes applied first
5. Application changes applied second
6. Status reported back to ArgoCD

### Docker Compose Deployment Flow
1. Changes pushed to repository
2. CI pipeline validates changes
3. Deploy script executed (manual or automated)
4. Environment-specific compose files applied
5. Services updated with zero-downtime when possible

## Security Architecture

### Secret Management
- External Secrets Operator for Kubernetes
- Environment files for Docker Compose
- Secure secret storage in external providers
- Just-in-time secret injection

### Network Security
- Internal service communication
- External access control
- TLS termination
- Network policies

## Monitoring and Observability

### Kubernetes Monitoring
- Prometheus for metrics
- Grafana for visualization
- Loki for logs
- AlertManager for alerts

### Docker Compose Monitoring
- Container health checks
- Log aggregation
- Resource monitoring
- Status dashboards

## Backup and Recovery

### Data Persistence
- Volume management
- Backup schedules
- Retention policies
- Recovery procedures

### Configuration Backup
- Git-based configuration backup
- Infrastructure state backup
- Secrets backup
- Restore procedures

## Development Workflow

### Local Development
1. Clone repository
2. Choose development environment
3. Start required services
4. Develop and test
5. Commit changes

### Continuous Integration
1. Automated testing
2. Configuration validation
3. Security scanning
4. Deployment dry-runs

## Scaling and Performance

### Resource Management
- Resource quotas
- Scaling policies
- Load balancing
- Performance monitoring

### High Availability
- Service redundancy
- Failover configurations
- Backup services
- Recovery procedures
