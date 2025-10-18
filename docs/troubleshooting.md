# Troubleshooting Guide

This document provides solutions for common issues you might encounter when working with this homelab setup.

## Kubernetes Issues

### ArgoCD Sync Failures

1. **Issue**: Applications stuck in "OutOfSync" state
   ```bash
   # Check application status
   argocd app get <app-name>
   
   # View detailed sync errors
   kubectl logs -n argocd deploy/argocd-application-controller
   ```
   **Solution**: 
   - Verify that your Kustomize overlays are correctly configured
   - Check if all required resources exist
   - Ensure RBAC permissions are correct

2. **Issue**: Resource creation fails
   ```bash
   # Check events in the namespace
   kubectl get events -n <namespace>
   ```
   **Solution**:
   - Verify resource specifications
   - Check for namespace existence
   - Validate RBAC permissions

### External Secrets Issues

1. **Issue**: Secrets not syncing
   ```bash
   # Check ESO operator logs
   kubectl logs -n external-secrets deploy/external-secrets
   
   # Check secret store status
   kubectl get secretstore -A
   ```
   **Solution**:
   - Verify secret store credentials
   - Check secret path in external provider
   - Validate ESO CRDs are installed

## Docker Compose Issues

### Service Startup Failures

1. **Issue**: Services fail to start
   ```bash
   # Check service logs
   docker compose logs <service-name>
   
   # Verify service status
   docker compose ps
   ```
   **Solution**:
   - Check environment variables
   - Verify volume mounts exist
   - Ensure ports are not in use

2. **Issue**: Volume permission issues
   ```bash
   # Check volume permissions
   ls -la /opt/<service>/
   ```
   **Solution**:
   - Adjust directory permissions
   - Verify user/group mappings
   - Check SELinux context if applicable

### Network Issues

1. **Issue**: Services can't communicate
   ```bash
   # Check network configuration
   docker network ls
   docker network inspect <network-name>
   ```
   **Solution**:
   - Verify service names in compose file
   - Check network mode configuration
   - Validate port mappings

## Common Infrastructure Issues

### Database Connection Issues

1. **Issue**: Applications can't connect to database
   ```bash
   # Check database service status
   docker compose ps db
   # or
   kubectl get pods -n <namespace> | grep db
   ```
   **Solution**:
   - Verify database credentials
   - Check network connectivity
   - Validate connection strings

### TLS Certificate Issues

1. **Issue**: Invalid certificates
   ```bash
   # Check cert-manager status
   kubectl get certificaterequest -A
   kubectl get certificates -A
   ```
   **Solution**:
   - Verify DNS records
   - Check cert-manager configuration
   - Validate certificate issuers

## Development Environment Issues

### Local Development

1. **Issue**: Development environment won't start
   ```bash
   # Check system resources
   docker system df
   df -h
   ```
   **Solution**:
   - Clear Docker cache
   - Remove unused volumes
   - Free up disk space

### CI/CD Pipeline

1. **Issue**: GitHub Actions workflow failures
   - Check workflow logs in GitHub Actions
   - Verify repository secrets are set
   - Validate workflow syntax

## Getting Help

If you encounter an issue not covered here:

1. Check the logs:
   ```bash
   # Kubernetes logs
   kubectl logs -n <namespace> <pod-name>
   
   # Docker logs
   docker compose logs
   ```

2. Check system resources:
   ```bash
   # System resources
   top
   df -h
   free -h
   ```

3. Review recent changes:
   ```bash
   # Git history
   git log --oneline -n 10
   ```

4. Open an issue in the repository with:
   - Description of the problem
   - Steps to reproduce
   - Relevant logs
   - Environment information
