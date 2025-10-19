#!/bin/bash
set -euo pipefail

# === Variables ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# === Functions ===
main() {
  # add env variable statements
  export TSDPROXY_TOKEN=$(pass show tailscale/tsdproxy)

}

main "$@"
