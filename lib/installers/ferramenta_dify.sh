#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_dify() {

## Verifica os recursos
recursos 2 4 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_dify

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do Dify AI
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o Dify AI (ex: dify.example.com): \e[0m" && read -r url_dify
    echo ""

    ##Pergunta o Dominio do Dify AI
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -en "\e[33mDigite o dominio para o API do Dify AI (ex: api-dify.example.com): \e[0m" && read -r url_dify_api
    echo ""

    ##Pergunta o Dominio do Qdrant
    #read -r ip _ <<<$(hostname -I)
    #echo -e "\e[97mPasso$amarelo 2/10\e[0m"
    #echo -en "\e[33mDigite o dominio do Qdrant (ex: http://$ip  ou http://qdrant.example.com): \e[0m" && read -r url_quedrant
    #echo ""

    ##Pergunta a Api Key do Qdrant
    #key_dify_rand=$(openssl rand -hex 16)
    #echo -e "\e[97mPasso$amarelo 3/10\e[0m"
    #echo -en "\e[33mDigite a Api Key do Qdrant (ex: $key_dify_rand): \e[0m" && read -r apikey_qdrant
    #echo ""

   ###Pergunta o Email SMTP
   #echo -e "\e[97mPasso$amarelo 3/7\e[0m"
   #echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_dify
   #echo ""
    

    ###Pergunta o usuario do Email SMTP
    #echo -e "\e[97mPasso$amarelo 4/7\e[0m"
    #echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    #echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_email_dify
    #echo ""
#
    ### Pergunta a senha do SMTP
    #echo -e "\e[97mPasso$amarelo 5/7\e[0m"
    #echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    #echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_dify
    #echo ""
#
    ### Pergunta o Host SMTP do email
    #echo -e "\e[97mPasso$amarelo 6/7\e[0m"
    #echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_dify
    #echo ""
#
    ### Pergunta a porta SMTP do email
    #echo -e "\e[97mPasso$amarelo 7/7\e[0m"
    #echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_dify
    #echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_dify
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Builder
    echo -e "\e[33mDominio do Dify AI:\e[97m $url_dify\e[0m"
    echo ""

    ## Informacao sobre URL do API do Dify AI
    echo -e "\e[33mDominio do API do Dify AI:\e[97m $url_dify_api\e[0m"
    echo ""

    ## Informacao sobre URL do Viewer
    #echo -e "\e[33mDominio do Qdrant:\e[97m $url_quedrant\e[0m"
    #echo ""

    ## Informacao sobre a versao da ferramenta
    #echo -e "\e[33mApi Key Qdrant:\e[97m $apikey_qdrant\e[0m"
    #echo ""    

    ### Informacao sobre Email
    #echo -e "\e[33mEmail do SMTP:\e[97m $email_dify\e[0m"
    #echo ""
#
    ### Informacao sobre UserSMTP
    #echo -e "\e[33mUser do SMTP:\e[97m $user_email_dify\e[0m"
    #echo ""
#
    ### Informacao sobre Senha do Email
    #echo -e "\e[33mSenha do Email:\e[97m $senha_email_dify\e[0m"
    #echo ""
#
    ### Informacao sobre Host SMTP
    #echo -e "\e[33mHost SMTP do Email:\e[97m $smtp_email_dify\e[0m"
    #echo ""
#
    ### Informacao sobre Porta SMTP
    #echo -e "\e[33mPorta SMTP do Email:\e[97m $porta_smtp_dify\e[0m"
    #echo ""

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
        nome_dify

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO DIFY \e[33m[1/5]\e[0m"
echo ""
sleep 1


cd

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/5]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "dify${1:+_$1}"
    criar_banco_postgres_da_stack "dify${1:+_$1}_plugin"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "dify${1:+_$1}"
    criar_banco_postgres_da_stack "dify${1:+_$1}_plugin"
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[3/5]\e[0m"
echo ""
sleep 1

pegar_senha_minio

minio.bucket dify${1:+-$1} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
else
    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
    echo ""
fi
echo ""

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO DIFY \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
secret_key=$(openssl rand -hex 16)
sandbox_api_key=$(openssl rand -hex 16)
token_weaviate=$(openssl rand -hex 16)
token_apikey_plugins=$(openssl rand -hex 16)
token_deamon=$(openssl rand -hex 16)
sandbox_key=$(openssl rand -hex 16)
cookie_domain="$(echo "$url_dify_api" | sed 's/^[^.]\+//')"

## Criando a stack dify.yaml
cat > dify${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: '3.7'
services:

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_api:
    image: langgenius/dify-api:latest

    volumes:
      - dify${1:+_$1}_storage:/app/api/storage

    networks:
      - $nome_rede_interna
      - dify${1:+_$1}_ssrf_proxy_network

    environment:
      ## Ao'A URLs e Endpoints
      - CONSOLE_API_URL=https://$url_dify_api/console/api
      - CONSOLE_WEB_URL=https://$url_dify
      - SERVICE_API_URL=https://$url_dify_api/service/api
      - TRIGGER_URL=https://$url_dify_api/triggers
      - APP_API_URL=https://$url_dify_api/api
      - APP_WEB_URL=https://$url_dify
      - FILES_URL=https://$url_dify_api/files
      - INTERNAL_FILES_URL=http://dify${1:+_$1}_api:5001/files
      - CHECK_UPDATE_URL=https://updates.dify.ai
      - OPENAI_API_BASE=https://api.openai.com/v1

      ## Ao'A LocalizaAAAAo e Idioma
      - LANG=en_US.UTF-8
      - LC_ALL=en_US.UTF-8
      - PYTHONIOENCODING=utf-8

      - LOG_LEVEL=INFO
      - LOG_FILE=/app/logs/server.log
      - LOG_FILE_MAX_SIZE=20
      - LOG_FILE_BACKUP_COUNT=5
      - LOG_DATEFORMAT=%Y-%m-%d %H:%M:%S
      - LOG_TZ=UTC
      - DEBUG=false
      - FLASK_DEBUG=false
      - ENABLE_REQUEST_LOGGING=False

      - SECRET_KEY=$secret_key
      - ACCESS_TOKEN_EXPIRE_MINUTES=60
      - REFRESH_TOKEN_EXPIRE_DAYS=30

      ## Aa"AAA ConfiguraAAAAo do Servidor
      - DEPLOY_ENV=PRODUCTION
      - DIFY_BIND_ADDRESS=0.0.0.0
      - DIFY_PORT=5001
      - SERVER_WORKER_AMOUNT=1
      - SERVER_WORKER_CLASS=gevent
      - SERVER_WORKER_CONNECTIONS=10
      - GUNICORN_TIMEOUT=360
      - MIGRATION_ENABLED=true
      - FILES_ACCESS_TIMEOUT=300
      - APP_DEFAULT_ACTIVE_REQUESTS=0
      - APP_MAX_ACTIVE_REQUESTS=0
      - APP_MAX_EXECUTION_TIME=1200
      - RESPECT_XFORWARD_HEADERS_ENABLED=true

      ## AoaEURaEUR Celery e Workers
      - CELERY_WORKER_CLASS=
      - CELERY_WORKER_AMOUNT=
      - CELERY_AUTO_SCALE=false
      - CELERY_MAX_WORKERS=
      - CELERY_MIN_WORKERS=

      ## AoaEURoAAAA API Tools
      - API_TOOL_DEFAULT_CONNECT_TIMEOUT=10
      - API_TOOL_DEFAULT_READ_TIMEOUT=60

      ## Ao'A Website Crawlers
      - ENABLE_WEBSITE_JINAREADER=true
      - ENABLE_WEBSITE_FIRECRAWL=true
      - ENABLE_WEBSITE_WATERCRAWL=true

      ##  Frontend
      - NEXT_PUBLIC_ENABLE_SINGLE_DOLLAR_LATEX=false

      - DB_TYPE=postgresql
      - DB_USERNAME=postgres
      - DB_PASSWORD=$senha_postgres
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_DATABASE=dify${1:+_$1}
      - SQLALCHEMY_POOL_SIZE=30
      - SQLALCHEMY_MAX_OVERFLOW=10
      - SQLALCHEMY_POOL_RECYCLE=3600
      - SQLALCHEMY_ECHO=false
      - SQLALCHEMY_POOL_PRE_PING=false
      - SQLALCHEMY_POOL_USE_LIFO=false
      - SQLALCHEMY_POOL_TIMEOUT=30

      ##  Redis
      - REDIS_HOST=dify${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_USERNAME=
      - REDIS_PASSWORD=
      - REDIS_USE_SSL=false
      - REDIS_DB=0
      - CELERY_BROKER_URL=redis://dify${1:+_$1}_redis:6379/1
      - CELERY_BACKEND=redis

      ## AoAAa Cookies e CORS
      - WEB_API_CORS_ALLOW_ORIGINS=https://$url_dify
      - CONSOLE_CORS_ALLOW_ORIGINS=https://$url_dify
      - COOKIE_DOMAIN=$cookie_domain
      - NEXT_PUBLIC_COOKIE_DOMAIN=$cookie_domain

      ##  Storage
      - STORAGE_TYPE=s3
      - S3_ENDPOINT=https://$url_s3
      - S3_BUCKET_NAME=dify${1:+-$1}
      - S3_ACCESS_KEY=$S3_ACCESS_KEY
      - S3_SECRET_KEY=$S3_SECRET_KEY
      - S3_REGION=eu-south
      - S3_ADDRESS_STYLE=path
      - S3_USE_AWS_MANAGED_IAM=false

      - VECTOR_STORE=weaviate
      - VECTOR_INDEX_NAME_PREFIX=Vector_index
      - WEAVIATE_ENDPOINT=http://dify${1:+_$1}_weaviate:8080
      - WEAVIATE_API_KEY=$token_weaviate
      - WEAVIATE_GRPC_ENDPOINT=grpc://dify${1:+_$1}_weaviate:50051
      - WEAVIATE_TOKENIZATION=word

      ## Ao'A Traefik
      - TRAEFIK_DOMAIN=$url_dify_api

      ##  Modo e Sentry
      - MODE=api
      - SENTRY_DSN=
      - SENTRY_TRACES_SAMPLE_RATE=1.0
      - SENTRY_PROFILES_SAMPLE_RATE=1.0

      ## AoaEUR' Plugins
      - PLUGIN_DAEMON_URL=http://dify${1:+_$1}_plugin_daemon:5002
      - PLUGIN_DAEMON_KEY=$token_deamon
      - PLUGIN_REMOTE_INSTALL_HOST=localhost
      - PLUGIN_REMOTE_INSTALL_PORT=5003
      - PLUGIN_MAX_PACKAGE_SIZE=52428800
      - INNER_API_KEY_FOR_PLUGIN=$token_apikey_plugins

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M
      labels:
        - traefik.enable=true
        - traefik.docker.network=$nome_rede_interna
        - traefik.http.routers.dify${1:+_$1}_api.rule=Host(\`$url_dify_api\`) && !PathPrefix(\`/service/api\`)
        - traefik.http.routers.dify${1:+_$1}_api.entrypoints=websecure
        - traefik.http.routers.dify${1:+_$1}_api.tls.certresolver=letsencryptresolver
        - traefik.http.routers.dify${1:+_$1}_api.tls=true
        - traefik.http.routers.dify${1:+_$1}_api.service=dify${1:+_$1}_api
        - traefik.http.services.dify${1:+_$1}_api.loadbalancer.server.port=5001
        - traefik.http.services.dify${1:+_$1}_api.loadbalancer.passHostHeader=true
        - traefik.http.routers.dify${1:+_$1}_api_service.rule=Host(\`$url_dify_api\`) && PathPrefix(\`/service/api\`)
        - traefik.http.routers.dify${1:+_$1}_api_service.entrypoints=websecure
        - traefik.http.routers.dify${1:+_$1}_api_service.tls.certresolver=letsencryptresolver
        - traefik.http.routers.dify${1:+_$1}_api_service.tls=true
        - traefik.http.routers.dify${1:+_$1}_api_service.service=dify${1:+_$1}_api
        - traefik.http.routers.dify${1:+_$1}_api_service.priority=20
        - traefik.http.middlewares.dify${1:+_$1}_api_stripprefix.stripprefix.prefixes=/service/api
        - traefik.http.middlewares.dify${1:+_$1}_api_stripprefix.stripprefix.forceSlash=false
        - traefik.http.routers.dify${1:+_$1}_api_service.middlewares=dify${1:+_$1}_api_stripprefix

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_worker:
    image: langgenius/dify-api:latest

    volumes:
      - dify${1:+_$1}_storage:/app/api/storage

    networks:
      - $nome_rede_interna
      - dify${1:+_$1}_ssrf_proxy_network

    environment:
      ## Ao'A URLs e Endpoints
      - CONSOLE_API_URL=https://$url_dify_api/console/api
      - CONSOLE_WEB_URL=https://$url_dify
      - SERVICE_API_URL=https://$url_dify_api/service/api
      - TRIGGER_URL=https://$url_dify_api/triggers
      - APP_API_URL=https://$url_dify_api/api
      - APP_WEB_URL=https://$url_dify
      - FILES_URL=https://$url_dify_api/files
      - INTERNAL_FILES_URL=http://dify${1:+_$1}_api:5001/files
      - CHECK_UPDATE_URL=https://updates.dify.ai
      - OPENAI_API_BASE=https://api.openai.com/v1

      ## Ao'A LocalizaAAAAo e Idioma
      - LANG=en_US.UTF-8
      - LC_ALL=en_US.UTF-8
      - PYTHONIOENCODING=utf-8

      - LOG_LEVEL=INFO
      - LOG_FILE=/app/logs/server.log
      - LOG_FILE_MAX_SIZE=20
      - LOG_FILE_BACKUP_COUNT=5
      - LOG_DATEFORMAT=%Y-%m-%d %H:%M:%S
      - LOG_TZ=UTC
      - DEBUG=false
      - FLASK_DEBUG=false
      - ENABLE_REQUEST_LOGGING=False

      - SECRET_KEY=$secret_key
      - ACCESS_TOKEN_EXPIRE_MINUTES=60
      - REFRESH_TOKEN_EXPIRE_DAYS=30

      ## Aa"AAA ConfiguraAAAAo do Servidor
      - DEPLOY_ENV=PRODUCTION
      - DIFY_BIND_ADDRESS=0.0.0.0
      - DIFY_PORT=5001
      - SERVER_WORKER_AMOUNT=1
      - SERVER_WORKER_CLASS=gevent
      - SERVER_WORKER_CONNECTIONS=10
      - GUNICORN_TIMEOUT=360
      - MIGRATION_ENABLED=true
      - FILES_ACCESS_TIMEOUT=300
      - APP_DEFAULT_ACTIVE_REQUESTS=0
      - APP_MAX_ACTIVE_REQUESTS=0
      - APP_MAX_EXECUTION_TIME=1200

      ## AoaEURaEUR Celery e Workers
      - CELERY_WORKER_CLASS=
      - CELERY_WORKER_AMOUNT=
      - CELERY_AUTO_SCALE=false
      - CELERY_MAX_WORKERS=
      - CELERY_MIN_WORKERS=

      ## AoaEURoAAAA API Tools
      - API_TOOL_DEFAULT_CONNECT_TIMEOUT=10
      - API_TOOL_DEFAULT_READ_TIMEOUT=60

      ## Ao'A Website Crawlers
      - ENABLE_WEBSITE_JINAREADER=true
      - ENABLE_WEBSITE_FIRECRAWL=true
      - ENABLE_WEBSITE_WATERCRAWL=true

      ##  Frontend
      - NEXT_PUBLIC_ENABLE_SINGLE_DOLLAR_LATEX=false

      - DB_TYPE=postgresql
      - DB_USERNAME=postgres
      - DB_PASSWORD=$senha_postgres
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_DATABASE=dify${1:+_$1}
      - SQLALCHEMY_POOL_SIZE=30
      - SQLALCHEMY_MAX_OVERFLOW=10
      - SQLALCHEMY_POOL_RECYCLE=3600
      - SQLALCHEMY_ECHO=false
      - SQLALCHEMY_POOL_PRE_PING=false
      - SQLALCHEMY_POOL_USE_LIFO=false
      - SQLALCHEMY_POOL_TIMEOUT=30

      ##  Redis
      - REDIS_HOST=dify${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_USERNAME=
      - REDIS_PASSWORD=
      - REDIS_USE_SSL=false
      - REDIS_DB=0
      - CELERY_BROKER_URL=redis://dify${1:+_$1}_redis:6379/1
      - CELERY_BACKEND=redis

      ## AoAAa Cookies e CORS
      - WEB_API_CORS_ALLOW_ORIGINS=https://$url_dify
      - CONSOLE_CORS_ALLOW_ORIGINS=https://$url_dify
      - COOKIE_DOMAIN=$cookie_domain
      - NEXT_PUBLIC_COOKIE_DOMAIN=$cookie_domain

      ##  Storage
      - STORAGE_TYPE=s3
      - S3_ENDPOINT=https://$url_s3
      - S3_BUCKET_NAME=dify${1:+-$1}
      - S3_ACCESS_KEY=$S3_ACCESS_KEY
      - S3_SECRET_KEY=$S3_SECRET_KEY
      - S3_REGION=eu-south
      - S3_ADDRESS_STYLE=path
      - S3_USE_AWS_MANAGED_IAM=false

      - VECTOR_STORE=weaviate
      - VECTOR_INDEX_NAME_PREFIX=vectorindex ## ou Vector_index
      - WEAVIATE_ENDPOINT=http://dify${1:+_$1}_weaviate:8080
      - WEAVIATE_API_KEY=$token_weaviate
      - WEAVIATE_GRPC_ENDPOINT=grpc://dify${1:+_$1}_weaviate:50051
      - WEAVIATE_TOKENIZATION=word

      ##  Modo e Sentry
      - MODE=worker
      - SENTRY_DSN=
      - SENTRY_TRACES_SAMPLE_RATE=1.0
      - SENTRY_PROFILES_SAMPLE_RATE=1.0

      ## AoaEUR' Plugins
      - PLUGIN_DAEMON_KEY=$token_deamon
      - PLUGIN_MAX_PACKAGE_SIZE=52428800
      - INNER_API_KEY_FOR_PLUGIN=$token_apikey_plugins

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_worker_beat:
    image: langgenius/dify-api:latest

    networks:
      - $nome_rede_interna
      - dify${1:+_$1}_ssrf_proxy_network

    environment:
      ## Ao'A URLs e Endpoints
      - CONSOLE_API_URL=https://$url_dify_api/console/api
      - CONSOLE_WEB_URL=https://$url_dify
      - SERVICE_API_URL=https://$url_dify_api/service/api
      - TRIGGER_URL=https://$url_dify_api/triggers
      - APP_API_URL=https://$url_dify_api/api
      - APP_WEB_URL=https://$url_dify
      - FILES_URL=https://$url_dify_api/files
      - INTERNAL_FILES_URL=http://dify${1:+_$1}_api:5001/files
      - CHECK_UPDATE_URL=https://updates.dify.ai
      - OPENAI_API_BASE=https://api.openai.com/v1

      ## Ao'A LocalizaAAAAo e Idioma
      - LANG=en_US.UTF-8
      - LC_ALL=en_US.UTF-8
      - PYTHONIOENCODING=utf-8

      - LOG_LEVEL=INFO
      - LOG_FILE=/app/logs/server.log
      - LOG_FILE_MAX_SIZE=20
      - LOG_FILE_BACKUP_COUNT=5
      - LOG_DATEFORMAT=%Y-%m-%d %H:%M:%S
      - LOG_TZ=UTC
      - DEBUG=false
      - FLASK_DEBUG=false
      - ENABLE_REQUEST_LOGGING=False

      - SECRET_KEY=$secret_key
      - ACCESS_TOKEN_EXPIRE_MINUTES=60
      - REFRESH_TOKEN_EXPIRE_DAYS=30

      ## Aa"AAA ConfiguraAAAAo do Servidor
      - DEPLOY_ENV=PRODUCTION
      - DIFY_BIND_ADDRESS=0.0.0.0
      - DIFY_PORT=5001
      - SERVER_WORKER_AMOUNT=1
      - SERVER_WORKER_CLASS=gevent
      - SERVER_WORKER_CONNECTIONS=10
      - GUNICORN_TIMEOUT=360
      - MIGRATION_ENABLED=true
      - FILES_ACCESS_TIMEOUT=300
      - APP_DEFAULT_ACTIVE_REQUESTS=0
      - APP_MAX_ACTIVE_REQUESTS=0
      - APP_MAX_EXECUTION_TIME=1200

      ## AoaEURaEUR Celery e Workers
      - CELERY_WORKER_CLASS=
      - CELERY_WORKER_AMOUNT=
      - CELERY_AUTO_SCALE=false
      - CELERY_MAX_WORKERS=
      - CELERY_MIN_WORKERS=

      ## AoaEURoAAAA API Tools
      - API_TOOL_DEFAULT_CONNECT_TIMEOUT=10
      - API_TOOL_DEFAULT_READ_TIMEOUT=60

      ## Ao'A Website Crawlers
      - ENABLE_WEBSITE_JINAREADER=true
      - ENABLE_WEBSITE_FIRECRAWL=true
      - ENABLE_WEBSITE_WATERCRAWL=true

      ##  Frontend
      - NEXT_PUBLIC_ENABLE_SINGLE_DOLLAR_LATEX=false

      - DB_TYPE=postgresql
      - DB_USERNAME=postgres
      - DB_PASSWORD=$senha_postgres
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_DATABASE=dify${1:+_$1}
      - SQLALCHEMY_POOL_SIZE=30
      - SQLALCHEMY_MAX_OVERFLOW=10
      - SQLALCHEMY_POOL_RECYCLE=3600
      - SQLALCHEMY_ECHO=false
      - SQLALCHEMY_POOL_PRE_PING=false
      - SQLALCHEMY_POOL_USE_LIFO=false
      - SQLALCHEMY_POOL_TIMEOUT=30

      ##  Redis
      - REDIS_HOST=dify${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_USERNAME=
      - REDIS_PASSWORD=
      - REDIS_USE_SSL=false
      - REDIS_DB=0
      - CELERY_BROKER_URL=redis://dify${1:+_$1}_redis:6379/1
      - CELERY_BACKEND=redis

      ## AoAAa Cookies e CORS
      - WEB_API_CORS_ALLOW_ORIGINS=https://$url_dify
      - CONSOLE_CORS_ALLOW_ORIGINS=https://$url_dify
      - COOKIE_DOMAIN=$cookie_domain
      - NEXT_PUBLIC_COOKIE_DOMAIN=$cookie_domain

      ##  Storage
      - STORAGE_TYPE=s3
      - S3_ENDPOINT=https://$url_s3
      - S3_BUCKET_NAME=dify${1:+-$1}
      - S3_ACCESS_KEY=$S3_ACCESS_KEY
      - S3_SECRET_KEY=$S3_SECRET_KEY
      - S3_REGION=eu-south
      - S3_ADDRESS_STYLE=path
      - S3_USE_AWS_MANAGED_IAM=false

      - VECTOR_STORE=weaviate
      - VECTOR_INDEX_NAME_PREFIX=Vector_index
      - WEAVIATE_ENDPOINT=http://dify${1:+_$1}_weaviate:8080
      - WEAVIATE_API_KEY=$token_weaviate
      - WEAVIATE_GRPC_ENDPOINT=grpc://dify${1:+_$1}_weaviate:50051
      - WEAVIATE_TOKENIZATION=word

      ##  Modo
      - MODE=beat

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_web:
    image: langgenius/dify-web:latest

    networks:
      - $nome_rede_interna

    environment:
      ## Ao'A URLs e Endpoints
      - TRAEFIK_DOMAIN=$url_dify
      - CONSOLE_API_URL=https://$url_dify_api
      - APP_API_URL=https://$url_dify_api
      - NEXT_PUBLIC_API_PREFIX=https://$url_dify_api/console/api
      - NEXT_PUBLIC_PUBLIC_API_PREFIX=https://$url_dify_api/api
      - MARKETPLACE_API_URL=https://marketplace.dify.ai
      - MARKETPLACE_URL=https://marketplace.dify.ai

      ## AoAAa Cookies
      - NEXT_PUBLIC_COOKIE_DOMAIN=$cookie_domain

      ##  Monitoramento e Observabilidade
      - SENTRY_DSN=
      - NEXT_TELEMETRY_DISABLED=1

      ## Aa"AAA ConfiguraAAAAes de Performance
      - TEXT_GENERATION_TIMEOUT_MS=60000
      - PM2_INSTANCES=2

      ## AoaEURaEUR SeguranAAa e CSP
      - CSP_WHITELIST=
      - ALLOW_EMBED=false
      - ALLOW_UNSAFE_DATA_SCHEME=false

      ## AoaEURoAAAA ConfiguraAAAAes de Workflow
      - TOP_K_MAX_VALUE=
      - INDEXING_MAX_SEGMENTATION_TOKENS_LENGTH=
      - LOOP_NODE_MAX_COUNT=100
      - MAX_TOOLS_NUM=10
      - MAX_PARALLEL_LIMIT=10
      - MAX_ITERATIONS_NUM=99
      - MAX_TREE_DEPTH=50

      ## Ao'A Website Crawlers
      - ENABLE_WEBSITE_JINAREADER=true
      - ENABLE_WEBSITE_FIRECRAWL=true
      - ENABLE_WEBSITE_WATERCRAWL=true

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M
      labels:
        # Traefik labels para o frontend
        - traefik.enable=true
        - traefik.docker.network=$nome_rede_interna
        - traefik.http.routers.dify${1:+_$1}_web.rule=Host(\`$url_dify\`)
        - traefik.http.routers.dify${1:+_$1}_web.entrypoints=websecure
        - traefik.http.routers.dify${1:+_$1}_web.tls.certresolver=letsencryptresolver
        - traefik.http.routers.dify${1:+_$1}_web.priority=10
        - traefik.http.services.dify${1:+_$1}_web.loadbalancer.server.port=3000

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_redis:
    image: redis:latest
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - dify${1:+_$1}_redis_data:/data

    networks:
      - $nome_rede_interna

    environment:
      ##  Configuracao do Redis
      - REDISCLI_AUTH=

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 2048M

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_weaviate:
    image: semitechnologies/weaviate:latest

    volumes:
      - dify${1:+_$1}_weaviate_data:/var/lib/weaviate

    networks:
      - $nome_rede_interna

    environment:
      - PERSISTENCE_DATA_PATH=/var/lib/weaviate
      - QUERY_DEFAULTS_LIMIT=25
      - DEFAULT_VECTORIZER_MODULE=none
      - CLUSTER_HOSTNAME=node1
      - DISABLE_TELEMETRY=true

      - AUTHENTICATION_ANONYMOUS_ACCESS_ENABLED=false
      - AUTHENTICATION_APIKEY_ENABLED=true
      - AUTHENTICATION_APIKEY_ALLOWED_KEYS=$token_weaviate
      - AUTHENTICATION_APIKEY_USERS=hello@dify.ai
      - AUTHORIZATION_ADMINLIST_ENABLED=true
      - AUTHORIZATION_ADMINLIST_USERS=hello@dify.ai

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_sandbox:
    image: langgenius/dify-sandbox:latest

    volumes:
      - dify${1:+_$1}_sandbox_dependencies:/dependencies
      - dify${1:+_$1}_sandbox_conf:/conf

    networks:
      - dify${1:+_$1}_ssrf_proxy_network

    environment:
      ## AoaEURaEUR ConfiguraAAAAo do Sandbox
      - API_KEY=$sandbox_api_key
      - GIN_MODE=release
      - WORKER_TIMEOUT=15
      - SANDBOX_PORT=8194

      ## Ao'A Rede e Proxy
      - ENABLE_NETWORK=true
      - HTTP_PROXY=http://dify${1:+_$1}_ssrf_proxy:3128
      - HTTPS_PROXY=http://dify${1:+_$1}_ssrf_proxy:3128

      ##  Dependencias Python
      - PIP_MIRROR_URL=

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_plugin_daemon:
    image: langgenius/dify-plugin-daemon:latest-local

    volumes:
      - dify${1:+_$1}_plugin_daemon:/app/storage

    networks:
      - $nome_rede_interna

    environment:
      ## Ao'A URLs e Endpoints
      - CONSOLE_API_URL=https://$url_dify_api/console/api
      - CONSOLE_WEB_URL=https://$url_dify
      - SERVICE_API_URL=https://$url_dify_api/service/api
      - TRIGGER_URL=https://$url_dify_api/triggers
      - APP_API_URL=https://$url_dify_api/api
      - APP_WEB_URL=https://$url_dify
      - FILES_URL=https://$url_dify_api/files
      - INTERNAL_FILES_URL=http://dify${1:+_$1}_api:5001/files
      - CHECK_UPDATE_URL=https://updates.dify.ai
      - OPENAI_API_BASE=https://api.openai.com/v1

      ## Ao'A LocalizaAAAAo e Idioma
      - LANG=en_US.UTF-8
      - LC_ALL=en_US.UTF-8
      - PYTHONIOENCODING=utf-8

      - LOG_LEVEL=INFO
      - LOG_FILE=/app/logs/server.log
      - LOG_FILE_MAX_SIZE=20
      - LOG_FILE_BACKUP_COUNT=5
      - LOG_DATEFORMAT=%Y-%m-%d %H:%M:%S
      - LOG_TZ=UTC
      - DEBUG=false
      - FLASK_DEBUG=false
      - ENABLE_REQUEST_LOGGING=False

      - SECRET_KEY=$secret_key
      - INIT_PASSWORD=
      - ACCESS_TOKEN_EXPIRE_MINUTES=60
      - REFRESH_TOKEN_EXPIRE_DAYS=30

      ## Aa"AAA ConfiguraAAAAo do Servidor
      - DEPLOY_ENV=PRODUCTION
      - DIFY_BIND_ADDRESS=0.0.0.0
      - DIFY_PORT=5001
      - SERVER_WORKER_AMOUNT=1
      - SERVER_WORKER_CLASS=gevent
      - SERVER_WORKER_CONNECTIONS=10
      - GUNICORN_TIMEOUT=360
      - MIGRATION_ENABLED=true
      - FILES_ACCESS_TIMEOUT=300
      - APP_DEFAULT_ACTIVE_REQUESTS=0
      - APP_MAX_ACTIVE_REQUESTS=0
      - APP_MAX_EXECUTION_TIME=1200

      ## AoaEURaEUR Celery e Workers
      - CELERY_WORKER_CLASS=
      - CELERY_WORKER_AMOUNT=
      - CELERY_AUTO_SCALE=false
      - CELERY_MAX_WORKERS=
      - CELERY_MIN_WORKERS=

      ## AoaEURoAAAA API Tools
      - API_TOOL_DEFAULT_CONNECT_TIMEOUT=10
      - API_TOOL_DEFAULT_READ_TIMEOUT=60

      ## Ao'A Website Crawlers
      - ENABLE_WEBSITE_JINAREADER=true
      - ENABLE_WEBSITE_FIRECRAWL=true
      - ENABLE_WEBSITE_WATERCRAWL=true

      ##  Frontend
      - NEXT_PUBLIC_ENABLE_SINGLE_DOLLAR_LATEX=false

      - DB_TYPE=postgresql
      - DB_USERNAME=postgres
      - DB_PASSWORD=$senha_postgres
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_DATABASE=dify${1:+_$1}_plugin
      - SQLALCHEMY_POOL_SIZE=30
      - SQLALCHEMY_MAX_OVERFLOW=10
      - SQLALCHEMY_POOL_RECYCLE=3600
      - SQLALCHEMY_ECHO=false
      - SQLALCHEMY_POOL_PRE_PING=false
      - SQLALCHEMY_POOL_USE_LIFO=false
      - SQLALCHEMY_POOL_TIMEOUT=30

      ##  Redis
      - REDIS_HOST=dify${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_USERNAME=
      - REDIS_PASSWORD=
      - REDIS_USE_SSL=false
      - REDIS_DB=0
      - CELERY_BROKER_URL=redis://dify${1:+_$1}_redis:6379/1
      - CELERY_BACKEND=redis

      ## AoAAa Cookies e CORS
      - WEB_API_CORS_ALLOW_ORIGINS=https://$url_dify
      - CONSOLE_CORS_ALLOW_ORIGINS=https://$url_dify
      - COOKIE_DOMAIN=$cookie_domain
      - NEXT_PUBLIC_COOKIE_DOMAIN=$cookie_domain

      ##  Storage
      - STORAGE_TYPE=s3
      - S3_ENDPOINT=https://$url_s3
      - S3_BUCKET_NAME=dify${1:+-$1}
      - S3_ACCESS_KEY=$S3_ACCESS_KEY
      - S3_SECRET_KEY=$S3_SECRET_KEY
      - S3_REGION=eu-south
      - S3_ADDRESS_STYLE=path
      - S3_USE_AWS_MANAGED_IAM=false

      - VECTOR_STORE=weaviate
      - VECTOR_INDEX_NAME_PREFIX=Vector_index
      - WEAVIATE_ENDPOINT=http://dify${1:+_$1}_weaviate:8080
      - WEAVIATE_API_KEY=$token_weaviate
      - WEAVIATE_GRPC_ENDPOINT=grpc://dify${1:+_$1}_weaviate:50051
      - WEAVIATE_TOKENIZATION=word

      ## AoaEUR' ConfiguraAAAAo do Plugin Daemon
      - SERVER_PORT=5002
      - SERVER_KEY=$token_deamon
      - MAX_PLUGIN_PACKAGE_SIZE=52428800
      - PPROF_ENABLED=false
      - DIFY_INNER_API_URL=http://dify${1:+_$1}_api:5001
      - DIFY_INNER_API_KEY=$token_apikey_plugins
      - PLUGIN_REMOTE_INSTALLING_HOST=0.0.0.0
      - PLUGIN_REMOTE_INSTALLING_PORT=5003
      - PLUGIN_WORKING_PATH=/app/storage/cwd
      - FORCE_VERIFYING_SIGNATURE=true
      - PYTHON_ENV_INIT_TIMEOUT=120
      - PLUGIN_MAX_EXECUTION_TIMEOUT=600
      - PLUGIN_STDIO_BUFFER_SIZE=1024
      - PLUGIN_STDIO_MAX_BUFFER_SIZE=5242880
      - PIP_MIRROR_URL=
      - PLUGIN_STORAGE_TYPE=local
      - PLUGIN_STORAGE_LOCAL_ROOT=/app/storage
      - PLUGIN_INSTALLED_PATH=plugin
      - PLUGIN_PACKAGE_CACHE_PATH=plugin_packages
      - PLUGIN_MEDIA_CACHE_PATH=assets

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M
      labels:
        - traefik.enable=true
        - traefik.docker.network=$nome_rede_interna
        - traefik.http.routers.dify${1:+_$1}_plugin.rule=Host(\`$url_dify\`) && PathPrefix(\`/e/\`)
        - traefik.http.routers.dify${1:+_$1}_plugin.entrypoints=websecure
        - traefik.http.routers.dify${1:+_$1}_plugin.tls.certresolver=letsencryptresolver
        - traefik.http.services.dify${1:+_$1}_plugin.loadbalancer.server.port=5002

## --------------------------- FELSEN --------------------------- ##

  dify${1:+_$1}_ssrf_proxy:
    image: ubuntu/squid:latest

    networks:
      - $nome_rede_interna
      - dify${1:+_$1}_ssrf_proxy_network

    environment:
      ## AoaEURaEUR ConfiguraAAAAo do SSRF Proxy
      - HTTP_PORT=3128
      - COREDUMP_DIR=/var/spool/squid
      - REVERSE_PROXY_PORT=8194

      ##  Sandbox
      - SANDBOX_HOST=dify${1:+_$1}_sandbox
      - SANDBOX_PORT=8194

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M

## --------------------------- FELSEN --------------------------- ##

volumes:
  dify${1:+_$1}_storage:
    external: true
    name: dify${1:+_$1}_storage
  dify${1:+_$1}_postgres_data:
    external: true
    name: dify${1:+_$1}_postgres_data
  dify${1:+_$1}_redis_data:
    external: true
    name: dify${1:+_$1}_redis_data
  dify${1:+_$1}_weaviate_data:
    external: true
    name: dify${1:+_$1}_weaviate_data
  dify${1:+_$1}_sandbox_dependencies:
    external: true
    name: dify${1:+_$1}_sandbox_dependencies
  dify${1:+_$1}_sandbox_conf:
    external: true
    name: dify${1:+_$1}_sandbox_conf
  dify${1:+_$1}_plugin_daemon:
    external: true
    name: dify${1:+_$1}_plugin_daemon

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
  dify${1:+_$1}_ssrf_proxy_network:
    driver: overlay
    internal: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Dify Ai"
fi
STACK_NAME="dify${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c dify.yaml dify > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Dify Ai"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest ubuntu/squid:latest langgenius/dify-api:latest langgenius/dify-web:latest semitechnologies/weaviate:latest langgenius/dify-sandbox:0.2.12 langgenius/dify-plugin-daemon:latest-local

## Usa o servico wait_dify para verificar se o servico esta online
wait_stack  dify${1:+_$1}_dify${1:+_$1}_api dify${1:+_$1}_dify${1:+_$1}_worker dify${1:+_$1}_dify${1:+_$1}_worker_beat dify${1:+_$1}_dify${1:+_$1}_web dify${1:+_$1}_dify${1:+_$1}_redis dify${1:+_$1}_dify${1:+_$1}_weaviate dify${1:+_$1}_dify${1:+_$1}_sandbox dify${1:+_$1}_dify${1:+_$1}_plugin_daemon dify${1:+_$1}_dify${1:+_$1}_ssrf_proxy


cd dados_vps

cat > dados_dify${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ DIFY AI ]

Dominio do dify: https://$url_dify

Email: Precisa de criar na primeira vez que entrar no Dify AI

Senha: Precisa de criar na primeira vez que entrar no Dify AI
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
echo -e "\e[32m[ DIFY AI ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_dify\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Precisa de criar na primeira vez que entrar no Dify AI.\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar na primeira vez que entrar no Dify AI.\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ###     ###      ###### ####   #### ###### 

