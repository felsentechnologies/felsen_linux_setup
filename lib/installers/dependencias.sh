#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

dependencias() {
  local packages=(
    sudo
    apt-utils
    dialog
    jq
    apache2-utils
    git
    python3
    curl
    wget
    ca-certificates
    gnupg
    lsb-release
    apparmor-utils
  )
  local env_value

  nome_iniciando
  echo "Verificando dependencias base do Felsen Linux Setup."
  echo ""

  if [[ "$(id -u)" -ne 0 ]] && ! command -v sudo >/dev/null 2>&1; then
    ui_error "Execute como root ou instale sudo antes de continuar."
    return 1
  fi

  if sudo apt-get update >/dev/null 2>&1; then
    echo "1/3 - [ OK ] - Atualizando lista de pacotes"
  else
    echo "1/3 - [ OFF ] - Atualizando lista de pacotes"
    return 1
  fi

  if sudo apt-get install -y "${packages[@]}" >/dev/null 2>&1; then
    echo "2/3 - [ OK ] - Verificando/instalando pacotes base"
  else
    echo "2/3 - [ OFF ] - Verificando/instalando pacotes base"
    return 1
  fi

  if command -v docker >/dev/null 2>&1 && command -v systemctl >/dev/null 2>&1; then
    sudo mkdir -p /etc/systemd/system/docker.service.d >/dev/null 2>&1
    sudo bash -c 'cat > /etc/systemd/system/docker.service.d/override.conf <<__FELSEN_MANAGED_FILE__
[Service]
Environment=DOCKER_MIN_API_VERSION=1.24
__FELSEN_MANAGED_FILE__' >/dev/null 2>&1
    sudo systemctl daemon-reexec >/dev/null 2>&1 || true
    sudo systemctl daemon-reload >/dev/null 2>&1 || true
    sudo systemctl restart docker >/dev/null 2>&1 || true

    env_value="$(systemctl show --property=Environment docker 2>/dev/null | grep -o "DOCKER_MIN_API_VERSION=1.24" || true)"
    if [[ "$env_value" == "DOCKER_MIN_API_VERSION=1.24" ]]; then
      echo "3/3 - [ OK ] - Docker API minima configurada"
    else
      echo "3/3 - [ OFF ] - Docker encontrado, mas ajuste nao foi confirmado"
    fi
  else
    echo "3/3 - [ OK ] - Docker ausente; ajuste sera ignorado"
  fi

  echo ""
  ui_success "Dependencias verificadas."
}
