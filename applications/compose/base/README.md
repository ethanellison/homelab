# Base Service Configurations

This directory contains the base Docker Compose configurations for each service in the homelab. Each service has its own directory with a modular compose file that can be included and extended by environment-specific configurations.

## Structure

```
base/
├── homeassistant/        # Home Assistant service
│   └── compose.yaml     # Base Home Assistant configuration
├── paperless/           # Paperless-ngx service
│   └── compose.yaml     # Base Paperless configuration
├── pihole/             # Pi-hole DNS service
│   └── compose.yaml     # Base Pi-hole configuration
├── redis/              # Redis service
│   └── compose.yaml     # Base Redis configuration
└── tsdproxy/           # Tailscale proxy service
    └── compose.yaml     # Base TSDProxy configuration
```

## Service Configuration

### Home Assistant
- Base image and container configuration
- Volume mounts for configuration and system access
- Time zone settings

### Paperless-ngx
- Document management service configuration
- Redis dependency
- Volume configurations for data persistence

### Pi-hole
- DNS and ad-blocking service
- Basic network configuration
- Volume mounts for configuration

### Redis
- Database service for Paperless
- Data persistence configuration
- Basic security settings

### TSDProxy
- Tailscale proxy service
- Docker socket access
- Basic networking configuration

## Usage

Each service's compose file is designed to be included in environment-specific compose files:

```yaml
# Example environment-specific docker-compose.yaml
include:
  - ../../base/homeassistant/compose.yaml
  - ../../base/pihole/compose.yaml
  # ... other services

services:
  # Override or extend service configurations
  homeassistant:
    ports:
      - "8123:8123"
    # ... other overrides
```

## Adding New Services

1. Create a new directory for your service:
   ```bash
   mkdir -p base/new-service
   ```

2. Create the base compose file:
   ```bash
   touch base/new-service/compose.yaml
   ```

3. Define the base configuration:
   ```yaml
   version: "3.8"
   
   services:
     new-service:
       image: ...
       # ... base configuration
   ```

4. Include in environment-specific compose files:
   ```yaml
   include:
     - ../../base/new-service/compose.yaml
   ```

## Best Practices

1. Keep base configurations minimal
2. Use environment variables for customization
3. Define volumes in base configurations
4. Use common labels and networks
5. Follow naming conventions