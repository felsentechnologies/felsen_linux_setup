#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_authentik() {
## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_authentik

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para o Authentik (ex: authentik.example.com): \e[0m" && read -r url_authentik
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o email para o Authentik (ex: FELSEN@example.com): \e[0m" && read -r email_authentik
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite o senha para o Authentik (ex: @Senha123_): \e[0m" && read -r senha_authentik
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_authentik
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do authentik:\e[97m $url_authentik\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mEmail do authentik:\e[97m $email_authentik\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do authentik:\e[97m $senha_authentik\e[0m"
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
        nome_authentik

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO AUTHENTIK \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO AUTHENTIK \e[33m[2/4]\e[0m"
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
    criar_banco_postgres_da_stack "authentik${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "authentik${1:+_$1}"
fi

echo -e "\e[97m- INSTALANDO AUTHENTIK \e[33m[3/4]\e[0m"
echo ""
sleep 1

secretkey_authentik=$(openssl rand -hex 16)

## Criando a stack authentik.yaml
cat > authentik${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  authentik${1:+_$1}_server:
    image: ghcr.io/goauthentik/server:latest
    command: server
    
    volumes:
    - authentik${1:+_$1}_media:/data/media
    - authentik${1:+_$1}_templates:/templates

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Dados de acesso
      - AUTHENTIK_BOOTSTRAP_EMAIL=$email_authentik
      - AUTHENTIK_BOOTSTRAP_PASSWORD=$senha_authentik

    ##  Configuracao do PostgreSQL
      - AUTHENTIK_POSTGRESQL__HOST=postgres
      - AUTHENTIK_POSTGRESQL__NAME=authentik${1:+_$1}
      - AUTHENTIK_POSTGRESQL__PASSWORD=$senha_postgres
      - AUTHENTIK_POSTGRESQL__USER=postgres
    
    ##  Configuracao do Redis
      - AUTHENTIK_REDIS__HOST=authentik${1:+_$1}_redis
      - AUTHENTIK_REDIS__PORT=6379

    ##  Secret Key
      - AUTHENTIK_SECRET_KEY=$secretkey_authentik
    
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
        - traefik.http.routers.authentik${1:+_$1}_server.rule=Host(\`$url_authentik\`)
        - traefik.http.services.authentik${1:+_$1}_server.loadbalancer.server.port=9000
        - traefik.http.routers.authentik${1:+_$1}_server.service=authentik${1:+_$1}_server
        - traefik.http.routers.authentik${1:+_$1}_server.tls.certresolver=letsencryptresolver
        - traefik.http.routers.authentik${1:+_$1}_server.entrypoints=websecure
        - traefik.http.routers.authentik${1:+_$1}_server.tls=true

## --------------------------- FELSEN --------------------------- ##

  authentik${1:+_$1}_worker:
    image: ghcr.io/goauthentik/server:latest
    command: worker
   
    volumes:
    - /var/run/docker.sock:/var/run/docker.sock
    - authentik${1:+_$1}_media:/data/media
    - authentik${1:+_$1}_certs:/certs
    - authentik${1:+_$1}_templates:/templates

    networks:
      - $nome_rede_interna

    environment:
    ## " Dados de acesso
      - AUTHENTIK_BOOTSTRAP_EMAIL=$email_authentik
      - AUTHENTIK_BOOTSTRAP_PASSWORD=$senha_authentik

    ##  Configuracao do PostgreSQL
      - AUTHENTIK_POSTGRESQL__HOST=postgres
      - AUTHENTIK_POSTGRESQL__NAME=authentik${1:+_$1}
      - AUTHENTIK_POSTGRESQL__PASSWORD=$senha_postgres
      - AUTHENTIK_POSTGRESQL__USER=postgres
    
    ##  Configuracao do Redis
      - AUTHENTIK_REDIS__HOST=authentik${1:+_$1}_redis
      - AUTHENTIK_REDIS__PORT=6379

    ##  Secret Key
      - AUTHENTIK_SECRET_KEY=$secretkey_authentik
    
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

  authentik${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - authentik${1:+_$1}_redis:/data

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
  authentik${1:+_$1}_media:
    external: true
    name: authentik${1:+_$1}_media
  authentik${1:+_$1}_templates:
    external: true
    name: authentik${1:+_$1}_templates
  authentik${1:+_$1}_certs:
    external: true
    name: authentik${1:+_$1}_certs
  authentik${1:+_$1}_redis:
    external: true
    name: authentik${1:+_$1}_redis


networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Authentik"
fi

STACK_NAME="authentik${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c authentik.yaml authentik > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do authentik"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest ghcr.io/goauthentik/server:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack authentik${1:+_$1}_authentik${1:+_$1}_redis authentik${1:+_$1}_authentik${1:+_$1}_worker authentik${1:+_$1}_authentik${1:+_$1}_server 


cd dados_vps

cat > dados_authentik${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ AUTHENTIK ]

Dominio do authentik: https://$url_authentik

Email: $email_authentik

Senha: $senha_authentik
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
echo -e "\e[32m[ AUTHENTIK ]\e[0m"
echo ""

echo -e "\e[33mDominio do authentik:\e[97m https://$url_authentik\e[0m"
echo ""

echo -e "\e[33mEmail do authentik:\e[97m $email_authentik\e[0m"
echo ""

echo -e "\e[33mSenha do authentik:\e[97m $senha_authentik\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ##########  ########### ##########  #######   #### ###### #################
## a-a-a-"a-a-a-a-a-a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-' a-a-a-"a-a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-a-a-a--  a-a-a-'     a-a-a-a-a-a-"a- a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-a-a-a--  
## a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-'     a-a-a-"a-a-a-a-- a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a-a-'   a-a-a-'   a-a-a-"a-a-a-  
## a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-'  a-a-a--a-a-a-' a-a-a- a-a-a-'a-a-a-'  a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a--
##  a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-a-a-a-  a-a-a-   a-a-a-   a-a-a-a-a-a-a-a-

