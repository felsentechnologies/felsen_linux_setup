#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_firecrawl() {

## Verifica os recursos
recursos 2 4 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_firecrawl

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o Firecrawl (ex: firecrawl.example.com): \e[0m" && read -r url_firecrawl
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -en "\e[33mDigite uma ApiKey da OpenAI: \e[0m" && read -r api_firecrawl
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_firecrawl
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do firecrawl
    echo -e "\e[33mDominio do Firecrawl:\e[97m $url_firecrawl\e[0m"
    echo ""

    ## Informacao sobre URL do firecrawl
    echo -e "\e[33mApiKey OpenAi:\e[97m $api_firecrawl\e[0m"
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
        nome_firecrawl

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO FIRECRAWL \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO FIRECRAWL \e[33m[2/3]\e[0m"
echo ""
sleep 1

apikey_firecrawl="fc-$(cat /dev/urandom | tr -dc 'a-f0-9' | head -c 32)"
postgres_password=$(openssl rand -hex 16)
## Criando a stack firecrawl.yaml
cat > firecrawl${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.8"
services:

## --------------------------- FELSEN --------------------------- ##

  firecrawl${1:+_$1}_api:
    image: ghcr.io/firecrawl/firecrawl:latest
    command: [ "node", "--max-old-space-size=6144", "dist/src/index.js" ]

    networks:
     - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " API Key
      - FIRECRAWL_API_KEY=$apikey_firecrawl

    ##  Configuracoes do PostgreSQL (NUQ)
      - POSTGRES_HOST=firecrawl${1:+_$1}_nuq_postgres
      - POSTGRES_PORT=5432
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=$postgres_password
      - POSTGRES_DB=postgres
      - NUQ_DATABASE_URL=postgresql://postgres:$postgres_password@firecrawl${1:+_$1}_nuq_postgres:5432/postgres
      - NUQ_DATABASE_URL_LISTEN=postgresql://postgres:$postgres_password@firecrawl${1:+_$1}_nuq_postgres:5432/postgres

    ##  Dados do Redis
      - REDIS_URL=redis://firecrawl${1:+_$1}_redis:6379
      - REDIS_RATE_LIMIT_URL=redis://firecrawl${1:+_$1}_redis:6379
      
    ##  Dados da OpenAI
      - OPENAI_API_KEY=$api_firecrawl
      - OPENAI_BASE_URL=https://api.openai.com/v1
      - MODEL_NAME=gpt-4o
      
    ##  Dados do ScrapingBee (opcional)
      - SCRAPING_BEE_API_KEY=
      
    ##  Configuracoes do Host e Porta
      - HOST=0.0.0.0
      - PORT=3002
      - INTERNAL_PORT=3002
      - WORKER_PORT=3005
      - EXTRACT_WORKER_PORT=3004
      
    ## a Dados do Webhook e Debug
      - SELF_HOSTED_WEBHOOK_URL=
      - LOGGING_LEVEL=DEBUG
      
    ## oi Dados do Supabase (opcional)
      - USE_DB_AUTHENTICATION=false
      #- SUPABASE_URL=
      #- SUPABASE_ANON_TOKEN=
      #- SUPABASE_SERVICE_TOKEN=
      
    ## i Configuracoes de Workers
      - NUM_WORKERS_PER_QUEUE=8
      - CRAWL_CONCURRENT_REQUESTS=10
      - MAX_CONCURRENT_JOBS=5
      - BROWSER_POOL_SIZE=5
      
    ##  Configuracoes do Playwright Service
      - PLAYWRIGHT_MICROSERVICE_URL=http://firecrawl${1:+_$1}_playwright:3000/scrape
      
    ##  Configuracoes de Proxy (opcional)
      - PROXY_SERVER=
      - PROXY_USERNAME=
      - PROXY_PASSWORD=
      
    ## Outras configuracoes
      - FLY_PROCESS_GROUP=app
      - ENV=production
      
    ##  Configuracoes adicionais (opcional)
      #- MODEL_EMBEDDING_NAME=
      #- OLLAMA_BASE_URL=
      #- SLACK_WEBHOOK_URL=
      #- BULL_AUTH_KEY=
      #- TEST_API_KEY=
      #- SEARXNG_ENDPOINT=
      #- SEARXNG_ENGINES=
      #- SEARXNG_CATEGORIES=
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4G
      labels:
        - traefik.enable=true
        - traefik.http.routers.firecrawl${1:+_$1}_api.rule=Host(\`$url_firecrawl\`)
        - traefik.http.services.firecrawl${1:+_$1}_api.loadbalancer.server.port=3002
        - traefik.http.routers.firecrawl${1:+_$1}_api.service=firecrawl${1:+_$1}_api
        - traefik.http.routers.firecrawl${1:+_$1}_api.tls.certresolver=letsencryptresolver
        - traefik.http.routers.firecrawl${1:+_$1}_api.entrypoints=websecure
        - traefik.http.routers.firecrawl${1:+_$1}_api.tls=true

## --------------------------- FELSEN --------------------------- ##

  firecrawl${1:+_$1}_worker:
    image: ghcr.io/firecrawl/firecrawl:latest
    command: [ "node", "--max-old-space-size=3072", "dist/src/services/queue-worker.js" ]
    
    networks:
     - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  Configuracoes do PostgreSQL (NUQ)
      - POSTGRES_HOST=firecrawl${1:+_$1}_nuq_postgres
      - POSTGRES_PORT=5432
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=$postgres_password
      - POSTGRES_DB=postgres
      - NUQ_DATABASE_URL=postgresql://postgres:$postgres_password@firecrawl${1:+_$1}_nuq_postgres:5432/postgres
      - NUQ_DATABASE_URL_LISTEN=postgresql://postgres:$postgres_password@firecrawl${1:+_$1}_nuq_postgres:5432/postgres

    ##  Dados do Redis
      - REDIS_URL=redis://firecrawl${1:+_$1}_redis:6379
      - REDIS_RATE_LIMIT_URL=redis://firecrawl${1:+_$1}_redis:6379
      
    ##  Dados da OpenAI
      - OPENAI_API_KEY=$api_firecrawl
      - OPENAI_BASE_URL=https://api.openai.com/v1
      - MODEL_NAME=gpt-4o
      
    ##  Dados do ScrapingBee (opcional)
      - SCRAPING_BEE_API_KEY=
      
    ##  Configuracoes do Host e Porta
      - HOST=0.0.0.0
      - PORT=3005
      - WORKER_PORT=3005
      
    ## a Dados do Webhook e Debug
      - SELF_HOSTED_WEBHOOK_URL=
      - LOGGING_LEVEL=DEBUG
      
    ## oi Dados do Supabase (opcional)
      - USE_DB_AUTHENTICATION=false
      #- SUPABASE_URL=
      #- SUPABASE_ANON_TOKEN=
      #- SUPABASE_SERVICE_TOKEN=
      
    ## i Configuracoes de Workers
      - NUM_WORKERS_PER_QUEUE=8
      - CRAWL_CONCURRENT_REQUESTS=10
      - MAX_CONCURRENT_JOBS=5
      - BROWSER_POOL_SIZE=5
      
    ##  Configuracoes do Playwright Service
      - PLAYWRIGHT_MICROSERVICE_URL=http://firecrawl${1:+_$1}_playwright:3000/scrape
      
    ##  Configuracoes de Proxy (opcional)
      - PROXY_SERVER=
      - PROXY_USERNAME=
      - PROXY_PASSWORD=
      
    ## Outras configuracoes
      - FLY_PROCESS_GROUP=worker
      - ENV=production
      
    ##  Configuracoes adicionais (opcional)
      #- MODEL_EMBEDDING_NAME=
      #- OLLAMA_BASE_URL=
      #- SLACK_WEBHOOK_URL=
      #- BULL_AUTH_KEY=
      #- TEST_API_KEY=
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 4G

## --------------------------- FELSEN --------------------------- ##

  firecrawl${1:+_$1}_playwright:
    image: ghcr.io/firecrawl/playwright-service:latest

    networks:
     - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracoes da Aplicacao
      - PORT=3000
      - BLOCK_MEDIA=true
      - MAX_CONCURRENT_PAGES=10
    
    ##  Configuracoes de Proxy
      - PROXY_SERVER=$proxy_server
      - PROXY_USERNAME=$proxy_username
      - PROXY_PASSWORD=$proxy_password

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4G

## --------------------------- FELSEN --------------------------- ##

  firecrawl${1:+_$1}_nuq_postgres:
    image: ghcr.io/firecrawl/nuq-postgres:latest

    volumes:
      - firecrawl${1:+_$1}_postgres:/var/lib/postgresql/data

    networks:
     - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracoes do PostgreSQL (NUQ)
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=$postgres_password
      - POSTGRES_DB=postgres
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 1G

## --------------------------- FELSEN --------------------------- ##

  firecrawl${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - firecrawl${1:+_$1}_redis:/data

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
  firecrawl${1:+_$1}_postgres:
    external: true
    name: firecrawl${1:+_$1}_postgres
  firecrawl${1:+_$1}_redis:
    external: true
    name: firecrawl${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do firecrawl"
fi
STACK_NAME="firecrawl${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c firecrawl.yaml firecrawl > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do firecrawl"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/firecrawl/nuq-postgres:latest redis:latest  ghcr.io/firecrawl/firecrawl:latest ghcr.io/firecrawl/playwright-service:latest

## Usa o servico wait_firecrawl para verificar se o servico esta online
wait_stack firecrawl${1:+_$1}_firecrawl${1:+_$1}_nuq_postgres firecrawl${1:+_$1}_firecrawl${1:+_$1}_api firecrawl${1:+_$1}_firecrawl${1:+_$1}_worker firecrawl${1:+_$1}_firecrawl${1:+_$1}_playwright firecrawl${1:+_$1}_firecrawl${1:+_$1}_redis 


cd dados_vps

cat > dados_firecrawl${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ FIRECRAWL ]

Dominio do firecrawl: https://$url_firecrawl

API Key: $apikey_firecrawl
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
echo -e "\e[32m[ FIRECRAWL ]\e[0m"
echo ""

echo -e "\e[33mDominio da API:\e[97m https://$url_firecrawl\e[0m"
echo ""

echo -e "\e[33mAPI Key:\e[97m $apikey_firecrawl\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ###    ######   ########### ###### ####### ###
## a-a-a-'    a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'
## a-a-a-' a-a-- a-a-a-'a-a-a-'   a-a-a-'  a-a-a-a-"a- a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-' a-a-a-a-"a-  a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-'
## a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-'     a-a-a-'
##  a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-
                                                                                      
