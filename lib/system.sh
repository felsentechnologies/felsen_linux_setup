#!/usr/bin/env bash

require_bash() {
  if [ -z "${BASH_VERSION:-}" ]; then
    echo "Este instalador precisa ser executado com bash." >&2
    exit 1
  fi
}

require_command() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "Comando obrigatorio nao encontrado: $cmd" >&2
    return 1
  }
}

local_ip() {
  hostname -I 2>/dev/null | awk '{print $1}'
}

sanitize_suffix() {
  local value="${1:-}"
  value="${value//[^a-zA-Z0-9_-]/}"
  printf '%s' "$value"
}