#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

n8n.mcp() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostrar mensagem de Instalando
instalando_msg

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO MCP DO N8N \e[33m[1/4]\e[0m"
echo ""
sleep 1


## NADA

# Mensagem de Passo
echo -e "\e[97m- PEGANDO INFORMACOES DA STACK DO N8N \e[33m[2/4]\e[0m"
echo ""
sleep 1

local_da_stack="/root/n8n${1:+_$1}.yaml"

if [ ! -f "$local_da_stack" ]; then
    echo -e "\e[91mArquivo $local_da_stack nao encontrado!\e[0m"
    exit 1
fi

# Funcao para extrair valores
get_var() {
  grep "$1" "$local_da_stack" | head -n1 | awk -F '=' '{gsub(/"/, "", $2); print $2}' | xargs
}

# Variaveis extraidas
DB_PASSWORD=$(get_var "DB_POSTGRESDB_PASSWORD")
ENCRYPTION_KEY=$(get_var "N8N_ENCRYPTION_KEY")
N8N_HOST=$(get_var "N8N_HOST")
EDITOR_BASE_URL=$(get_var "N8N_EDITOR_BASE_URL")
WEBHOOK_URL=$(get_var "WEBHOOK_URL")
SMTP_SENDER=$(get_var "N8N_SMTP_SENDER")
SMTP_USER=$(get_var "N8N_SMTP_USER")
SMTP_PASS=$(get_var "N8N_SMTP_PASS")
SMTP_HOST=$(get_var "N8N_SMTP_HOST")
SMTP_PORT=$(get_var "N8N_SMTP_PORT")
SMTP_SSL=$(get_var "N8N_SMTP_SSL")
WEBHOOK_URL_FORMATADO=$(echo "$WEBHOOK_URL" | sed -E 's|https?://([^/]+)/?.*|\1|')
QUEUE_BULL_REDIS_HOST=$(get_var "QUEUE_BULL_REDIS_HOST")

# Exibir uma vez so
echo -e "- DB_PASSWORD=$DB_PASSWORD"
echo -e "- ENCRYPTION_KEY=$ENCRYPTION_KEY"
echo -e "- N8N_HOST=$N8N_HOST"
echo -e "- EDITOR_BASE_URL=$EDITOR_BASE_URL"
echo -e "- WEBHOOK_URL=$WEBHOOK_URL"
echo -e "- WEBHOOK_URL_FORMATADO=$WEBHOOK_URL_FORMATADO"
echo -e "- SMTP_SENDER=$SMTP_SENDER"
echo -e "- SMTP_USER=$SMTP_USER"
echo -e "- SMTP_PASS=$SMTP_PASS"
echo -e "- SMTP_HOST=$SMTP_HOST"
echo -e "- SMTP_PORT=$SMTP_PORT"
echo -e "- SMTP_SSL=$SMTP_SSL"
echo -e "- QUEUE_BULL_REDIS_HOST=$QUEUE_BULL_REDIS_HOST"

echo ""
## Mensagem de Passo
echo -e "\e[97m- INSTALANDO MCP DO N8N \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack n8n.yaml
cat > n8n${1:+_$1}_mcp.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  n8n${1:+_$1}_mcp:
    image: n8nio/n8n:latest ## Versao do N8N
    command: webhook

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - N8N_FIX_MIGRATIONS=true 
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n_queue${1:+_$1}
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=$DB_PASSWORD

      ## AAoA...AAa'AA'A Criptografia
      - N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY

      - N8N_HOST=$N8N_HOST
      - N8N_EDITOR_BASE_URL=$EDITOR_BASE_URL
      - WEBHOOK_URL=$WEBHOOK_URL
      - N8N_PROTOCOL=https
      - N8N_PROXY_HOPS=1
      - N8N_ONBOARDING_FLOW_DISABLED=true
      - N8N_BLOCK_ENV_ACCESS_IN_NODE=false
      - N8N_SKIP_AUTH_ON_OAUTH_CALLBACK=false

      - NODE_ENV=production
      - EXECUTIONS_MODE=queue
      - EXECUTIONS_TIMEOUT=3600
      - EXECUTIONS_TIMEOUT_MAX=7200
      - OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true
      - N8N_RUNNERS_ENABLED=true
      - N8N_RUNNERS_MODE=internal
      - N8N_RESTRICT_FILE_ACCESS_TO="~/.n8n-files"
      - NODES_EXCLUDE="[]"

      ##  Pacotes e Nos Comunitarios
      - N8N_REINSTALL_MISSING_PACKAGES=true
      - N8N_COMMUNITY_PACKAGES_ENABLED=true
      - N8N_NODE_PATH=/home/node/.n8n/nodes
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true

      ##  SMTP (Envio de E-mails)
      - N8N_SMTP_SENDER=$SMTP_SENDER
      - N8N_SMTP_USER=$SMTP_USER
      - N8N_SMTP_PASS=$SMTP_PASS
      - N8N_SMTP_HOST=$SMTP_HOST
      - N8N_SMTP_PORT=$SMTP_PORT
      - N8N_SMTP_SSL=$SMTP_SSL

      ## AAoA...AAa'AA'A Redis (Fila de ExecuA'A'AA'A'Ao)
      - QUEUE_BULL_REDIS_HOST=$QUEUE_BULL_REDIS_HOST
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=2

      ##  Metricas
      - N8N_METRICS=true

      ## AAA'AA'AAAA'AA'A ExecuA'A'AA'A'Aes e Limpeza
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=336

      ##  Recursos de IA
      - N8N_AI_ENABLED=false
      - N8N_AI_PROVIDER=openai
      - N8N_AI_OPENAI_API_KEY=

      ##  Permissoes em Funcoes Personalizadas
      - NODE_FUNCTION_ALLOW_BUILTIN=*
      - NODE_FUNCTION_ALLOW_EXTERNAL=moment,lodash

      ##  Fuso Horario
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - TZ=America/Sao_Paulo
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 2048M
      labels:
        - traefik.enable=true
        - traefik.http.middlewares.nogzip.headers.customResponseHeaders.Content-Encoding=
        - traefik.http.routers.n8n${1:+_$1}_mcp.rule=(Host(\`$WEBHOOK_URL_FORMATADO\`) && PathPrefix(\`/mcp\`)) ## Url do Webhook do N8N
        - traefik.http.routers.n8n${1:+_$1}_mcp.entrypoints=websecure
        - traefik.http.routers.n8n${1:+_$1}_mcp.priority=1
        - traefik.http.routers.n8n${1:+_$1}_mcp.middlewares=nogzip
        - traefik.http.routers.n8n${1:+_$1}_mcp.tls.certresolver=letsencryptresolver
        - traefik.http.routers.n8n${1:+_$1}_mcp.service=n8n${1:+_$1}_mcp
        - traefik.http.services.n8n${1:+_$1}_mcp.loadbalancer.server.port=5678
        - traefik.http.services.n8n${1:+_$1}_mcp.loadbalancer.passHostHeader=1

## --------------------------- FELSEN --------------------------- ##

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do MCP do N8N"
fi
STACK_NAME="n8n${1:+_$1}_mcp"
stack_editavel

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull n8nio/n8n:latest

wait_stack n8n${1:+_$1}_mcp_n8n${1:+_$1}_mcp


fix_webhook_url_mcp="${WEBHOOK_URL%/}"

cd dados_vps

cat > dados_n8n${1:+_$1}_mpc <<__FELSEN_MANAGED_FILE__
[ MCP DO N8N ]

Dominio do Webhook do MCP: $fix_webhook_url_mcp/mcp
__FELSEN_MANAGED_FILE__
cd
cd

## Espera 30 segundos
wait_30_sec

## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ MCP DO N8N ]\e[0m"
echo ""

echo -e "\e[33mDominio Webhook:\e[97m $fix_webhook_url_mcp/mcp\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}
