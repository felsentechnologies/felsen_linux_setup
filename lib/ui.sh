#!/usr/bin/env bash

amarelo="${amarelo:-\e[33m}"
verde="${verde:-\e[32m}"
branco="${branco:-\e[97m}"
bege="${bege:-\e[93m}"
vermelho="${vermelho:-\e[91m}"
reset="${reset:-\e[0m}"

ui_clear() {
  command -v clear >/dev/null 2>&1 && clear || true
}

ui_banner() {
  echo -e "${verde}Felsen Linux Setup${reset}"
  echo -e "${branco}Instalador modular para Docker Swarm, Portainer e apps self-hosted.${reset}"
  echo
}

ui_section() {
  echo -e "${amarelo}==>${reset} ${branco}$*${reset}"
}

ui_error() {
  echo -e "${vermelho}Erro:${reset} $*" >&2
}

ui_success() {
  echo -e "${verde}OK:${reset} $*"
}

ui_pause() {
  read -r -p "Pressione Enter para continuar... " _
}

confirm_yes_no() {
  local prompt="${1:-Continuar?}"
  local answer
  while true; do
    read -r -p "$prompt (Y/N): " answer
    case "$answer" in
      Y|y) return 0 ;;
      N|n) return 1 ;;
      *) echo "Digite apenas Y ou N." ;;
    esac
  done
}

versao() {
  echo -e "${branco}Versao do Felsen Linux Setup: ${verde}v. 1.0.0${reset}"
}

nome_instalador() {
  ui_banner
}

nome_menu() {
  ui_clear
  ui_banner
}

direitos_setup() {
  echo -e "${branco}Este instalador organiza stacks self-hosted em Docker/Portainer.${reset}"
}

direitos_instalador() {
  direitos_setup
  echo
  confirm_yes_no "Ao digitar Y voce confirma que revisou o script e deseja continuar" || exit 1
}

creditos_msg() {
  echo
}

instalando_msg() {
  ui_section "Instalando"
}

instalado_msg() {
  ui_success "Instalacao finalizada"
}

erro_msg() {
  ui_error "Operacao nao concluida"
}