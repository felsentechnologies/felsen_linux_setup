#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_netbox() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_netbox

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o NetBox (ex: netbox.example.com): \e[0m" && read -r url_netbox
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_netbox
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do NetBox:\e[97m $url_netbox\e[0m"
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
        nome_netbox

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO NETBOX \e[33m[1/4]\e[0m"
echo ""
sleep 1


# Mensagem de Passo
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
    criar_banco_postgres_da_stack "netbox${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "netbox${1:+_$1}"
fi

pegar_senha_postgres > /dev/null 2>&1

echo -e "\e[97m- INSTALANDO NETBOX \e[33m[3/4]\e[0m"
echo ""
sleep 1

secretkey_netbox=$(openssl rand -hex 25)
tokenpepper_netbox=$(openssl rand -hex 16)
postgres_netbox=$(openssl rand -hex 16)

## Criando a stack netbox.yaml
cat > netbox${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  netbox${1:+_$1}_app:
    image: docker.io/netboxcommunity/netbox:v4.4-3.4.2

    volumes:
      - netbox${1:+_$1}_media_files:/opt/netbox/netbox/media:rw
      - netbox${1:+_$1}_reports_files:/opt/netbox/netbox/reports:rw
      - netbox${1:+_$1}_scripts_files:/opt/netbox/netbox/scripts:rw

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Configuracao do Postgres
      - DB_HOST=netbox${1:+_$1}_db
      - DB_NAME=netbox${1:+_$1}
      - DB_PASSWORD=$postgres_netbox
      - DB_USER=postgres

    ##  Configuracao do Redis
      - REDIS_HOST=netbox${1:+_$1}_redis
      - REDIS_PASSWORD=
      - REDIS_DATABASE=0
      - REDIS_SSL=false
      - REDIS_INSECURE_SKIP_TLS_VERIFY=false

    ##  Configuracao do Redis
      - REDIS_CACHE_HOST=netbox${1:+_$1}_redis_cache
      - REDIS_CACHE_PASSWORD=
      - REDIS_CACHE_DATABASE=1
      - REDIS_CACHE_SSL=false
      - REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY=false

    ## " SeguranAa e Chaves
      - SECRET_KEY=$secretkey_netbox
      - API_TOKEN_PEPPER_1=$tokenpepper_netbox

    ## Configuracoes da Aplicacao
      - MEDIA_ROOT=/opt/netbox/netbox/media
      - CORS_ORIGIN_ALLOW_ALL=True
      - GRAPHQL_ENABLED=true
      - WEBHOOKS_ENABLED=true
      - METRICS_ENABLED=false
      - SKIP_SUPERUSER=false

    ##  Configuracao de SMTP
      #- EMAIL_FROM=email@dominio.com
      #- EMAIL_USERNAME=email@dominio.com
      #- EMAIL_PASSWORD=@Senha123_
      #- EMAIL_SERVER=smtp.dominio.com
      #- EMAIL_PORT=587
      #- EMAIL_USE_SSL=false
      #- EMAIL_USE_TLS=false
      #- EMAIL_TIMEOUT=5
      #- EMAIL_SSL_CERTFILE=
      #- EMAIL_SSL_KEYFILE=

    ##  Verificacao de Atualizacoes
      - RELEASE_CHECK_URL=https://api.github.com/repos/netbox-community/netbox/releases

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.netbox${1:+_$1}.rule=Host(\`$url_netbox\`)
        - traefik.http.services.netbox${1:+_$1}.loadbalancer.server.port=8080
        - traefik.http.routers.netbox${1:+_$1}.service=netbox${1:+_$1}
        - traefik.http.routers.netbox${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.netbox${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.netbox${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  netbox${1:+_$1}_worker:
    image: docker.io/netboxcommunity/netbox:v4.4-3.4.2
    command:
      - /opt/netbox/venv/bin/python
      - /opt/netbox/netbox/manage.py
      - rqworker

    volumes:
      - netbox${1:+_$1}_media_files:/opt/netbox/netbox/media:rw
      - netbox${1:+_$1}_reports_files:/opt/netbox/netbox/reports:rw
      - netbox${1:+_$1}_scripts_files:/opt/netbox/netbox/scripts:rw

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Configuracao do Postgres
      - DB_HOST=netbox${1:+_$1}_db
      - DB_NAME=netbox${1:+_$1}
      - DB_PASSWORD=$postgres_netbox
      - DB_USER=postgres

    ##  Configuracao do Redis
      - REDIS_HOST=netbox${1:+_$1}_redis
      - REDIS_PASSWORD=
      - REDIS_DATABASE=0
      - REDIS_SSL=false
      - REDIS_INSECURE_SKIP_TLS_VERIFY=false

    ##  Configuracao do Redis
      - REDIS_CACHE_HOST=netbox${1:+_$1}_redis_cache
      - REDIS_CACHE_PASSWORD=
      - REDIS_CACHE_DATABASE=1
      - REDIS_CACHE_SSL=false
      - REDIS_CACHE_INSECURE_SKIP_TLS_VERIFY=false

    ## " SeguranAa e Chaves
      - SECRET_KEY=$secretkey_netbox
      - API_TOKEN_PEPPER_1=$tokenpepper_netbox

    ## Configuracoes da Aplicacao
      - MEDIA_ROOT=/opt/netbox/netbox/media
      - CORS_ORIGIN_ALLOW_ALL=True
      - GRAPHQL_ENABLED=true
      - WEBHOOKS_ENABLED=true
      - METRICS_ENABLED=false
      - SKIP_SUPERUSER=false

    ##  Configuracao de SMTP
      #- EMAIL_FROM=email@dominio.com
      #- EMAIL_USERNAME=email@dominio.com
      #- EMAIL_PASSWORD=@Senha123_
      #- EMAIL_SERVER=smtp.dominio.com
      #- EMAIL_PORT=587
      #- EMAIL_USE_SSL=false
      #- EMAIL_USE_TLS=false
      #- EMAIL_TIMEOUT=5
      #- EMAIL_SSL_CERTFILE=
      #- EMAIL_SSL_KEYFILE=

    ##  Verificacao de Atualizacoes
      - RELEASE_CHECK_URL=https://api.github.com/repos/netbox-community/netbox/releases

    deploy:
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 10
        window: 120s
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  netbox${1:+_$1}_db:
    image: docker.io/postgres:17-alpine

    volumes:
      - netbox${1:+_$1}_db:/var/lib/postgresql/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Configuracao do Postgres
      - POSTGRES_DB=netbox${1:+_$1}
      - POSTGRES_PASSWORD=$postgres_netbox

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  netbox${1:+_$1}_redis:
    image: docker.io/valkey/valkey:8.1-alpine
    command: [
        "valkey-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - netbox${1:+_$1}_redis_data:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  netbox${1:+_$1}_redis_cache:
    image: docker.io/valkey/valkey:8.1-alpine
    command: [
        "valkey-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]
    
    volumes:
      - netbox${1:+_$1}_redis_cache_data:/data
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
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
  netbox${1:+_$1}_media_files:
    external: true
    name: netbox${1:+_$1}_media_files
  netbox${1:+_$1}_db:
    external: true
    name: netbox${1:+_$1}_db
  netbox${1:+_$1}_redis_cache_data:
    external: true
    name: netbox${1:+_$1}_redis_cache_data
  netbox${1:+_$1}_redis_data:
    external: true
    name: netbox${1:+_$1}_redis_data
  netbox${1:+_$1}_reports_files:
    external: true
    name: netbox${1:+_$1}_reports_files
  netbox${1:+_$1}_scripts_files:
    external: true
    name: netbox${1:+_$1}_scripts_files

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do netbox"
fi

STACK_NAME="netbox${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c netbox.yaml netbox > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do netbox"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull docker.io/postgres:17-alpine docker.io/valkey/valkey:8.1-alpine docker.io/netboxcommunity/netbox:v4.4-3.4.2

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack netbox${1:+_$1}_netbox${1:+_$1}_db netbox${1:+_$1}_netbox${1:+_$1}_redis netbox${1:+_$1}_netbox${1:+_$1}_redis_cache netbox${1:+_$1}_netbox${1:+_$1}_app  netbox${1:+_$1}_netbox${1:+_$1}_worker


cd dados_vps

cat > dados_netbox${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ NETBOX ]

Dominio do NetBox: https://$url_netbox

Usuario: admin

Senha: admin
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
echo -e "\e[32m[ NETBOX ]\e[0m"
echo ""

echo -e "\e[33mDominio do NetBox:\e[97m https://$url_netbox\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m admin\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m admin\e[0m"
echo ""

echo -e "\e[33mBiblioteca de Modelos de Dispositivos (BONUS):\e[97m https://github.com/netbox-community/devicetype-library\e[0m"
echo ""

echo -e "\e[97mObservacao:\e[33m Aguarde 5 minutos antes de acessar o NetBox devido as migracoes\e[0m"
echo -e "\e[33mque levam um certo tempo para serem concluidas\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###  ### ###### ###########  ### ###### 
## a-a-a-' a-a-a-"a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-' a-a-a-"a-a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-'
## a-a-a-"a-a-a-a-- a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-- a-a-a-"a-a-a-a-a-'
## ##|  #####|  ##|##|     ##|  #####|  ##|
## a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-  a-a-a-

