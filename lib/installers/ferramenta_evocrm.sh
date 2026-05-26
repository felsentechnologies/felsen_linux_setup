#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_evocrm() {

## Verifica os recursos
recursos 4 8 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_evocrm

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do Builder
    echo -e "\e[97mPasso$amarelo 1/7\e[0m"
    echo -en "\e[33mDigite o Dominio para o EvoCRM (ex: evocrm.example.com): \e[0m" && read -r url_evocrm_frontend
    echo ""

    ##Pergunta o Dominio do Viewer
    echo -e "\e[97mPasso$amarelo 2/7\e[0m"
    echo -en "\e[33mDigite o Dominio para a API do EvoCRM (ex: api-evocrm.example.com): \e[0m" && read -r url_evocrm_api
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 3/7\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_evocrm
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 4/7\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r username_smtp_evocrm
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 5/7\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_smtp_evocrm
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 6/7\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_evocrm
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 7/7\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r port_smtp_evocrm
    echo ""

    ## extrai o dominio do email
    if [[ "$email_smtp_evocrm" == *"@"* ]]; then
      domain_smtp_evocrm="${email_smtp_evocrm#*@}"  # Remove tudo ate o @
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_evocrm
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Builder
    echo -e "\e[33mDominio do EvoCRM:\e[97m $url_evocrm_frontend\e[0m"
    echo ""

    ## Informacao sobre URL do Viewer
    echo -e "\e[33mDominio da API do EvoCRM:\e[97m $url_evocrm_api\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mEmail do SMTP:\e[97m $email_smtp_evocrm\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mUsuario do SMTP:\e[97m $username_smtp_evocrm\e[0m"
    echo ""

    ## Informacao sobre Senha do Email
    echo -e "\e[33mSenha do Email:\e[97m $senha_smtp_evocrm\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP do Email:\e[97m $host_smtp_evocrm\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP do Email:\e[97m $port_smtp_evocrm\e[0m"
    echo ""

    ## Pergunta se as respostas estao corretas
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
        nome_evocrm

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done


## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO EVO CRM \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nada nada nada.. so para aparecer a mensagem de passo..

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO PGVECTOR \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

verificar_container_pgvector
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - pgvector ja instalado"
    pegar_senha_pgvector > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do PgVector"
    criar_banco_pgvector_da_stack "evocrm${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_pgvector
    pegar_senha_pgvector > /dev/null 2>&1
    criar_banco_pgvector_da_stack "evocrm${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO EVO CRM \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
secret_key_base_evocrm=$(openssl rand -hex 64)
jwt_secret_evocrm=$(openssl rand -hex 32)
evoai_crm_api_token=$(openssl rand -hex 32)
doorkeeper_jwt_secret_key=$(openssl rand -hex 32)
bot_runtime_secret=$(openssl rand -hex 32)
apt install python3 -y > /dev/null 2>&1
encryption_key=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")

