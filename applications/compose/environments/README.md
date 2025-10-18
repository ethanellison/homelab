# Docker Compose Environments

This directory contains environment-specific Docker Compose configurations for different deployment targets.

## Structure

```
environments/
├── local/              # Local development environment
│   ├── docker-compose.yaml
│   └── .env.example
└── vps/               # VPS production environment
    ├── docker-compose.yaml
    └── .env.example
```

## Environment Setup

### Local Development

1. Copy the environment template:
   ```bash
   cp local/.env.example local/.env
   ```

2. Create required directories:
   ```bash
   mkdir -p local/data/{homeassistant,pihole/{etc,dnsmasq.d},paperless/{data,media,consume,export},redis}
   ```

3. Start the environment:
   ```bash
   docker compose -f local/docker-compose.yaml up -d
   ```

### VPS Production

1. Copy the environment template:
   ```bash
   cp vps/.env.example vps/.env
   ```

2. Create required directories:
   ```bash
   sudo mkdir -p /opt/{homeassistant/config,pihole/{etc,dnsmasq.d},paperless/{data,media,consume,export},redis/data}
   ```

3. Set proper permissions:
   ```bash
   sudo chown -R 1000:1000 /opt/{homeassistant,paperless,redis}
   sudo chown -R pihole:pihole /opt/pihole
   ```

4. Start the environment:
   ```bash
   docker compose -f vps/docker-compose.yaml up -d
   ```

## Configuration Details

### Local Environment
- All data stored in `./data/` directory
- Debug modes enabled
- Services exposed on localhost
- Simplified security for development

### VPS Environment
- Data stored in `/opt/` directory
- Production security settings
- Tailscale integration
- Proper volume permissions
- Internal networking
- Reverse proxy support

## Network Architecture

### Local
- All services exposed on localhost
- Direct access for development
- No internal network isolation

### VPS
- Internal network for service communication
- Tailscale network for secure access
- Restricted port exposure
- Reverse proxy for web services

## Backup Considerations

### Local
- Data in `./data/` can be backed up as needed
- Development data not critical

### VPS
- Regular backups of `/opt/` recommended
- Consider volume backup strategy
- Database dumps for Redis
- Configuration backups