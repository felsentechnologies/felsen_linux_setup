#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=core.sh
source "$PROJECT_ROOT/lib/core.sh"
# shellcheck source=ui.sh
source "$PROJECT_ROOT/lib/ui.sh"
# shellcheck source=system.sh
source "$PROJECT_ROOT/lib/system.sh"
# shellcheck source=data.sh
source "$PROJECT_ROOT/lib/data.sh"
# shellcheck source=docker.sh
source "$PROJECT_ROOT/lib/docker.sh"
# shellcheck source=portainer.sh
source "$PROJECT_ROOT/lib/portainer.sh"

for installer_module in "$PROJECT_ROOT"/lib/installers/*.sh; do
  # shellcheck source=/dev/null
  source "$installer_module"
done
