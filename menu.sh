#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"
# shellcheck source=lib/system.sh
source "$SCRIPT_DIR/lib/system.sh"

APPS_CATALOG="$SCRIPT_DIR/config/apps.tsv"
COMMANDS_CATALOG="$SCRIPT_DIR/config/commands.tsv"
current_page=1

require_bash

usage() {
  cat <<__FELSEN_MANAGED_FILE__
Uso:
  bash menu.sh                 Abre o menu interativo
  bash menu.sh <opcao> [sufixo] Executa uma opcao, alias ou comando

Exemplos:
  bash menu.sh n8n
  bash menu.sh chatwoot cliente1
  bash menu.sh portainer.restart
__FELSEN_MANAGED_FILE__
}

read_tsv() {
  local file="$1"
  while IFS=$'\t' read -r c1 c2 c3 c4 c5 c6 c7; do
    [[ -z "${c1:-}" || "${c1:0:1}" == "#" ]] && continue
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$c1" "$c2" "$c3" "$c4" "$c5" "$c6" "$c7"
  done < "$file"
}

show_menu_page() {
  local page="$1"
  local number slug name app_page aliases script function
  nome_menu
  echo -e "${branco}Pagina ${amarelo}${page}${reset}"
  echo
  while IFS=$'\t' read -r number slug name app_page aliases script function; do
    [[ "$app_page" == "$page" ]] || continue
    printf "[ %02d ] - %s\n" "$number" "$name"
  done < <(read_tsv "$APPS_CATALOG")
  echo
  echo "P1, P2, P3: navegar paginas | comandos: lista comandos | sair: encerrar"
  echo
}

show_commands() {
  local slug script function
  nome_menu
  echo "Comandos disponiveis:"
  echo
  while IFS=$'\t' read -r slug script function _; do
    [[ -z "${slug:-}" || "${slug:0:1}" == "#" ]] && continue
    printf "  %s\n" "$slug"
  done < "$COMMANDS_CATALOG"
  echo
  echo "P1, P2, P3: voltar ao catalogo | sair: encerrar"
  echo
}

token_matches_alias() {
  local token="$1"
  local aliases="$2"
  local alias
  IFS=',' read -ra alias_list <<< "$aliases"
  for alias in "${alias_list[@]}"; do
    [[ "$token" == "$alias" ]] && return 0
  done
  return 1
}

resolve_app_script() {
  local token="$1"
  local number slug name page aliases script function
  while IFS=$'\t' read -r number slug name page aliases script function; do
    if [[ "$token" == "$number" || "$token" == "$slug" ]] || token_matches_alias "$token" "$aliases"; then
      printf '%s\n' "$SCRIPT_DIR/$script"
      return 0
    fi
  done < <(read_tsv "$APPS_CATALOG")
  return 1
}

resolve_command_script() {
  local token="$1"
  local slug script function
  while IFS=$'\t' read -r slug script function _; do
    [[ -z "${slug:-}" || "${slug:0:1}" == "#" ]] && continue
    if [[ "$token" == "$slug" ]]; then
      printf '%s\n' "$SCRIPT_DIR/$script"
      return 0
    fi
  done < "$COMMANDS_CATALOG"
  return 1
}

run_selection() {
  local token="${1:-}"
  local suffix="${2:-}"
  local script=""

  case "$token" in
    "" ) return 0 ;;
    -h|--help|help|ajuda) usage; return 0 ;;
    sair|SAIR|exit|quit) exit 0 ;;
    p1|P1) current_page=1; return 0 ;;
    p2|P2) current_page=2; return 0 ;;
    p3|P3) current_page=3; return 0 ;;
    comando|COMANDO|comandos|COMANDOS) current_page=commands; return 0 ;;
  esac

  if script="$(resolve_app_script "$token")"; then
    if [[ "${FELSEN_SETUP_DRY_RUN:-0}" == "1" ]]; then
      printf 'app\t%s\t%s\n' "$script" "$suffix"
      return 0
    fi
    bash "$script" "$suffix"
    return $?
  fi

  if script="$(resolve_command_script "$token")"; then
    if [[ "${FELSEN_SETUP_DRY_RUN:-0}" == "1" ]]; then
      printf 'command\t%s\t%s\n' "$script" "$suffix"
      return 0
    fi
    bash "$script" "$suffix"
    return $?
  fi

  ui_error "Opcao ou comando nao encontrado: $token"
  return 1
}

interactive_menu() {
  local input token suffix
  direitos_instalador
  while true; do
    if [[ "$current_page" == "commands" ]]; then
      show_commands
    else
      show_menu_page "$current_page"
    fi
    read -r -p "Digite a opcao, alias ou comando: " input
    token="${input%% *}"
    suffix="${input#"$token"}"
    suffix="${suffix#"${suffix%%[![:space:]]*}"}"
    run_selection "$token" "$suffix" || ui_pause
  done
}

if [[ "${1:-}" != "" ]]; then
  run_selection "$1" "${2:-}"
else
  interactive_menu
fi
