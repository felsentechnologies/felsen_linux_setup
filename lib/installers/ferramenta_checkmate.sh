#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_checkmate() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados
pegar_senha_mongodb

## Mostra o nome da aplicacao
nome_checkmate

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o Dominio para o Checkmate (ex: checkmate.example.com): \e[0m" && read -r url_checkmate
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -en "\e[33mDigite o Dominio para a API do Checkmate (ex: checkmate-api.example.com): \e[0m" && read -r url_checkmate_api
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_checkmate
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do checkmate:\e[97m $url_checkmate\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mDominio da API do checkmate:\e[97m $url_checkmate_api\e[0m"
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
        nome_checkmate

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO CHECKMATE \e[33m[1/3]\e[0m"
echo ""
sleep 1



echo -e "\e[97m- INSTALANDO CHECKMATE \e[33m[2/3]\e[0m"
echo ""
sleep 1

secretkey_checkmate=$(openssl rand -hex 16)

## Criando a stack checkmate.yaml
cat > checkmate${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  checkmate${1:+_$1}_client:
    image: ghcr.io/bluewave-labs/checkmate-client:latest

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Url do Frontend
      - UPTIME_APP_CLIENT_HOST=https://$url_checkmate

    ##  Url do Backend
      - UPTIME_APP_API_BASE_URL=https://$url_checkmate_api/api/v1
    
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
        - traefik.http.routers.checkmate${1:+_$1}_client.rule=Host(\`$url_checkmate\`)
        - traefik.http.services.checkmate${1:+_$1}_client.loadbalancer.server.port=80
        - traefik.http.routers.checkmate${1:+_$1}_client.service=checkmate${1:+_$1}_client
        - traefik.http.routers.checkmate${1:+_$1}_client.tls.certresolver=letsencryptresolver
        - traefik.http.routers.checkmate${1:+_$1}_client.entrypoints=websecure
        - traefik.http.routers.checkmate${1:+_$1}_client.tls=true

## --------------------------- FELSEN --------------------------- ##

  checkmate${1:+_$1}_server:
    image: ghcr.io/bluewave-labs/checkmate-backend:latest

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock

    networks:
       $nome_rede_interna: ## Nome da rede interna
        aliases:
          - server 

    environment:
    ##  Configuracoes de URLs e Hosts
      - VITE_APP_API_BASE_URL=https://$url_checkmate_api/api/v1
      - VITE_APP_CLIENT_HOST=https://$url_checkmate
      - UPTIME_APP_CLIENT_HOST=https://$url_checkmate
      - CLIENT_HOST=https://$url_checkmate

    ## Configuracoes da Aplicacao
      - VITE_APP_LOG_LEVEL=info

    ## -"i Configuracoes do Banco de Dados
      - DB_CONNECTION_STRING=mongodb://$user_mongo:$pass_mongo@mongodb:27017/checkmate${1:+_$1}?authSource=admin

    ##  Configuracoes do Redis
      - REDIS_URL=redis://checkmate${1:+_$1}_redis:6379

    ## " Configuracoes de SeguranAa
      - JWT_SECRET=$secretkey_checkmate

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
        - traefik.http.routers.checkmate${1:+_$1}_server.rule=Host(\`$url_checkmate_api\`)
        - traefik.http.services.checkmate${1:+_$1}_server.loadbalancer.server.port=52345
        - traefik.http.routers.checkmate${1:+_$1}_server.service=checkmate${1:+_$1}_server
        - traefik.http.routers.checkmate${1:+_$1}_server.tls.certresolver=letsencryptresolver
        - traefik.http.routers.checkmate${1:+_$1}_server.entrypoints=websecure
        - traefik.http.routers.checkmate${1:+_$1}_server.tls=true

## --------------------------- FELSEN --------------------------- ##

  checkmate${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - checkmate${1:+_$1}_redis:/data

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
  checkmate${1:+_$1}_data:
    external: true
    name: checkmate${1:+_$1}_data
  checkmate${1:+_$1}_redis:
    external: true
    name: checkmate${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do checkmate"
fi

STACK_NAME="checkmate${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c checkmate.yaml checkmate > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do checkmate"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest ghcr.io/bluewave-labs/checkmate-client:latest ghcr.io/bluewave-labs/checkmate-backend:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack checkmate${1:+_$1}_checkmate${1:+_$1}_redis checkmate${1:+_$1}_checkmate${1:+_$1}_server checkmate${1:+_$1}_checkmate${1:+_$1}_client 


cd dados_vps

cat > dados_checkmate${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ CHECKMATE ]

Dominio do checkmate: https://$url_checkmate

Dominio da API do checkmate: https://$url_checkmate_api
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
echo -e "\e[32m[ CHECKMATE ]\e[0m"
echo ""

echo -e "\e[33mDominio do checkmate:\e[97m https://$url_checkmate\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no Checkmate\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no Checkmate\e[0m"
echo ""

echo -e "\e[33mDominio da API do checkmate:\e[97m https://$url_checkmate_api\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###  ##############   ########### ####### ####### ####   ####
## a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'
## a-a-a-a-a-a-a-a-'a-a-a-a-a-a--   a-a-a-a-a-a-"a- a-a-a-a-a-a--  a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-"a-a-a-'
## a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-    a-a-a-a-"a-  a-a-a-"a-a-a-  a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-"a-a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-'     a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a-   a-a-a-   a-a-a-      a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-     a-a-a-

