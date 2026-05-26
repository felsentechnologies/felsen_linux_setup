#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=lib/ui.sh
source "$SCRIPT_DIR/lib/ui.sh"
# shellcheck source=lib/system.sh
source "$SCRIPT_DIR/lib/system.sh"

APPS_CATALOG="$SCRIPT_DIR/config/apps.tsv"
COMMANDS_CATALOG="$SCRIPT_DIR/config/commands.tsv"

PAGE_SIZE="${FELSEN_MENU_PAGE_SIZE:-18}"
current_view="apps"
current_page=1
search_query=""

require_bash

usage() {
  cat <<__FELSEN_MANAGED_FILE__
Uso:
  bash menu.sh                  Abre o menu interativo
  bash menu.sh <opcao> [sufixo] Executa uma opcao, alias ou comando

Exemplos:
  bash menu.sh n8n
  bash menu.sh chatwoot cliente1
  bash menu.sh portainer.restart

No menu interativo:
  Digite o numero, slug ou alias para executar.
  Use /texto para buscar.
  Use n/p para proxima pagina ou pagina anterior.
  Use p1, p2 ou p3 para saltar para paginas antigas.
  Use apps ou comandos para alternar a lista.
  Use ajuda para ver os atalhos.
__FELSEN_MANAGED_FILE__
}

read_tsv() {
  local file="$1"
  while IFS=$'\t' read -r c1 c2 c3 c4 c5 c6 c7; do
    [[ -z "${c1:-}" || "${c1:0:1}" == "#" ]] && continue
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$c1" "$c2" "$c3" "$c4" "$c5" "$c6" "$c7"
  done < "$file"
}

lower_text() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

trim_left() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  printf '%s' "$value"
}

token_matches_alias() {
  local token
  local aliases
  local alias

  token="$(lower_text "$1")"
  aliases="$2"

  IFS=',' read -ra alias_list <<< "$aliases"
  for alias in "${alias_list[@]}"; do
    [[ "$token" == "$(lower_text "$alias")" ]] && return 0
  done
  return 1
}

app_matches_search() {
  local query
  local number="$1"
  local slug="$2"
  local name="$3"
  local aliases="$4"

  [[ -z "$search_query" ]] && return 0
  query="$(lower_text "$search_query")"

  [[ "$(lower_text "$number $slug $name $aliases")" == *"$query"* ]]
}

command_matches_search() {
  local query
  local slug="$1"
  local script="$2"
  local function="$3"

  [[ -z "$search_query" ]] && return 0
  query="$(lower_text "$search_query")"

  [[ "$(lower_text "$slug $script $function")" == *"$query"* ]]
}

count_apps() {
  local count=0
  local number slug name app_page aliases script function
  while IFS=$'\t' read -r number slug name app_page aliases script function; do
    if app_matches_search "$number" "$slug" "$name" "$aliases"; then
      count=$((count + 1))
    fi
  done < <(read_tsv "$APPS_CATALOG")
  printf '%s\n' "$count"
}

count_commands() {
  local count=0
  local slug script function _
  while IFS=$'\t' read -r slug script function _; do
    if command_matches_search "$slug" "$script" "$function"; then
      count=$((count + 1))
    fi
  done < <(read_tsv "$COMMANDS_CATALOG")
  printf '%s\n' "$count"
}

max_pages_for_count() {
  local total="$1"
  local pages=1
  if (( total > 0 )); then
    pages=$(( (total + PAGE_SIZE - 1) / PAGE_SIZE ))
  fi
  printf '%s\n' "$pages"
}

clamp_page() {
  local total="$1"
  local pages
  pages="$(max_pages_for_count "$total")"

  (( current_page < 1 )) && current_page=1
  (( current_page > pages )) && current_page="$pages"
}

show_header() {
  local title="$1"
  local total="$2"
  local pages
  pages="$(max_pages_for_count "$total")"

  nome_menu
  echo -e "${branco}${title}${reset}"
  echo "Itens: $total | Pagina: $current_page/$pages | Busca: ${search_query:-sem filtro}"
  echo
}

show_apps() {
  local total skip printed seen
  local number slug name app_page aliases script function

  total="$(count_apps)"
  clamp_page "$total"
  skip=$(( (current_page - 1) * PAGE_SIZE ))
  printed=0
  seen=0

  show_header "Catalogo de apps" "$total"
  printf "%-5s %-24s %s\n" "Num" "Slug" "Nome"
  printf "%-5s %-24s %s\n" "---" "----" "----"

  while IFS=$'\t' read -r number slug name app_page aliases script function; do
    app_matches_search "$number" "$slug" "$name" "$aliases" || continue
    if (( seen < skip )); then
      seen=$((seen + 1))
      continue
    fi
    (( printed >= PAGE_SIZE )) && break
    printf "%-5s %-24s %s\n" "$number" "$slug" "$name"
    printed=$((printed + 1))
    seen=$((seen + 1))
  done < <(read_tsv "$APPS_CATALOG")

  (( total == 0 )) && echo "Nenhum app encontrado para a busca atual."
  echo
  show_shortcuts
}

