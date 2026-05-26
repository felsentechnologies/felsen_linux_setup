#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_lowcoder() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_lowcoder

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para o Lowcoder (ex: lowcoder.example.com): \e[0m" && read -r url_lowcoder
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 2/8\e[0m"
    echo -en "\e[33mDigite um email para o Super Admin (ex: contato@example.com): \e[0m" && read -r email_super_admin_lowcoder
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 3/8\e[0m"
    echo -en "\e[33mDigite a senha do Super Admin (ex: @Senha123_): \e[0m" && read -r pass_super_admin_lowcoder
    echo ""

    ## Pergunta o email SMTP
    echo -e "\e[97mPasso$amarelo 4/8\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_lowcoder
    echo ""

    ## Pergunta o Ususario SMTP
    echo -e "\e[97mPasso$amarelo 5/8\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_smtp_lowcoder
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 6/8\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_smtp_lowcoder
    echo ""
    
    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 7/8\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_lowcoder
    echo ""
    
    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 8/8\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_lowcoder
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_lowcoder
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    pegar_senha_mongodb

    ## Informacao sobre URL
    echo -e "\e[33mDominio da lowcoder:\e[97m $url_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mEmail do Super Admin:\e[97m $email_super_admin_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do Super Admin:\e[97m $pass_super_admin_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mEmail SMTP:\e[97m $email_smtp_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mUser SMTP:\e[97m $user_smtp_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha SMTP:\e[97m $senha_smtp_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mHost SMTP:\e[97m $host_smtp_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_lowcoder\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mUsuario do MongoDB:\e[97m $user_mongo\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do MongoDB:\e[97m $pass_mongo\e[0m"
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_lowcoder" -eq 465 ]; then
    smtp_secure_lowcoder_ssl=true
    smtp_secure_lowcoder_startls=false
    else
    smtp_secure_lowcoder_ssl=false
    smtp_secure_lowcoder_startls=true
    fi

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
        nome_lowcoder

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO LOWCODER \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Literalmente nada, apenas um espaco vazio caso precisar de adicionar alguma coisa
## Antes..
## E claro, para aparecer a mensagem do passo..

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO O LOWCODER \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Gerando Encryption
encryption_key_lowcoder1=$(openssl rand -hex 16)
encryption_key_lowcoder2=$(openssl rand -hex 16)
encryption_key_lowcoder3=$(openssl rand -hex 32)
encryption_key_lowcoder4=$(openssl rand -hex 32)

## Pegando ip da vps
read -r ip _ <<<$(hostname -I)

## Criando a stack lowcoder.yaml
cat > lowcoder${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  lowcoder${1:+_$1}_api:
    image: lowcoderorg/lowcoder-ce-api-service:latest

    networks:
      - $nome_rede_interna

    environment:
    ##  Dados do Super Admin
      - LOWCODER_SUPERUSER_USERNAME=$email_super_admin_lowcoder
      - LOWCODER_SUPERUSER_PASSWORD=$pass_super_admin_lowcoder
      - LOWCODER_EMAIL_SIGNUP_ENABLED=false ## true = permitir criar novas contas

    ##  Dominio
      - LOWCODER_PUBLIC_URL=https://$url_lowcoder/
      - LOWCODER_NODE_SERVICE_URL=http://lowcoder${1:+_$1}_node:6060

    ##  Dados MongoDB
      - LOWCODER_MONGODB_URL=mongodb://$user_mongo:$pass_mongo@mongodb:27017/lowcoder${1:+_$1}?authSource=admin&readPreference=primary&ssl=false&directConnection=true

    ##  Dados Redis
      - LOWCODER_REDIS_URL=redis://lowcoder${1:+-$1}-redis:6379

    ## Dados SMTP
      - LOWCODER_ADMIN_SMTP_HOST=$host_smtp_lowcoder
      - LOWCODER_ADMIN_SMTP_PORT=$porta_smtp_lowcoder
      - LOWCODER_ADMIN_SMTP_USERNAME=$user_smtp_lowcoder
      - LOWCODER_ADMIN_SMTP_PASSWORD=$senha_smtp_lowcoder
      - LOWCODER_ADMIN_SMTP_AUTH=true
      - LOWCODER_ADMIN_SMTP_SSL_ENABLED=$smtp_secure_lowcoder_ssl
      - LOWCODER_ADMIN_SMTP_STARTTLS_ENABLED=$smtp_secure_lowcoder_startls
      - LOWCODER_ADMIN_SMTP_STARTTLS_REQUIRED=$smtp_secure_lowcoder_startls
      - LOWCODER_EMAIL_NOTIFICATIONS_SENDER=$email_smtp_lowcoder

    ## Configuracoes
      - LOWCODER_MAX_QUERY_TIMEOUT=120
      - LOWCODER_EMAIL_AUTH_ENABLED=true
      - LOWCODER_CREATE_WORKSPACE_ON_SIGNUP=true ## true = permitir criar novos workspaces
      - LOWCODER_WORKSPACE_MODE=SAAS

    ##  Encryption
      - LOWCODER_DB_ENCRYPTION_PASSWORD=$encryption_key_lowcoder1 ## hash Encryption
      - LOWCODER_DB_ENCRYPTION_SALT=$encryption_key_lowcoder2 ## hash Encryption
      - LOWCODER_API_KEY_SECRET=$encryption_key_lowcoder3 # hash Encryption
      - LOWCODER_NODE_SERVICE_SECRET=$encryption_key_lowcoder4
      - LOWCODER_NODE_SERVICE_SECRET_SALT=lowcoder.org

    ##  Outras configuracoes
      - LOWCODER_CORS_DOMAINS=*
      - LOWCODER_MAX_ORGS_PER_USER=100
      - LOWCODER_MAX_MEMBERS_PER_ORG=1000
      - LOWCODER_MAX_GROUPS_PER_ORG=100
      - LOWCODER_MAX_APPS_PER_ORG=1000
      - LOWCODER_MAX_DEVELOPERS=50
    
    ## " User ID e Group ID
      - LOWCODER_PUID=9001
      - LOWCODER_PGID=9001

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
        - traefik.http.routers.lowcoder${1:+_$1}_api.rule=Host(\`$url_lowcoder\`) && PathPrefix(\`/api\`)
        - traefik.http.services.lowcoder${1:+_$1}_api.loadbalancer.server.port=8080
        - traefik.http.routers.lowcoder${1:+_$1}_api.service=lowcoder${1:+_$1}_api
        - traefik.http.routers.lowcoder${1:+_$1}_api.entrypoints=websecure
        - traefik.http.routers.lowcoder${1:+_$1}_api.tls.certresolver=letsencryptresolver
        - traefik.http.routers.lowcoder${1:+_$1}_api.tls=true

## --------------------------- FELSEN --------------------------- ##

  lowcoder${1:+_$1}_node:
    image: lowcoderorg/lowcoder-ce-node-service:latest

    networks:
      - $nome_rede_interna

    environment:
    ## " User ID e Group ID
      - LOWCODER_PUID=9001
      - LOWCODER_PGID=9001
    
    ##  API Service URL
      - LOWCODER_API_SERVICE_URL=http://lowcoder${1:+_$1}_api:8080

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  lowcoder${1:+_$1}_frontend:
    image: lowcoderorg/lowcoder-ce-frontend:latest

    volumes:
     - lowcoder${1:+_$1}_assets:/lowcoder/assets

    networks:
      - $nome_rede_interna

    environment:
    ##  URLs de Servicos Internos
      - LOWCODER_API_SERVICE_URL=http://lowcoder${1:+_$1}_api:8080
      - LOWCODER_NODE_SERVICE_URL=http://lowcoder${1:+_$1}_node:6060
    
    ## Configuracoes Gerais
      - LOWCODER_MAX_REQUEST_SIZE=20m
      - LOWCODER_MAX_QUERY_TIMEOUT=120
    
    ##  Seguranca & Chaves
      - LOWCODER_NODE_SERVICE_SECRET=$encryption_key_lowcoder4
      - LOWCODER_NODE_SERVICE_SECRET_SALT=lowcoder.org

    ## " User ID e Group ID
      - LOWCODER_PUID=9001
      - LOWCODER_PGID=9001

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager  
      labels:
        - traefik.enable=true
        - traefik.http.routers.lowcoder${1:+_$1}_frontend.rule=Host(\`$url_lowcoder\`) && PathPrefix(\`/\`)
        - traefik.http.services.lowcoder${1:+_$1}_frontend.loadbalancer.server.port=3000
        - traefik.http.routers.lowcoder${1:+_$1}_frontend.service=lowcoder${1:+_$1}_frontend
        - traefik.http.routers.lowcoder${1:+_$1}_frontend.entrypoints=websecure
        - traefik.http.routers.lowcoder${1:+_$1}_frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.lowcoder${1:+_$1}_frontend.tls=true

## --------------------------- FELSEN --------------------------- ##

  lowcoder${1:+-$1}-redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - lowcoder${1:+_$1}_redis:/data

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
  lowcoder${1:+_$1}_assets:
    external: true
    name: lowcoder${1:+_$1}_assets
  lowcoder${1:+_$1}_redis:
    external: true
    name: lowcoder${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da Lowcoder"
fi
STACK_NAME="lowcoder${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c lowcoder.yaml lowcoder > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack da lowcoder"
#fi

sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest lowcoderorg/lowcoder-ce-api-service:latest lowcoderorg/lowcoder-ce-node-service:latest lowcoderorg/lowcoder-ce-frontend:latest

## Usa o servico wait_stack "lowcoder" para verificar se o servico esta online
wait_stack lowcoder${1:+_$1}_lowcoder${1:+-$1}-redis lowcoder${1:+_$1}_lowcoder${1:+_$1}_api lowcoder${1:+_$1}_lowcoder${1:+_$1}_node lowcoder${1:+_$1}_lowcoder${1:+_$1}_frontend


cd dados_vps

cat > dados_lowcoder${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ LOWCODER ]

Link do Lowcoder: https://$url_lowcoder

Usuario: $email_super_admin_lowcoder

Senha: $pass_super_admin_lowcoder

API_KEY: $encryption_key_lowcoder3
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
echo -e "\e[32m[ LOWCODER ]\e[0m"
echo ""

echo -e "\e[97mLink do Lowcoder:\e[33m https://$url_lowcoder\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m $email_super_admin_lowcoder\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m $pass_super_admin_lowcoder\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###      ###### ####   ### ####### ###########      ####### ###    ###
## a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a- a-a-a-"a-a-a-a-a-a-a-a-'     a-a-a-"a-a-a-a-a-a--a-a-a-'    a-a-a-'
## ##|     #######|###### ##|##|  ##########  ##|     ##|   ##|##| ## ##|
## a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-  a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-"a-
## a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a- 

