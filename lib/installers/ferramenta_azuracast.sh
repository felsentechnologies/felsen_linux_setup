#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_azuracast() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_azuracast

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o AzuraCast (ex: azuracast.example.com): \e[0m" && read -r url_azuracast
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_azuracast
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do azuracast
    echo -e "\e[33mDominio do AzuraCast:\e[97m $url_azuracast\e[0m"
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
        nome_azuracast

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO AZURACAST \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO AZURACAST \e[33m[2/3]\e[0m"
echo ""
sleep 1

azuracast_mysql_password=$(openssl rand -hex 16)

## Criando a stack azuracast.yaml
cat > azuracast${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  azuracast${1:+_$1}_web:
    image: ghcr.io/azuracast/azuracast:latest

    volumes:
      - azuracast${1:+_$1}_station_data:/var/azuracast/stations
      - azuracast${1:+_$1}_backups:/var/azuracast/backups
      - azuracast${1:+_$1}_db_data:/var/lib/mysql
      - azuracast${1:+_$1}_www_uploads:/var/azuracast/storage/uploads
      - azuracast${1:+_$1}_shoutcast2_install:/var/azuracast/storage/shoutcast2
      - azuracast${1:+_$1}_stereo_tool_install:/var/azuracast/storage/stereo_tool
      - azuracast${1:+_$1}_rsas_install:/var/azuracast/storage/rsas
      - azuracast${1:+_$1}_geolite_install:/var/azuracast/storage/geoip
      - azuracast${1:+_$1}_sftpgo_data:/var/azuracast/storage/sftpgo
      - azuracast${1:+_$1}_acme:/var/azuracast/storage/acme

    networks:
      - $nome_rede_interna ## Nome da rede interna
    ports:
      - target: 2022
        published: 2022
        protocol: tcp
        mode: host
      - target: 8005
        published: 8005
        protocol: tcp
        mode: host

    environment:
    ##  Identificacao do Projeto
      - COMPOSE_PROJECT_NAME=azuracast

    ##  Configuracoes de Portas
      - AZURACAST_HTTP_PORT=80
      - AZURACAST_HTTPS_PORT=443
      - AZURACAST_SFTP_PORT=2022

    ##  Configuracoes de Permissoes
      - AZURACAST_PUID=1000
      - AZURACAST_PGID=1000

    ##  Configuracoes de Performance
      - NGINX_TIMEOUT=1800

    ##  Configuracoes do MySQL (INTERNO)
      - ENABLE_INTERNAL_MYSQL=true
      - MYSQL_ROOT_PASSWORD=$azuracast_mysql_password ## Senha do MySQL (INTERNO)
      - MYSQL_DATABASE=azuracast
      - MYSQL_USER=azuracast
      - MYSQL_PASSWORD=$azuracast_mysql_password ## Senha do usuario do MySQL (INTERNO)
      - MYSQL_CHARACTER_SET_SERVER=utf8mb4
      - MYSQL_COLLATION_SERVER=utf8mb4_unicode_ci

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.azuracast${1:+_$1}_web.rule=Host(\`$url_azuracast\`) ## Dominio para aplicacao
        - traefik.http.routers.azuracast${1:+_$1}_web.entrypoints=websecure
        - traefik.http.routers.azuracast${1:+_$1}_web.priority=1
        - traefik.http.routers.azuracast${1:+_$1}_web.tls.certresolver=letsencryptresolver
        - traefik.http.routers.azuracast${1:+_$1}_web.service=azuracast${1:+_$1}_web
        - traefik.http.services.azuracast${1:+_$1}_web.loadbalancer.server.port=80
        - traefik.http.services.azuracast${1:+_$1}_web.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  azuracast${1:+_$1}_updater:
    image: ghcr.io/azuracast/updater:latest

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

    networks:
      - $nome_rede_interna ## Nome da rede interna

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

volumes:
  azuracast${1:+_$1}_station_data:
    external: true
    name: azuracast${1:+_$1}_station_data
  azuracast${1:+_$1}_backups:
    external: true
    name: azuracast${1:+_$1}_backups
  azuracast${1:+_$1}_db_data:
    external: true
    name: azuracast${1:+_$1}_db_data
  azuracast${1:+_$1}_www_uploads:
    external: true
    name: azuracast${1:+_$1}_www_uploads
  azuracast${1:+_$1}_shoutcast2_install:
    external: true
    name: azuracast${1:+_$1}_shoutcast2_install
  azuracast${1:+_$1}_stereo_tool_install:
    external: true
    name: azuracast${1:+_$1}_stereo_tool_install
  azuracast${1:+_$1}_rsas_install:
    external: true
    name: azuracast${1:+_$1}_rsas_install
  azuracast${1:+_$1}_geolite_install:
    external: true
    name: azuracast${1:+_$1}_geolite_install
  azuracast${1:+_$1}_sftpgo_data:
    external: true
    name: azuracast${1:+_$1}_sftpgo_data
  azuracast${1:+_$1}_acme:
    external: true
    name: azuracast${1:+_$1}_acme

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna

__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do AzuraCast"
fi
STACK_NAME="azuracast${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c azuracast.yaml azuracast > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do azuracast"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/azuracast/azuracast:latest ghcr.io/azuracast/updater:latest

## Usa o servico wait_azuracast para verificar se o servico esta online
wait_stack azuracast${1:+_$1}_azuracast${1:+_$1}_web azuracast${1:+_$1}_azuracast${1:+_$1}_updater


cd dados_vps

cat > dados_azuracast${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ AZURACAST ]

Dominio do AzuraCast: https://$url_azuracast

Usuario: Precisa criar no primeiro acesso do AzuraCast

Senha: Precisa criar no primeiro acesso do AzuraCast

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
echo -e "\e[32m[ AZURACAST ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_azuracast\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do AzuraCast\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do AzuraCast\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########  ######     #######   ######  ###
## a-a-a-"a-a-a-a-a-a-a-a-'  a-a-a-'a-a-a-'     a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-' a-a-a-"a-
## a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'a-a-a-'     a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-"a- 
## a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-'a-a-a-'     a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-- 
## #######|##|  ##|##########|##| #####|##|  ###
## a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-  a-a-a-

