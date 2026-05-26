#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_n8n() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_n8n

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do N8N
    echo -e "\e[97mPasso$amarelo 1/7\e[0m"
    echo -en "\e[33mDigite o dominio para o N8N (ex: n8n.example.com): \e[0m" && read -r url_editorn8n
    echo ""
    
    ##Pergunta o Dominio do Webhook
    echo -e "\e[97mPasso$amarelo 2/7\e[0m"
    echo -en "\e[33mDigite o dominio para o Webhook do N8N (ex: webhook.example.com): \e[0m" && read -r url_webhookn8n
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 3/7\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_n8n
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 4/7\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_smtp_n8n
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 5/7\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_smtp_n8n
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 6/7\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_n8n
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 7/7\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_n8n
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ -z "$porta_smtp_n8n" ]; then
      smtp_secure_smtp_n8n=false
    else
      case "$porta_smtp_n8n" in
        465)
          smtp_secure_smtp_n8n=true
          ;;
        25|2525|587)
          smtp_secure_smtp_n8n=false
          ;;
        *)
          smtp_secure_smtp_n8n=false
          ;;
      esac
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_n8n
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do N8N
    echo -e "\e[33mDominio do N8N:\e[97m $url_editorn8n\e[0m"
    echo ""
    
    ## Informacao sobre URL do Webhook
    echo -e "\e[33mDominio para o Webhook:\e[97m $url_webhookn8n\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mEmail do SMTP:\e[97m $email_smtp_n8n\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mUsuario do SMTP:\e[97m $usuario_smtp_n8n\e[0m"
    echo ""

    ## Informacao sobre Senha do Email
    echo -e "\e[33mSenha do Email:\e[97m $senha_smtp_n8n\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP do Email:\e[97m $host_smtp_n8n\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP do Email:\e[97m $porta_smtp_n8n\e[0m"
    echo ""

    ## Informacao sobre Secure SMTP
    echo -e "\e[33mSecure SMTP do Email:\e[97m $smtp_secure_smtp_n8n\e[0m"
    echo ""
    
    read -p "As respostas estao corretas? (Y/N): " confirmacao
    if [ "$confirmacao" = "Y" ] || [ "$confirmacao" = "y" ]; then

        ## Digitou Y para confirmar que as informacoes estao corretas

        ## Limpar o terminal
        clear

        ## Mostrar mensagem de Instalando
        instalando_msg

        ## Sai do Loop
        break
    else

        ## Digitou N para dizer que as informacoes nao estao corretas.

        ## Limpar o terminal
        clear

        ## Mostra o nome da ferramenta
        nome_n8n

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO N8N \e[33m[1/4]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Verifica se tem postgres, se sim pega a senha e cria um banco nele, se nao instala, pega a senha e cria o banco
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "n8n_queue${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "n8n_queue${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO N8N \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
encryption_key=$(openssl rand -hex 16)

## Criando a stack n8n.yaml
cat > n8n${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  n8n${1:+_$1}_editor:
    image: n8nio/n8n:latest ## Versao do N8N
    command: start

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Banco de Dados (PostgreSQL)
      - N8N_FIX_MIGRATIONS=true 
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n_queue${1:+_$1}
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=$senha_postgres

    ## " Criptografia
      - N8N_ENCRYPTION_KEY=$encryption_key

      ##  URLs e Configuracoes de Acesso
      - N8N_HOST=$url_editorn8n
      - N8N_EDITOR_BASE_URL=https://$url_editorn8n/
      - WEBHOOK_URL=https://$url_webhookn8n/
      - N8N_PROTOCOL=https
      - N8N_PROXY_HOPS=1
      - N8N_ONBOARDING_FLOW_DISABLED=true
      - N8N_BLOCK_ENV_ACCESS_IN_NODE=false
      - N8N_SKIP_AUTH_ON_OAUTH_CALLBACK=false

    ## Ambiente de Execucao
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
      - N8N_SMTP_SENDER=$email_smtp_n8n
      - N8N_SMTP_USER=$usuario_smtp_n8n
      - N8N_SMTP_PASS=$senha_smtp_n8n
      - N8N_SMTP_HOST=$host_smtp_n8n
      - N8N_SMTP_PORT=$porta_smtp_n8n
      - N8N_SMTP_SSL=$smtp_secure_smtp_n8n

    ## " Redis (Fila de Execucao)
      - QUEUE_BULL_REDIS_HOST=n8n${1:+_$1}_redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=1

    ##  Metricas
      - N8N_METRICS=true

    ## Execucoes e Limpeza
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
      #- N8N_DEFAULT_LOCALE=pt-BR

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.n8n${1:+_$1}_editor.rule=Host(\`$url_editorn8n\`) ## Url do Editor do N8N
        - traefik.http.routers.n8n${1:+_$1}_editor.entrypoints=websecure
        - traefik.http.routers.n8n${1:+_$1}_editor.priority=10
        - traefik.http.routers.n8n${1:+_$1}_editor.tls.certresolver=letsencryptresolver
        - traefik.http.routers.n8n${1:+_$1}_editor.service=n8n${1:+_$1}_editor
        - traefik.http.services.n8n${1:+_$1}_editor.loadbalancer.server.port=5678
        - traefik.http.services.n8n${1:+_$1}_editor.loadbalancer.passHostHeader=1

## --------------------------- FELSEN --------------------------- ##

  n8n${1:+_$1}_webhook:
    image: n8nio/n8n:latest ## Versao do N8N
    command: webhook

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Banco de Dados (PostgreSQL)
      - N8N_FIX_MIGRATIONS=true 
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n_queue${1:+_$1}
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=$senha_postgres

    ## " Criptografia
      - N8N_ENCRYPTION_KEY=$encryption_key

      ##  URLs e Configuracoes de Acesso
      - N8N_HOST=$url_editorn8n
      - N8N_EDITOR_BASE_URL=https://$url_editorn8n/
      - WEBHOOK_URL=https://$url_webhookn8n/
      - N8N_PROTOCOL=https
      - N8N_PROXY_HOPS=1
      - N8N_ONBOARDING_FLOW_DISABLED=true
      - N8N_BLOCK_ENV_ACCESS_IN_NODE=false
      - N8N_SKIP_AUTH_ON_OAUTH_CALLBACK=false

    ## Ambiente de Execucao
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
      - N8N_SMTP_SENDER=$email_smtp_n8n
      - N8N_SMTP_USER=$usuario_smtp_n8n
      - N8N_SMTP_PASS=$senha_smtp_n8n
      - N8N_SMTP_HOST=$host_smtp_n8n
      - N8N_SMTP_PORT=$porta_smtp_n8n
      - N8N_SMTP_SSL=$smtp_secure_smtp_n8n

    ## " Redis (Fila de Execucao)
      - QUEUE_BULL_REDIS_HOST=n8n${1:+_$1}_redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=1

    ##  Metricas
      - N8N_METRICS=true

    ## Execucoes e Limpeza
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
      #- N8N_DEFAULT_LOCALE=pt-BR
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.n8n${1:+_$1}_webhook.rule=Host(\`$url_webhookn8n\`) ## Url do Webhook do N8N
        - traefik.http.routers.n8n${1:+_$1}_webhook.entrypoints=websecure
        - traefik.http.routers.n8n${1:+_$1}_webhook.priority=5
        - traefik.http.routers.n8n${1:+_$1}_webhook.tls.certresolver=letsencryptresolver
        - traefik.http.routers.n8n${1:+_$1}_webhook.service=n8n${1:+_$1}_webhook
        - traefik.http.services.n8n${1:+_$1}_webhook.loadbalancer.server.port=5678
        - traefik.http.services.n8n${1:+_$1}_webhook.loadbalancer.passHostHeader=1

## --------------------------- FELSEN --------------------------- ##

  n8n${1:+_$1}_worker:
    image: n8nio/n8n:latest ## Versao do N8N
    command: worker --concurrency=10

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Banco de Dados (PostgreSQL)
      - N8N_FIX_MIGRATIONS=true 
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n_queue${1:+_$1}
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=$senha_postgres

    ## " Criptografia
      - N8N_ENCRYPTION_KEY=$encryption_key

      ##  URLs e Configuracoes de Acesso
      - N8N_HOST=$url_editorn8n
      - N8N_EDITOR_BASE_URL=https://$url_editorn8n/
      - WEBHOOK_URL=https://$url_webhookn8n/
      - N8N_PROTOCOL=https
      - N8N_PROXY_HOPS=1
      - N8N_ONBOARDING_FLOW_DISABLED=true
      - N8N_BLOCK_ENV_ACCESS_IN_NODE=false
      - N8N_SKIP_AUTH_ON_OAUTH_CALLBACK=false

    ## Ambiente de Execucao
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
      - N8N_SMTP_SENDER=$email_smtp_n8n
      - N8N_SMTP_USER=$usuario_smtp_n8n
      - N8N_SMTP_PASS=$senha_smtp_n8n
      - N8N_SMTP_HOST=$host_smtp_n8n
      - N8N_SMTP_PORT=$porta_smtp_n8n
      - N8N_SMTP_SSL=$smtp_secure_smtp_n8n

    ## " Redis (Fila de Execucao)
      - QUEUE_BULL_REDIS_HOST=n8n${1:+_$1}_redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=1

    ##  Metricas
      - N8N_METRICS=true

    ## Execucoes e Limpeza
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
      #- N8N_DEFAULT_LOCALE=pt-BR
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  n8n${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - n8n${1:+_$1}_redis:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 6379:6379

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

volumes:
  n8n${1:+_$1}_redis:
    external: true
    name: n8n${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do N8N"
fi
STACK_NAME="n8n${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c n8n.yaml n8n > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do N8N"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest n8nio/n8n:latest

## Usa o servico wait_n8n para verificar se o servico esta online
wait_stack n8n${1:+_$1}_n8n${1:+_$1}_redis n8n${1:+_$1}_n8n${1:+_$1}_editor n8n${1:+_$1}_n8n${1:+_$1}_webhook n8n${1:+_$1}_n8n${1:+_$1}_worker


cd dados_vps

cat > dados_n8n${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ N8N ]

Dominio do N8N: https://$url_editorn8n

Dominio do Webhook do N8N: https://$url_webhookn8n

Email: Precisa criar no primeiro acesso do N8N

Senha: Precisa criar no primeiro acesso do N8N

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
echo -e "\e[32m[ N8N ]\e[0m"
echo ""

echo -e "\e[33mDominio Editor:\e[97m https://$url_editorn8n\e[0m"
echo ""

echo -e "\e[33mDominio Webhook:\e[97m https://$url_webhookn8n\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Precisa criar no primeiro acesso do N8N\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do N8N\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########      ####### ###    ######################
## a-a-a-"a-a-a-a-a-a-a-a-'     a-a-a-"a-a-a-a-a-a--a-a-a-'    a-a-a-'a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## ######  ##|     ##|   ##|##| ## ##|##|##############  
## a-a-a-"a-a-a-  a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  
## a-a-a-'     a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-     a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

