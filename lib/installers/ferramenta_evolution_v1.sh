#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_evolution_v1() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_evolution

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para a Evolution API (ex: api.example.com): \e[0m" && read -r url_evolution
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_evolution
    
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
        nome_evolution

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DA EVOLUTION API \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Literalmente nada, apenas um espaco vazio caso precisar de adicionar alguma coisa
## Antes..
## E claro, para aparecer a mensagem do passo..

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO A EVOLUTION API \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Verifica se existe postgres
verificar_container_postgres
if [ $? -eq 0 ]; then
    pegar_senha_postgres > /dev/null 2>&1
    senha_do_postgres=$senha_postgres
else
    senha_do_postgres=SENHA_DO_POSTGRES_AQUI
fi

## Aqui de fato vamos iniciar a instalacao da Evolution API

## Criando uma Global Key Aleatoria
apikeyglobal=$(openssl rand -hex 16)

## Criando a stack
cat > evolution_v1${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  evolution_Felsen${1:+_$1}:
    image: evoapicloud/evolution-api:v1.8.5 ## Versao da Evolution API
    command: ["node", "./dist/src/main.js"]

    volumes:
      - evolution_Felsen${1:+_$1}_instances:/evolution/instances
      - evolution_Felsen${1:+_$1}_store:/evolution/store
      - evolution_Felsen${1:+_$1}_views:/evolution/views

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Url da Evolution API
      - SERVER_URL=https://$url_evolution ## Url da aplicacao

    ## " Dados de AutenticaAAo
      - AUTHENTICATION_TYPE=apikey
      - AUTHENTICATION_API_KEY=$apikeyglobal ## GLOBAL API KEY
      - AUTHENTICATION_EXPOSE_IN_FETCH_INSTANCES=true

    ## Configuracoes
      - CONFIG_SESSION_PHONE_CLIENT=Felsen ## Nome que aparece no celular
      - CONFIG_SESSION_PHONE_NAME=chrome

    ##  Definir versao do Whatsapp Web
    ## pegue a versao em: https://web.whatsapp.com/check-update?version=0&platform=web
      - CONFIG_SESSION_PHONE_VERSION=2,3000,1015901307

    ## -i Sobre os QR-Codes
      - QRCODE_LIMIT=1902
      - QRCODE_COLOR=#000000

    ## o Ativar o RabbitMQ
      - RABBITMQ_ENABLED=false ## Colocar true se quiser usar | Recomendado | Necessario instalar RabbitMQ antes
      - RABBITMQ_URI=amqp://USER:PASS@rabbitmq:5672

    ## -"i Ativar Banco de Dados MongoDB
      - DATABASE_ENABLED=false ## Colocar true se quiser usar | Necessario instalar MongoDB antes
      - DATABASE_CONNECTION_URI=mongodb://USUARIO:SENHA@IP_VPS:27017/?authSource=admin&readPreference=primary&ssl=false&directConnection=true ## Colocar a URL do MongoDB
      - DATABASE_CONNECTION_DB_PREFIX_NAME=evolution${1:+_$1}
      - DATABASE_SAVE_DATA_INSTANCE=true
      - DATABASE_SAVE_DATA_NEW_MESSAGE=true
      - DATABASE_SAVE_MESSAGE_UPDATE=true
      - DATABASE_SAVE_DATA_CONTACTS=true
      - DATABASE_SAVE_DATA_CHATS=true

    ## 'aEUR' Ativar o Redis
      - REDIS_ENABLED=false ## Colocar true se quiser usar | Nao recomendado
      - REDIS_URI=redis://redis:6379

    ##  Ativar o Cache Redis (Em testes)
      - CACHE_REDIS_ENABLED=false
      - CACHE_REDIS_URI=redis://redis:6379
      - CACHE_REDIS_PREFIX_KEY=evolution${1:+_$1}
      - CACHE_REDIS_TTL=604800
      - CACHE_REDIS_SAVE_INSTANCES=false
      - CACHE_LOCAL_ENABLED=false
      - CACHE_LOCAL_TTL=604800

    ##  Novas variaveis para o Typebot
      - TYPEBOT_KEEP_OPEN=true
      - TYPEBOT_API_VERSION=latest

    ##  Novas variaveis para o Chatwoot
      - CHATWOOT_MESSAGE_DELETE=true
      - CHATWOOT_MESSAGE_READ=true

    ##  Importar mensagens para o Chatwoot | Descomente para usar
    ## Se estiver usando Chatwoot do Nestor mude o a parte "chatwoot" para "chatwoot_nestor"
      #- CHATWOOT_IMPORT_DATABASE_CONNECTION_URI=postgresql://postgres:$senha_do_postgres@postgres:5432/chatwoot?sslmode=disable
      #- CHATWOOT_IMPORT_DATABASE_PLACEHOLDER_MEDIA_MESSAGE=false ## true = Importar midia | false = Nao importar midia 

    ##  Informacoes do Webhook
      - WEBHOOK_GLOBAL_ENABLED=false
      - WEBHOOK_GLOBAL_URL=
      - WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS=false
      - WEBHOOK_EVENTS_APPLICATION_STARTUP=false
      - WEBHOOK_EVENTS_QRCODE_UPDATED=true
      - WEBHOOK_EVENTS_MESSAGES_SET=false
      - WEBHOOK_EVENTS_MESSAGES_UPSERT=true
      - WEBHOOK_EVENTS_MESSAGES_UPDATE=true
      - WEBHOOK_EVENTS_CONTACTS_SET=true
      - WEBHOOK_EVENTS_CONTACTS_UPSERT=true
      - WEBHOOK_EVENTS_CONTACTS_UPDATE=true
      - WEBHOOK_EVENTS_PRESENCE_UPDATE=true
      - WEBHOOK_EVENTS_CHATS_SET=true
      - WEBHOOK_EVENTS_CHATS_UPSERT=true
      - WEBHOOK_EVENTS_CHATS_UPDATE=true
      - WEBHOOK_EVENTS_CHATS_DELETE=true
      - WEBHOOK_EVENTS_GROUPS_UPSERT=true
      - WEBHOOK_EVENTS_GROUPS_UPDATE=true
      - WEBHOOK_EVENTS_GROUP_PARTICIPANTS_UPDATE=true
      - WEBHOOK_EVENTS_CONNECTION_UPDATE=true

    ## Sobre as instancias
      - DEL_INSTANCE=false
      - DEL_TEMP_INSTANCES=false
      - STORE_MESSAGES=true
      - STORE_MESSAGE_UP=true
      - STORE_CONTACTS=true
      - STORE_CHATS=true
      - CLEAN_STORE_CLEANING_INTERVAL=7200 # seconds === 2h
      - CLEAN_STORE_MESSAGES=true
      - CLEAN_STORE_MESSAGE_UP=true
      - CLEAN_STORE_CONTACTS=true
      - CLEAN_STORE_CHATS=true

    ## -i Outros dados
      - DOCKER_ENV=true
      - LOG_LEVEL=ERROR

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.evolution_Felsen${1:+_$1}.rule=Host(\`$url_evolution\`) ## Url da Evolution API
        - traefik.http.routers.evolution_Felsen${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.evolution_Felsen${1:+_$1}.priority=1
        - traefik.http.routers.evolution_Felsen${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evolution_Felsen${1:+_$1}.service=evolution_Felsen${1:+_$1}
        - traefik.http.services.evolution_Felsen${1:+_$1}.loadbalancer.server.port=8080
        - traefik.http.services.evolution_Felsen${1:+_$1}.loadbalancer.passHostHeader=1

## --------------------------- FELSEN --------------------------- ##

volumes:
  evolution_Felsen${1:+_$1}_instances:
    external: true
    name: evolution_Felsen${1:+_$1}_instances
  evolution_Felsen${1:+_$1}_store:
    external: true
    name: evolution_Felsen${1:+_$1}_store
  evolution_Felsen${1:+_$1}_views:
    external: true
    name: evolution_Felsen${1:+_$1}_views
networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da Evolution API"
fi
STACK_NAME="evolution_v1${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c evolution_v1.yaml evolution > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack da Evolution API"
#fi

sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

pull evoapicloud/evolution-api:v1.8.5

## Usa o servico wait_evolution para verificar se o servico esta online
wait_stack "evolution_v1${1:+_$1}_evolution_Felsen${1:+_$1}"


cd dados_vps

cat > dados_evolution_v1${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ EVOLUTION API ]

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
echo -e "\e[32m[ Evolution API ]\e[0m"
echo ""

echo -e "\e[97mLink do Manager:\e[33m https://$url_evolution/manager\e[0m"
echo ""

echo -e "\e[97mAPI URL:\e[33m https://$url_evolution\e[0m"
echo ""

echo -e "\e[97mGLOBAL API KEY:\e[33m $apikeyglobal\e[0m"
echo ""

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########   ### ####### ###     ###   ############### ####### ####   ###    ###   ########## 
## a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-a-a--  a-a-a-'    a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-a-a-a--  a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-- a-a-a-'    a-a-a-'   a-a-a-' a-a-a-a-a-a-"a-
## a-a-a-"a-a-a-  a-a-a-a-- a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'    a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a- 
## a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'     a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a--
## a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-a-a-a-a- a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-    a-a-a-   a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-      a-a-a-a-a-  a-a-a-a-a-a-a-a-

