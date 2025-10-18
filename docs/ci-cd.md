# CI/CD Configuration Guide

This guide explains how to set up the CI/CD pipeline for automated deployments.

## GitHub Actions Secrets

You need to configure the following secrets in your GitHub repository:

### Environment Secrets (Production)

1. Navigate to your repository settings:
   - Go to "Settings" > "Environments"
   - Click "New environment"
   - Name it "production"
   - Add protection rules if desired (e.g., required reviewers)

2. Add the following secrets:

   | Secret Name | Description | Example |
   |------------|-------------|----------|
   | `SSH_PRIVATE_KEY` | SSH private key for VPS access | `-----BEGIN OPENSSH PRIVATE KEY-----\n...` |
   | `SSH_KNOWN_HOSTS` | SSH known hosts file content | `vps.example.com ssh-ed25519 AAAA...` |
   | `SSH_HOST` | VPS hostname or IP | `vps.example.com` |
   | `SSH_USERNAME` | SSH username | `deploy` |
   | `ENV_FILE` | Complete environment file content | `HOST_IP=1.2.3.4\nDOMAIN=...` |

## Setting Up SSH Access

1. Generate a deployment SSH key:
   ```bash
   ssh-keygen -t ed25519 -C "github-actions-deploy"
   ```

2. Add to VPS authorized keys:
   ```bash
   # On your VPS
   mkdir -p ~/.ssh
   echo "public-key-content" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. Get known hosts entry:
   ```bash
   ssh-keyscan -H your-vps-hostname.com
   ```

4. Create the environment file:
   ```bash
   # Copy the example file
   cp applications/compose/environments/vps/.env.example production.env
   
   # Edit with your settings
   nano production.env
   
   # Use the content for the ENV_FILE secret
   cat production.env
   ```

## Deployment Process

The CI/CD pipeline will:

1. Validate all configurations
2. Deploy to VPS when merging to main
3. Verify the deployment
4. Report status back to GitHub

### Manual Deployment

If needed, you can manually deploy using:

```bash
# SSH into your VPS
ssh your-vps-hostname.com

# Navigate to deployment directory
cd /opt/homelab

# Run deployment
docker compose -f applications/compose/environments/vps/docker-compose.yaml up -d
```

## Troubleshooting

### Common Issues

1. SSH Connection Failures:
   - Verify SSH key permissions
   - Check known hosts entry
   - Confirm VPS firewall settings

2. Docker Compose Errors:
   - Check environment variables
   - Verify file permissions
   - Review Docker logs

3. Service Verification Failures:
   - Check service logs
   - Verify port availability
   - Check resource constraints

### Logs and Debugging

Access deployment logs:
1. GitHub Actions workflow logs
2. VPS Docker logs
3. Application-specific logs