#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_unoapi() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_unoapi

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio da UnoApi
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para a Uno API (ex: unoapi.example.com): \e[0m" && read -r url_unoapi
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_unoapi
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    echo -e "\e[33mDominio da Uno API:\e[97m $url_unoapi\e[0m"
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
        nome_unoapi

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done


## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DA UNO API \e[33m[1/5]\e[0m"
echo ""
sleep 1


## Nada nada nada.. so para aparecer a mensagem de passo..

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[2/5]\e[0m"
echo ""
sleep 1

pegar_senha_minio
minio.bucket unoapi${1:+-$1} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
    echo ""
else
    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
    echo ""
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO VHOST NO RABBITMQ \e[33m[3/5]\e[0m"
echo ""
sleep 1

pegar_user_senha_rabbitmq
sleep 5
curl -u $user_rabbit_mqs:$senha_rabbit_mqs -X PUT https://$url_rabbit_mqs/api/vhosts/unoapi${1:+_$1}
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - VHost criado:\e[33m unoapi${1:+_$1}\e[0m"
    echo ""
else
    echo "1/1 - [ OFF ] - Erro ao criar VHost"
    echo ""
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO UNO API \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
key_unoapi=$(openssl rand -hex 16)

## Criando a stack unoapi.yaml
cat > unoapi${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  unoapi${1:+_$1}_api:
    image: clairton/unoapi-cloud:latest
    entrypoint: yarn cloud

    volumes:
      - unoapi${1:+_$1}_data:/home/u/app

    networks:
      - $nome_rede_interna

    environment:
    ##  Url Uno API
      - BASE_URL=https://$url_unoapi

    ## " Token Uno Api
      - UNOAPI_AUTH_TOKEN=$key_unoapi

    ## " Configuracoes da Uno API
      - CONFIG_SESSION_PHONE_CLIENT=Felsen
      - CONFIG_SESSION_PHONE_NAME=Chrome ## Chrome | Firefox | Edge | Opera | Safari

    ##  Configuracao do Webhook
      #- WEBHOOK_URL=https://UrlDoChatwoot.com/webhooks/whatsapp
      #- WEBHOOK_HEADER=api_access_token
      #- WEBHOOK_TOKEN=token_do_admin

    ## -"i Dados do Minio/S3
      - STORAGE_ENDPOINT=https://$url_s3
      - STORAGE_ACCESS_KEY_ID=$S3_ACCESS_KEY
      - STORAGE_SECRET_ACCESS_KEY=$S3_SECRET_KEY
      - STORAGE_BUCKET_NAME=unoapi${1:+-$1}
      - STORAGE_REGION=eu-south
      - STORAGE_FORCE_PATH_STYLE=true

    ## " Dados do RabbitMQ
      - AMQP_URL=amqp://$user_rabbit_mqs:$senha_rabbit_mqs@rabbitmq:5672/unoapi${1:+_$1}

    ## " Dados do Redis
      - REDIS_URL=redis://unoapi${1:+_$1}_redis:6379

    ## " Outras configuracoes
      - LOG_LEVEL=debug
      - UNO_LOG_LEVEL=debug
      - UNOAPI_RETRY_REQUEST_DELAY=1_000

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
        - traefik.http.routers.unoapi${1:+_$1}.rule=Host(\`$url_unoapi\`)
        - traefik.http.routers.unoapi${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.unoapi${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.unoapi${1:+_$1}.loadbalancer.server.port=9876
        - traefik.http.routers.unoapi${1:+_$1}.priority=1
        - traefik.http.services.unoapi${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.routers.unoapi${1:+_$1}.service=unoapi${1:+_$1}

## --------------------------- FELSEN --------------------------- ##

  unoapi${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - unoapi${1:+_$1}_redis:/data

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
  unoapi${1:+_$1}_data:
    external: true
    name: unoapi${1:+_$1}_data
  unoapi${1:+_$1}_redis:
    external: true
    name: unoapi${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Uno API"
fi
STACK_NAME="unoapi${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c unoapi.yaml unoapi > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Uno API"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest clairton/unoapi-cloud:latest

## Usa o servico wait_unoapi para verificar se o servico esta online
wait_stack unoapi${1:+_$1}_unoapi${1:+_$1}_redis unoapi${1:+_$1}_unoapi${1:+_$1}_api


cd dados_vps

cat > dados_unoapi${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ UNO API ]

Dominio do unoapi: https://$url_unoapi

Auth Token: $key_unoapi
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
echo -e "\e[32m[ UNO API ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_unoapi\e[0m"
echo ""

echo -e "\e[33mAuth Token:\e[97m $key_unoapi\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   ### ###### ####   ###     ####### ####### ####   ####    ####   ### ####### ####### ################
## a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'    a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'    a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-- a-a-a-'    a-a-a-'     a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-"a-a-a-'    a-a-a-"a-a-a-- a-a-a-'a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-a--
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a--a-a-a-'    a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'    a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-  a-a-a-a-a-a-a-a-'
## a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'    a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'    a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'
## a-a-a-  a-a-a-a-a- a-a-a-a-a-a- a-a-a-  a-a-a-a-a-     a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-     a-a-a-    a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-
##
##            #######  #######      ####### ###   ##################  ###### ######## ###### 
##            a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--    a-a-a-"a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--
##            a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'    a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'
##            a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'    a-a-a-'a-"a-" a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-'
##            a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-    a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'     a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'  a-a-a-'
##            a-a-a-a-a-a-a-  a-a-a-a-a-a-a-      a-a-a-a-EURa-EURa-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-