show_commands() {
  local total skip printed seen
  local slug script function _

  total="$(count_commands)"
  clamp_page "$total"
  skip=$(( (current_page - 1) * PAGE_SIZE ))
  printed=0
  seen=0

  show_header "Comandos de manutencao" "$total"
  printf "%-28s %s\n" "Comando" "Descricao tecnica"
  printf "%-28s %s\n" "-------" "-----------------"

  while IFS=$'\t' read -r slug script function _; do
    command_matches_search "$slug" "$script" "$function" || continue
    if (( seen < skip )); then
      seen=$((seen + 1))
      continue
    fi
    (( printed >= PAGE_SIZE )) && break
    printf "%-28s %s\n" "$slug" "$function"
    printed=$((printed + 1))
    seen=$((seen + 1))
  done < <(read_tsv "$COMMANDS_CATALOG")

  (( total == 0 )) && echo "Nenhum comando encontrado para a busca atual."
  echo
  show_shortcuts
}

show_shortcuts() {
  echo "Atalhos: /buscar | limpa | n proxima | p anterior | apps | comandos | ajuda | sair"
  echo "Dica: informe um sufixo depois da opcao. Ex.: chatwoot cliente1"
  echo
}

show_help() {
  nome_menu
  cat <<__FELSEN_MANAGED_FILE__
Como usar o menu

Executar:
  6
  n8n
  chatwoot cliente1
  portainer.restart

Navegar:
  n          proxima pagina
  p          pagina anterior
  p1/p2/p3   vai para uma pagina especifica de apps
  apps       lista aplicativos
  comandos   lista comandos de manutencao

Buscar:
  /redis     filtra itens por texto
  limpa      remove o filtro

Sair:
  sair

Tambem e possivel executar sem abrir o menu:
  bash menu.sh n8n
  bash menu.sh docker.fix
__FELSEN_MANAGED_FILE__
  echo
}

resolve_app_script() {
  local token
  local number slug name page aliases script function

  token="$(lower_text "$1")"
  while IFS=$'\t' read -r number slug name page aliases script function; do
    if [[ "$token" == "$(lower_text "$number")" || "$token" == "$(lower_text "$slug")" ]] || token_matches_alias "$token" "$aliases"; then
      printf '%s\n' "$SCRIPT_DIR/$script"
      return 0
    fi
  done < <(read_tsv "$APPS_CATALOG")
  return 1
}

resolve_command_script() {
  local token
  local slug script function _

  token="$(lower_text "$1")"
  while IFS=$'\t' read -r slug script function _; do
    if [[ "$token" == "$(lower_text "$slug")" ]]; then
      printf '%s\n' "$SCRIPT_DIR/$script"
      return 0
    fi
  done < <(read_tsv "$COMMANDS_CATALOG")
  return 1
}

run_script() {
  local kind="$1"
  local script="$2"
  local suffix="$3"

  if [[ "${FELSEN_SETUP_DRY_RUN:-0}" == "1" ]]; then
    printf '%s\t%s\t%s\n' "$kind" "$script" "$suffix"
    return 0
  fi

  bash "$script" "$suffix"
}

run_selection() {
  local token="${1:-}"
  local suffix="${2:-}"
  local script=""

  case "$(lower_text "$token")" in
    "" ) return 0 ;;
    -h|--help|help|ajuda) usage; return 0 ;;
    sair|exit|quit) exit 0 ;;
    apps|app|catalogo) current_view="apps"; current_page=1; return 0 ;;
    comando|comandos|cmd|cmds) current_view="commands"; current_page=1; return 0 ;;
    p1) current_view="apps"; current_page=1; return 0 ;;
    p2) current_view="apps"; current_page=2; return 0 ;;
    p3) current_view="apps"; current_page=3; return 0 ;;
    n|next|proxima|proximo|+) current_page=$((current_page + 1)); return 0 ;;
    p|prev|anterior|-) current_page=$((current_page - 1)); return 0 ;;
    limpa|limpar|clear) search_query=""; current_page=1; return 0 ;;
  esac

  if script="$(resolve_app_script "$token")"; then
    run_script "app" "$script" "$suffix"
    return $?
  fi

  if script="$(resolve_command_script "$token")"; then
    run_script "command" "$script" "$suffix"
    return $?
  fi

  ui_error "Opcao ou comando nao encontrado: $token"
  return 1
}

confirm_interactive_run() {
  local token="$1"
  local suffix="$2"
  local label="$token"

  [[ -n "$suffix" ]] && label="$label $suffix"
  confirm_yes_no "Executar '$label' agora?"
}

interactive_menu() {
  local input token suffix

  while true; do
    if [[ "$current_view" == "commands" ]]; then
      show_commands
    else
      show_apps
    fi

    read -r -p "Escolha: " input
    input="$(trim_left "$input")"

    if [[ "$input" == /* ]]; then
      search_query="${input#/}"
      current_page=1
      continue
    fi

    token="${input%% *}"
    suffix="${input#"$token"}"
    suffix="$(trim_left "$suffix")"

    case "$(lower_text "$token")" in
      "" ) continue ;;
      ajuda|help|-h|--help) show_help; ui_pause; continue ;;
      sair|exit|quit|apps|app|catalogo|comando|comandos|cmd|cmds|p1|p2|p3|n|next|proxima|proximo|+|p|prev|anterior|-|limpa|limpar|clear)
        run_selection "$token" "$suffix" || ui_pause
        continue
        ;;
    esac

    if confirm_interactive_run "$token" "$suffix"; then
      run_selection "$token" "$suffix" || ui_pause
    fi
  done
}

if [[ "${1:-}" != "" ]]; then
  run_selection "$1" "${2:-}"
else
  interactive_menu
fi