## Criando a stack evocrm.yaml
cat > evocrm${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_gateway:
    image: evoapicloud/evo-crm-gateway:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:                                                                                                                                              
      - AUTH_UPSTREAM=evocrm${1:+_$1}_auth:3001                                                                                                                         
      - CRM_UPSTREAM=evocrm${1:+_$1}_crm:3000                                                                                                                           
      - CORE_UPSTREAM=evocrm${1:+_$1}_core:5555                       
      - PROCESSOR_UPSTREAM=evocrm${1:+_$1}_processor:8000                                                                                                               
      - BOT_RUNTIME_UPSTREAM=evocrm${1:+_$1}_bot_runtime:8080

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=1
        - traefik.docker.network=$nome_rede_interna ## Nome da rede interna
        - traefik.http.routers.evocrm${1:+_$1}_gateway.rule=Host(\`$url_evocrm_api\`) ##&& (PathPrefix(\`/api/v1/auth\`) || PathPrefix(\`/api\`) || PathPrefix(\`/rails\`) || PathPrefix(\`/setup\`) || PathPrefix(\`/oauth\`) || PathPrefix(\`/cable\`) || PathPrefix(\`/.well-known\`) || PathPrefix(\`/webhooks\`) || PathPrefix(\`/bot\`) || PathPrefix(\`/platform\`)) ## Dominio API (gateway)
        - traefik.http.routers.evocrm${1:+_$1}_gateway.entrypoints=websecure
        - traefik.http.routers.evocrm${1:+_$1}_gateway.priority=1
        - traefik.http.routers.evocrm${1:+_$1}_gateway.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evocrm${1:+_$1}_gateway.service=evocrm${1:+_$1}_gateway
        - traefik.http.services.evocrm${1:+_$1}_gateway.loadbalancer.server.port=3030
        - traefik.http.services.evocrm${1:+_$1}_gateway.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_auth:
    image: evoapicloud/evo-auth-service-community:latest
    command: bash -c "bundle exec rails db:migrate && bundle exec rails s -p 3001 -b 0.0.0.0"
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ## Rails (ambiente)
      - RAILS_ENV=production
      - RAILS_MAX_THREADS=5

    ## " Segredos e tokens
      - SECRET_KEY_BASE=$secret_key_base_evocrm
      - JWT_SECRET_KEY=$jwt_secret_evocrm
      - EVOAI_CRM_API_TOKEN=$evoai_crm_api_token

    ## -"i PostgreSQL
      - POSTGRES_HOST=pgvector
      - POSTGRES_PORT=5432
      - POSTGRES_USERNAME=postgres
      - POSTGRES_PASSWORD=$senha_pgvector
      - POSTGRES_DATABASE=evocrm${1:+_$1}
      - POSTGRES_SSLMODE=disable

    ##  Redis
      - REDIS_URL=redis://evocrm${1:+_$1}_redis:6379/1

    ##  URLs pAoblicas e CORS
      - FRONTEND_URL=https://$url_evocrm_frontend
      - BACKEND_URL=https://$url_evocrm_api
      - CORS_ORIGINS=https://$url_evocrm_frontend,https://$url_evocrm_api

    ## E-mail (Mailer + SMTP)
      - SMTP_DOMAIN=$domain_smtp_evocrm
      - MAILER_SENDER_EMAIL=$email_smtp_evocrm
      - SMTP_USERNAME=$username_smtp_evocrm
      - SMTP_PASSWORD=$senha_smtp_evocrm
      - SMTP_ADDRESS=$host_smtp_evocrm
      - SMTP_PORT=$port_smtp_evocrm
      - SMTP_AUTHENTICATION=plain
      - SMTP_ENABLE_STARTTLS_AUTO=true

    ##  Doorkeeper (OAuth / JWT)
      - DOORKEEPER_JWT_SECRET_KEY=$jwt_secret_evocrm
      - DOORKEEPER_JWT_ALGORITHM=hs256
      - DOORKEEPER_JWT_ISS=evo-auth-service

    ##  MFA e filas
      - MFA_ISSUER=EvoCRM
      - SIDEKIQ_CONCURRENCY=10
      - ACTIVE_STORAGE_SERVICE=local
    
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_auth_sidekiq:
    image: evoapicloud/evo-auth-service-community:latest
    command: ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Rails (ambiente)
      - RAILS_ENV=production

    ## " Segredos e tokens
      - SECRET_KEY_BASE=$secret_key_base_evocrm
      - JWT_SECRET_KEY=$jwt_secret_evocrm
      - EVOAI_CRM_API_TOKEN=$evoai_crm_api_token

    ## -"i PostgreSQL
      - POSTGRES_HOST=pgvector
      - POSTGRES_PORT=5432
      - POSTGRES_USERNAME=postgres
      - POSTGRES_PASSWORD=$senha_pgvector
      - POSTGRES_DATABASE=evocrm${1:+_$1}
      - POSTGRES_SSLMODE=disable

    ##  Redis
      - REDIS_URL=redis://evocrm${1:+_$1}_redis:6379/1

    ##  CORS
      - FRONTEND_URL=https://$url_evocrm_frontend
      - BACKEND_URL=https://$url_evocrm_api
      - CORS_ORIGINS=https://$url_evocrm_frontend,https://$url_evocrm_api

    ## E-mail (Mailer + SMTP)
      - SMTP_DOMAIN=$domain_smtp_evocrm
      - MAILER_SENDER_EMAIL=$email_smtp_evocrm
      - SMTP_USERNAME=$username_smtp_evocrm
      - SMTP_PASSWORD=$senha_smtp_evocrm
      - SMTP_ADDRESS=$host_smtp_evocrm
      - SMTP_PORT=$port_smtp_evocrm
      - SMTP_AUTHENTICATION=plain
      - SMTP_ENABLE_STARTTLS_AUTO=true

    ##  Doorkeeper (OAuth / JWT)
      - DOORKEEPER_JWT_SECRET_KEY=$jwt_secret_evocrm
      - DOORKEEPER_JWT_ALGORITHM=hs256
      - DOORKEEPER_JWT_ISS=evo-auth-service

    ##  MFA e filas
      - MFA_ISSUER=EvoCRM
      - SIDEKIQ_CONCURRENCY=10
      - ACTIVE_STORAGE_SERVICE=local
    
    healthcheck:
      disable: true
    
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_crm:
    image: evoapicloud/evo-ai-crm-community:latest
    command: sh -c "until wget -qO- http://evocrm${1:+_$1}_auth:3001/health >/dev/null 2>&1; do echo 'Waiting for auth...'; sleep 5; done; bundle exec rails db:migrate && bundle exec rails s -p 3000 -b 0.0.0.0"
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Rails (ambiente e logs)
      - RAILS_ENV=production
      - RAILS_SERVE_STATIC_FILES=true
      - RAILS_LOG_TO_STDOUT=true

    ## " Segredos e tokens
      - SECRET_KEY_BASE=$secret_key_base_evocrm
      - JWT_SECRET_KEY=$jwt_secret_evocrm
      - EVOAI_CRM_API_TOKEN=$evoai_crm_api_token

    ## -"i PostgreSQL
      - POSTGRES_HOST=pgvector
      - POSTGRES_PORT=5432
      - POSTGRES_USERNAME=postgres
      - POSTGRES_PASSWORD=$senha_pgvector
      - POSTGRES_DATABASE=evocrm${1:+_$1}
      - POSTGRES_SSLMODE=disable

    ##  Redis
      - REDIS_URL=redis://evocrm${1:+_$1}_redis:6379/1

    ##  Servicos internos (Auth + Core)
      - EVO_AUTH_SERVICE_URL=http://evocrm${1:+_$1}_auth:3001
      - EVO_AI_CORE_SERVICE_URL=http://evocrm${1:+_$1}_core:5555

    ##  URLs pAoblicas e CORS
      - BACKEND_URL=https://$url_evocrm_api
      - FRONTEND_URL=https://$url_evocrm_frontend
      - CORS_ORIGINS=https://$url_evocrm_frontend,https://$url_evocrm_api
    
    ##  rastreamento e logs
      - DISABLE_TELEMETRY=true
      - LOG_LEVEL=info
    
    ##  Funcionalidades da aplicacao
      - ENABLE_ACCOUNT_SIGNUP=true
      - ENABLE_PUSH_RELAY_SERVER=true
      - ENABLE_INBOX_EVENTS=true
    
    ##  Bot runtime
      - BOT_RUNTIME_URL=http://evocrm${1:+_$1}_bot_runtime:8080
      - BOT_RUNTIME_SECRET=$bot_runtime_secret
      - BOT_RUNTIME_POSTBACK_BASE_URL=http://evocrm${1:+_$1}_crm:3000
    
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_crm_sidekiq:
    image: evoapicloud/evo-ai-crm-community:latest
    command: ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Rails (ambiente)
      - RAILS_ENV=production
    
    ## " Segredos e tokens
      - SECRET_KEY_BASE=$secret_key_base_evocrm
      - JWT_SECRET_KEY=$jwt_secret_evocrm
      - EVOAI_CRM_API_TOKEN=$evoai_crm_api_token
    
    ## -"i PostgreSQL
      - POSTGRES_HOST=pgvector
      - POSTGRES_PORT=5432
      - POSTGRES_USERNAME=postgres
      - POSTGRES_PASSWORD=$senha_pgvector
      - POSTGRES_DATABASE=evocrm${1:+_$1}
      - POSTGRES_SSLMODE=disable
    
    ##  Redis
      - REDIS_URL=redis://evocrm${1:+_$1}_redis:6379/1
    
    ##  Servicos internos (Auth + Core)
      - EVO_AUTH_SERVICE_URL=http://evocrm${1:+_$1}_auth:3001
      - EVO_AI_CORE_SERVICE_URL=http://evocrm${1:+_$1}_core:5555
    
    ##  CORS
      - BACKEND_URL=https://$url_evocrm_api
      - FRONTEND_URL=https://$url_evocrm_frontend
      - CORS_ORIGINS=https://$url_evocrm_frontend,https://$url_evocrm_api
    
    ##  Bot runtime
      - BOT_RUNTIME_URL=http://evocrm${1:+_$1}_bot_runtime:8080
      - BOT_RUNTIME_SECRET=$bot_runtime_secret
      - BOT_RUNTIME_POSTBACK_BASE_URL=http://evocrm${1:+_$1}_crm:3000
    
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_core:
    image: evoapicloud/evo-ai-core-service-community:latest
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i PostgreSQL (conexao)
      - DB_HOST=pgvector
      - DB_PORT=5432
      - DB_USER=postgres
      - DB_PASSWORD=$senha_pgvector
      - DB_NAME=evocrm${1:+_$1}
      - DB_SSLMODE=disable
    
    ##  Pool de conexoes
      - DB_MAX_IDLE_CONNS=10
      - DB_MAX_OPEN_CONNS=100
      - DB_CONN_MAX_LIFETIME=1h
      - DB_CONN_MAX_IDLE_TIME=30m
    
    ##  API (porta)
      - PORT=5555
    
    ## " Segredos e JWT
      - SECRET_KEY_BASE=$secret_key_base_evocrm
      - JWT_SECRET_KEY=$jwt_secret_evocrm
      - JWT_ALGORITHM=HS256
      - ENCRYPTION_KEY=$encryption_key
    
    ##  Servicos internos
      - EVOLUTION_BASE_URL=http://evocrm${1:+_$1}_crm:3000
      - EVO_AUTH_BASE_URL=http://evocrm${1:+_$1}_auth:3001
      - AI_PROCESSOR_URL=http://evocrm${1:+_$1}_processor:8000
      - AI_PROCESSOR_VERSION=v1
    
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_processor:
    image: evoapicloud/evo-ai-processor-community:latest
    command: sh -c "alembic upgrade head 2>&1 || echo 'Alembic migration had errors, continuing...'; python -m scripts.run_seeders; uvicorn src.main:app --host \$\$HOST --port \$\$PORT"
    
    volumes:
      - evocrm${1:+_$1}_processor_logs:/app/logs
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i PostgreSQL
      - POSTGRES_CONNECTION_STRING=postgresql://postgres:$senha_pgvector@pgvector:5432/evocrm${1:+_$1}?sslmode=disable
    
    ##  Redis
      - REDIS_HOST=evocrm${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=
      - REDIS_SSL=false
      - REDIS_DB=0
      - REDIS_KEY_PREFIX=a2a_
      - REDIS_TTL=3600
    
    ##  Uvicorn (host / porta)
      - HOST=0.0.0.0
      - PORT=8000
    
    ##  Debug e segredos
      - DEBUG=false
      - SECRET_KEY_BASE=$secret_key_base_evocrm
      - ENCRYPTION_KEY=$encryption_key
      - JWT_SECRET_KEY=$jwt_secret_evocrm
      - EVOAI_CRM_API_TOKEN=$evoai_crm_api_token
    
    ##  Integracao CRM e Core
      - EVO_AUTH_BASE_URL=http://evocrm${1:+_$1}_auth:3001
      - EVO_AI_CRM_URL=http://evocrm${1:+_$1}_crm:3000
      - CORE_SERVICE_URL=http://evocrm${1:+_$1}_core:5555/api/v1
   
    ##  URLs pAoblicas da API
      - APP_URL=https://$url_evocrm_api
      - API_URL=https://$url_evocrm_api
    
    ##  Metadados da API (OpenAPI)
      - API_TITLE=Agent Processor Community
      - API_DESCRIPTION=Agent Processor Community for Evo AI
      - API_VERSION=1.0.0
      - ORGANIZATION_NAME=Evo CRM
    
    ## -i Cache de tools
      - TOOLS_CACHE_ENABLED=true
      - TOOLS_CACHE_TTL=3600
    
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_bot_runtime:
    image: evoapicloud/evo-bot-runtime:latest
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
      
    environment:
    ##  Rede (listen)
      - LISTEN_ADDR=0.0.0.0:8080
    
    ##  Redis
      - REDIS_URL=redis://evocrm${1:+_$1}_redis:6379/1
    
    ##  Processor e seguranca
      - AI_PROCESSOR_URL=http://evocrm${1:+_$1}_processor:8000
      - BOT_RUNTIME_SECRET=$bot_runtime_secret
      - AI_CALL_TIMEOUT_SECONDS=30
    
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_frontend:
    image: evoapicloud/evo-ai-frontend-community:latest
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Vite (ambiente)
      - VITE_APP_ENV=production
    
    ##  URLs da API (build-time)
      - VITE_API_URL=https://$url_evocrm_api
      - VITE_AUTH_API_URL=https://$url_evocrm_api
      - VITE_EVOAI_API_URL=https://$url_evocrm_api
      - VITE_AGENT_PROCESSOR_URL=https://$url_evocrm_api
      - VITE_WS_URL=https://$url_evocrm_api
      
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=1
        - traefik.docker.network=$nome_rede_interna ## Nome da rede interna
        - traefik.http.routers.evocrm${1:+_$1}_frontend.rule=Host(\`$url_evocrm_frontend\`) ## Dominio frontend (React)
        - traefik.http.routers.evocrm${1:+_$1}_frontend.entrypoints=websecure
        - traefik.http.routers.evocrm${1:+_$1}_frontend.priority=1
        - traefik.http.routers.evocrm${1:+_$1}_frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evocrm${1:+_$1}_frontend.service=evocrm${1:+_$1}_frontend
        - traefik.http.services.evocrm${1:+_$1}_frontend.loadbalancer.server.port=80
        - traefik.http.services.evocrm${1:+_$1}_frontend.loadbalancer.passHostHeader=true
        
## --------------------------- FELSEN --------------------------- ##

  evocrm${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]
    
    volumes:
      - evocrm${1:+_$1}_redis:/data
    
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
  evocrm${1:+_$1}_processor_logs:
    external: true
    name: evocrm${1:+_$1}_processor_logs
  evocrm${1:+_$1}_redis:
    external: true
    name: evocrm${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do EVO CRM"
fi
STACK_NAME="evocrm${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c evocrm.yaml evocrm > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do EVOCRM"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest evoapicloud/evo-auth-service-community:latest evoapicloud/evo-ai-crm-community:latest evoapicloud/evo-ai-core-service-community:latest evoapicloud/evo-ai-processor-community:latest evoapicloud/evo-bot-runtime:latest evoapicloud/evo-crm-gateway:latest evoapicloud/evo-ai-frontend-community:latest

## Usa o servico wait_EVOCRM para verificar se o servico esta online
wait_stack evocrm${1:+_$1}_evocrm${1:+_$1}_redis evocrm${1:+_$1}_evocrm${1:+_$1}_auth evocrm${1:+_$1}_evocrm${1:+_$1}_auth_sidekiq evocrm${1:+_$1}_evocrm${1:+_$1}_crm evocrm${1:+_$1}_evocrm${1:+_$1}_crm_sidekiq evocrm${1:+_$1}_evocrm${1:+_$1}_core evocrm${1:+_$1}_evocrm${1:+_$1}_processor evocrm${1:+_$1}_evocrm${1:+_$1}_bot_runtime evocrm${1:+_$1}_evocrm${1:+_$1}_gateway evocrm${1:+_$1}_evocrm${1:+_$1}_frontend 


cd dados_vps

cat > dados_evocrm${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ EVO CRM ]

Dominio do EvoCRM: https://$url_evocrm_frontend

Dominio da API do EvoCRM: https://$url_evocrm_api
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
echo -e "\e[32m[ EVO CRM ]\e[0m"
echo ""

echo -e "\e[33mDominio do EvoCRM:\e[97m https://$url_evocrm_frontend\e[0m"
echo ""

echo -e "\e[33mDominio da API do EvoCRM:\e[97m https://$url_evocrm_api\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   #### ##############     ####   ### ###### ####   ###
## a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--    a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'
## a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-'     a-a-a-a-a-a-a-"a-    a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-- a-a-a-'
## a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-     a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'         a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'
## a-a-a-     a-a-a- a-a-a-a-a-a-a-a-a-a-         a-a-a-  a-a-a-a-a- a-a-a-a-a-a- a-a-a-  a-a-a-a-a-

