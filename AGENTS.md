# Agent Guidelines

This document contains guidelines and patterns for agents working on this homelab project.

## Build/Lint/Test Commands

This is an infrastructure-as-code repository. Validation is done via CI/CD.

- **Validate all manifests:** `./kustomize build infrastructure/kubernetes/base`
- **Validate Docker Compose:** `docker compose -f applications/compose/base/<service>/compose.yaml -f applications/compose/environments/<env>/docker-compose.yaml config`
- **Run single test:** No unit tests. Validate a single service by running the compose config command for that service.

## Code Style Guidelines

- **YAML:** Use 2 spaces for indentation. Follow existing structure in `compose.yaml` files.
- **Naming:** Use kebab-case for service names and directories (e.g., `ts-budget`, `budget-actual`).
- **Environment Variables:** Use `SCREAMING_SNAKE_CASE`. Store in `.env` files, not in code.
- **Tailscale Services:** Follow the Tailscale Service Pattern below for consistency.

## Tailscale Service Pattern

When adding a new service to a Tailnet, follow this pattern:

1.  **Service Definition:** Add a `ts-<service_name>` sidecar container in `compose.yaml` using the template from the automation stack.
2.  **Serve Config:** Create `config/<service_name>.json` to proxy traffic to the main service container.
3.  **Environment:** Ensure `TS_AUTHKEY` and `TS_CERT_DOMAIN` are set in the environment.