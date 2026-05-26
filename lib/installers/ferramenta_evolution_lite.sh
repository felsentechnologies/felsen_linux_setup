#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_evolution_lite() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_evolution_lite

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para a Evolution API Lite (ex: api.example.com): \e[0m" && read -r url_evolution
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_evolution_lite
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio da Evolution API:\e[97m $url_evolution\e[0m"
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
        nome_evolution_lite

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DA EVOLUTION API LITE \e[33m[1/4\e[0m"
echo ""
sleep 1


## Literalmente nada, apenas um espaco vazio caso precisar de adicionar alguma coisa
## Antes..
## E claro, para aparecer a mensagem do passo..

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres Instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "evolution${1:+_$1}_lite"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "evolution${1:+_$1}_lite"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO A EVOLUTION API \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Aqui de fato vamos iniciar a instalacao da Evolution API

## Criando uma Global Key Aleatoria
apikeyglobal=$(openssl rand -hex 16)

## Criando a stack evolution.yaml
cat > evolution${1:+_$1}_lite.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  evolution${1:+_$1}_lite:
    image: atendai/evolution-api-lite:latest ## Versao da Evolution API
    entrypoint: ["/bin/bash", "-c", ". ./Docker/scripts/deploy_database.sh && npm run start:prod" ]

    volumes:
      - evolution${1:+_$1}_lite_instances:/evolution/instances

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracoes Gerais
      - SERVER_URL=https://$url_evolution
      - AUTHENTICATION_API_KEY=$apikeyglobal
      - AUTHENTICATION_EXPOSE_IN_FETCH_INSTANCES=true
      - DEL_INSTANCE=false
      - QRCODE_LIMIT=1902
      - LANGUAGE=pt-BR
      
    ##  Configuracao do Cliente
    ## Pegue a versao em: https://web.whatsapp.com/sw.js
      - CONFIG_SESSION_PHONE_VERSION=2.3000.1025815458
      - CONFIG_SESSION_PHONE_CLIENT=Felsen
      - CONFIG_SESSION_PHONE_NAME=Chrome
      
    ## -"i Configuracao do Banco de Dados
      - DATABASE_ENABLED=true
      - DATABASE_PROVIDER=postgresql
      - DATABASE_CONNECTION_URI=postgresql://postgres:$senha_postgres@postgres:5432/evolution${1:+_$1}_lite
      - DATABASE_CONNECTION_CLIENT_NAME=evolution${1:+_$1}_lite
      - DATABASE_SAVE_DATA_INSTANCE=true
      - DATABASE_SAVE_DATA_NEW_MESSAGE=true
      - DATABASE_SAVE_MESSAGE_UPDATE=true
      - DATABASE_SAVE_DATA_CONTACTS=true
      - DATABASE_SAVE_DATA_CHATS=true
      - DATABASE_SAVE_DATA_LABELS=true
      - DATABASE_SAVE_DATA_HISTORIC=true
      
    ##  Configuracao do Cache
      - CACHE_REDIS_ENABLED=true
      - CACHE_REDIS_URI=redis://evolution${1:+_$1}_lite_redis:6379/8
      - CACHE_REDIS_PREFIX_KEY=evolution
      - CACHE_REDIS_SAVE_INSTANCES=false
      - CACHE_LOCAL_ENABLED=false
      
    ## Configuracao do S3
      - S3_ENABLED=false
      - S3_ACCESS_KEY=
      - S3_SECRET_KEY=
      - S3_BUCKET=evolution
      - S3_PORT=443
      - S3_ENDPOINT=
      - S3_USE_SSL=true
      #- S3_REGION=eu-south

    ##  Configuracao do WhatsApp Business
      - WA_BUSINESS_TOKEN_WEBHOOK=evolution
      - WA_BUSINESS_URL=https://graph.facebook.com
      - WA_BUSINESS_VERSION=v20.0
      - WA_BUSINESS_LANGUAGE=pt_BR

    ##  rastreamento
      - TELEMETRY=false
      - TELEMETRY_URL=

    ##  Configuracao do WebSocket
      - WEBSOCKET_ENABLED=false
      - WEBSOCKET_GLOBAL_EVENTS=false

    ##  Configuracao do SQS
      - SQS_ENABLED=false
      - SQS_ACCESS_KEY_ID=
      - SQS_SECRET_ACCESS_KEY=
      - SQS_ACCOUNT_ID=
      - SQS_REGION=

    ##  Configuracao do RabbitMQ
      - RABBITMQ_ENABLED=false
      - RABBITMQ_URI=amqp://USER:PASS@rabbitmq:5672/evolution${1:+_$1}
      - RABBITMQ_EXCHANGE_NAME=evolution
      - RABBITMQ_GLOBAL_ENABLED=false
      - RABBITMQ_EVENTS_APPLICATION_STARTUP=false
      - RABBITMQ_EVENTS_INSTANCE_CREATE=false
      - RABBITMQ_EVENTS_INSTANCE_DELETE=false
      - RABBITMQ_EVENTS_QRCODE_UPDATED=false
      - RABBITMQ_EVENTS_MESSAGES_SET=false
      - RABBITMQ_EVENTS_MESSAGES_UPSERT=true
      - RABBITMQ_EVENTS_MESSAGES_EDITED=false
      - RABBITMQ_EVENTS_MESSAGES_UPDATE=false
      - RABBITMQ_EVENTS_MESSAGES_DELETE=false
      - RABBITMQ_EVENTS_SEND_MESSAGE=false
      - RABBITMQ_EVENTS_CONTACTS_SET=false
      - RABBITMQ_EVENTS_CONTACTS_UPSERT=false
      - RABBITMQ_EVENTS_CONTACTS_UPDATE=false
      - RABBITMQ_EVENTS_PRESENCE_UPDATE=false
      - RABBITMQ_EVENTS_CHATS_SET=false
      - RABBITMQ_EVENTS_CHATS_UPSERT=false
      - RABBITMQ_EVENTS_CHATS_UPDATE=false
      - RABBITMQ_EVENTS_CHATS_DELETE=false
      - RABBITMQ_EVENTS_GROUPS_UPSERT=false
      - RABBITMQ_EVENTS_GROUP_UPDATE=false
      - RABBITMQ_EVENTS_GROUP_PARTICIPANTS_UPDATE=false
      - RABBITMQ_EVENTS_CONNECTION_UPDATE=true
      - RABBITMQ_EVENTS_CALL=false
      - RABBITMQ_EVENTS_TYPEBOT_START=false
      - RABBITMQ_EVENTS_TYPEBOT_CHANGE_STATUS=false

    ##  Configuracao do Webhook
      - WEBHOOK_GLOBAL_ENABLED=false
      - WEBHOOK_GLOBAL_URL=
      - WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS=false
      - WEBHOOK_EVENTS_APPLICATION_STARTUP=false
      - WEBHOOK_EVENTS_QRCODE_UPDATED=false
      - WEBHOOK_EVENTS_MESSAGES_SET=false
      - WEBHOOK_EVENTS_MESSAGES_UPSERT=false
      - WEBHOOK_EVENTS_MESSAGES_EDITED=false
      - WEBHOOK_EVENTS_MESSAGES_UPDATE=false
      - WEBHOOK_EVENTS_MESSAGES_DELETE=false
      - WEBHOOK_EVENTS_SEND_MESSAGE=false
      - WEBHOOK_EVENTS_CONTACTS_SET=false
      - WEBHOOK_EVENTS_CONTACTS_UPSERT=false
      - WEBHOOK_EVENTS_CONTACTS_UPDATE=false
      - WEBHOOK_EVENTS_PRESENCE_UPDATE=false
      - WEBHOOK_EVENTS_CHATS_SET=false
      - WEBHOOK_EVENTS_CHATS_UPSERT=false
      - WEBHOOK_EVENTS_CHATS_UPDATE=false
      - WEBHOOK_EVENTS_CHATS_DELETE=false
      - WEBHOOK_EVENTS_GROUPS_UPSERT=false
      - WEBHOOK_EVENTS_GROUPS_UPDATE=false
      - WEBHOOK_EVENTS_GROUP_PARTICIPANTS_UPDATE=false
      - WEBHOOK_EVENTS_CONNECTION_UPDATE=false
      - WEBHOOK_EVENTS_LABELS_EDIT=false
      - WEBHOOK_EVENTS_LABELS_ASSOCIATION=false
      - WEBHOOK_EVENTS_CALL=false
      - WEBHOOK_EVENTS_TYPEBOT_START=false
      - WEBHOOK_EVENTS_TYPEBOT_CHANGE_STATUS=false
      - WEBHOOK_EVENTS_ERRORS=false
      - WEBHOOK_EVENTS_ERRORS_WEBHOOK=

    ##  Configuracao do Provider
      - PROVIDER_ENABLED=false
      - PROVIDER_HOST=127.0.0.1
      - PROVIDER_PORT=5656
      - PROVIDER_PREFIX=evolution${1:+_$1}
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.evolution${1:+_$1}_lite.rule=Host(\`$url_evolution\`) ## Url da Evolution API
        - traefik.http.routers.evolution${1:+_$1}_lite.entrypoints=websecure
        - traefik.http.routers.evolution${1:+_$1}_lite.priority=1
        - traefik.http.routers.evolution${1:+_$1}_lite.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evolution${1:+_$1}_lite.service=evolution${1:+_$1}_lite
        - traefik.http.services.evolution${1:+_$1}_lite.loadbalancer.server.port=8080
        - traefik.http.services.evolution${1:+_$1}_lite.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  evolution${1:+_$1}_lite_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - evolution${1:+_$1}_lite_redis:/data

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
          memory: 2048M

## --------------------------- FELSEN --------------------------- ##

volumes:
  evolution${1:+_$1}_lite_instances:
    external: true
    name: evolution${1:+_$1}_lite_instances
  evolution${1:+_$1}_lite_redis:
    external: true
    name: evolution${1:+_$1}_lite_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da Evolution API"
fi
STACK_NAME="evolution${1:+_$1}_lite"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c evolution.yaml evolution > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack da Evolution API"
#fi

sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest atendai/evolution-api-lite:latest

## Usa o servico wait_evolution para verificar se o servico esta online
wait_stack "evolution${1:+_$1}_lite_evolution${1:+_$1}_lite"


cd dados_vps

cat > dados_evolution${1:+_$1}_lite <<__FELSEN_MANAGED_FILE__
[ EVOLUTION API LITE ]

Manager Evolution: https://$url_evolution/manager

URL: https://$url_evolution

Global API Key: $apikeyglobal
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
echo -e "\e[32m[ EVOLUTION API LITE ]\e[0m"
echo ""

echo -e "\e[97mAPI URL:\e[33m https://$url_evolution\e[0m"
echo ""

echo -e "\e[97mGLOBAL API KEY:\e[33m $apikeyglobal\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}


## ###########   ### ####### ###     ###   ############### ####### ####   ###    ###   ### ###
## a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-a-a--  a-a-a-'    a-a-a-'   a-a-a-'a-a-a-a-'
## ######  ##|   ##|##|   ##|##|     ##|   ##|   ##|   ##|##|   ##|###### ##|    ##|   ##|###|
## a-a-a-"a-a-a-  a-a-a-a-- a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'    a-a-a-a-- a-a-a-"a- a-a-a-'
## a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'     a-a-a-a-a-a-"a-  a-a-a-'
## a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-a-a-a-a- a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-    a-a-a-   a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-      a-a-a-a-a-   a-a-a-

