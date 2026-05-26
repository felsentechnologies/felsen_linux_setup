#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

traefik.fix() {
  echo ""
  echo "Corrigindo Traefik..."

  if [[ -f /root/traefik.yaml ]]; then
    traefik.update "$@"
    return $?
  fi

  ui_error "Arquivo /root/traefik.yaml nao encontrado. Execute primeiro a instalacao do Traefik & Portainer."
  return 1
}
