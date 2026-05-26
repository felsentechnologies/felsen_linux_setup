#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$PROJECT_ROOT/lib/bootstrap.sh"

suffix="${1:-}"
func="minio.bucket.delete"

if ! declare -F "$func" >/dev/null 2>&1; then
  ui_error "Comando nao encontrado nos modulos: $func"
  exit 1
fi

"$func" "$suffix"
