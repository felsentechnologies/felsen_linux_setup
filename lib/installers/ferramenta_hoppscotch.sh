#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_hoppscotch() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_hoppscotch

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/8\e[0m"
    echo -en "\e[33mDigite o dominio para o Frontend do Hoppscotch (ex: hoppscotch.example.com): \e[0m" && read -r url_hoppscotch_frontend
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/8\e[0m"
    echo -en "\e[33mDigite o dominio para a API Admin do Hoppscotch (ex: admin-hoppscotch.example.com): \e[0m" && read -r url_hoppscotch_admin
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/8\e[0m"
    echo -en "\e[33mDigite o dominio para a API Backend do Hoppscotch (ex: backend-hoppscotch.example.com): \e[0m" && read -r url_hoppscotch_backend
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 4/8\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r hoppscotch_smtp_email
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 5/8\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r hoppscotch_smtp_user
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 6/8\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r hoppscotch_smtp_pass
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 7/8\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r hoppscotch_smtp_host
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 8/8\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r hoppscotch_smtp_port
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_typebot" -eq 465 ]; then
    hoppscotch_smtp_secure=true
    else
    hoppscotch_smtp_secure=false
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_hoppscotch
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do hoppscotch
    echo -e "\e[33mDominio Frontend do Hoppscotch:\e[97m $url_hoppscotch_frontend\e[0m"
    echo ""

    ## Informacao sobre URL do hoppscotch
    echo -e "\e[33mDominio Admin do Hoppscotch:\e[97m $url_hoppscotch_admin\e[0m"
    echo ""

    ## Informacao sobre URL do hoppscotch
    echo -e "\e[33mDominio Backend do Hoppscotch:\e[97m $url_hoppscotch_backend\e[0m"
    echo ""

    ## Informacao sobre Email SMTP
    echo -e "\e[33mEmail SMTP:\e[97m $hoppscotch_smtp_email\e[0m"
    echo ""

    ## Informacao sobre Usuario SMTP
    echo -e "\e[33mUsuario SMTP:\e[97m $hoppscotch_smtp_user\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP:\e[97m $hoppscotch_smtp_host\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP:\e[97m $hoppscotch_smtp_port\e[0m"
    echo ""

    ## Informacao sobre SSL SMTP
    echo -e "\e[33mSSL SMTP:\e[97m $hoppscotch_smtp_secure\e[0m"
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
        nome_hoppscotch

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO HOPPSCOTCH \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Cansei ja de explicar o que isso faz kkkk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "hoppscotch${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "hoppscotch${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO HOPPSCOTCH \e[33m[3/4]\e[0m"
echo ""
sleep 1

encryption_key=$(openssl rand -hex 16)
jwt_secret_key=$(openssl rand -hex 16)
sesstion_secret_key=$(openssl rand -hex 16)

## Criando a stack hoppscotch.yaml
cat > hoppscotch${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.8"
services:

## --------------------------- FELSEN --------------------------- ##

  hoppscotch${1:+_$1}_app:
    image: hoppscotch/hoppscotch-frontend:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  URLs do Aplicativo
      - VITE_BASE_URL=https://$url_hoppscotch_frontend
      - VITE_SHORTCODE_BASE_URL=https://$url_hoppscotch_frontend
      - VITE_ADMIN_URL=https://$url_hoppscotch_admin
      - VITE_BACKEND_GQL_URL=https://$url_hoppscotch_backend/graphql
      - VITE_BACKEND_WS_URL=wss://$url_hoppscotch_backend/graphql
      - VITE_BACKEND_API_URL=https://$url_hoppscotch_backend/v1

    ## " Provedores de AutenticaAAo
      - VITE_ALLOWED_AUTH_PROVIDERS=EMAIL ## Opcoes: EMAIL,GOOGLE,GITHUB,MICROSOFT

    ##  Termos e Privacidade
      - VITE_APP_TOS_LINK=https://docs.hoppscotch.io/support/terms
      - VITE_APP_PRIVACY_POLICY_LINK=https://docs.hoppscotch.io/support/privacy

    ## i Acesso via Subpath
      - ENABLE_SUBPATH_BASED_ACCESS=false

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.hoppscotch${1:+_$1}_app.rule=Host(\`$url_hoppscotch_frontend\`) ## Dominio para aplicacao
        - traefik.http.routers.hoppscotch${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.hoppscotch${1:+_$1}_app.priority=1
        - traefik.http.routers.hoppscotch${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.hoppscotch${1:+_$1}_app.service=hoppscotch${1:+_$1}_app
        - traefik.http.services.hoppscotch${1:+_$1}_app.loadbalancer.server.port=3000
        - traefik.http.services.hoppscotch${1:+_$1}_app.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  hoppscotch${1:+_$1}_admin:
    image: hoppscotch/hoppscotch-admin:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  URLs do Aplicativo
      - VITE_BASE_URL=https://$url_hoppscotch_frontend
      - VITE_SHORTCODE_BASE_URL=https://$url_hoppscotch_frontend
      - VITE_ADMIN_URL=https://$url_hoppscotch_admin
      - VITE_BACKEND_GQL_URL=https://$url_hoppscotch_backend/graphql
      - VITE_BACKEND_WS_URL=wss://$url_hoppscotch_backend/graphql
      - VITE_BACKEND_API_URL=https://$url_hoppscotch_backend/v1

    ## " Provedores de AutenticaAAo
      - VITE_ALLOWED_AUTH_PROVIDERS=EMAIL ## Opcoes: EMAIL,GOOGLE,GITHUB,MICROSOFT

    ##  Termos e Privacidade
      - VITE_APP_TOS_LINK=https://docs.hoppscotch.io/support/terms
      - VITE_APP_PRIVACY_POLICY_LINK=https://docs.hoppscotch.io/support/privacy

    ## i Acesso via Subpath
      - ENABLE_SUBPATH_BASED_ACCESS=false
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.hoppscotch${1:+_$1}_admin.rule=Host(\`$url_hoppscotch_admin\`) ## Dominio para aplicacao
        - traefik.http.routers.hoppscotch${1:+_$1}_admin.entrypoints=websecure
        - traefik.http.routers.hoppscotch${1:+_$1}_admin.priority=1
        - traefik.http.routers.hoppscotch${1:+_$1}_admin.tls.certresolver=letsencryptresolver
        - traefik.http.routers.hoppscotch${1:+_$1}_admin.service=hoppscotch${1:+_$1}_admin
        - traefik.http.services.hoppscotch${1:+_$1}_admin.loadbalancer.server.port=3100
        - traefik.http.services.hoppscotch${1:+_$1}_admin.loadbalancer.passHostHeader=true
        
## --------------------------- FELSEN --------------------------- ##

  hoppscotch${1:+_$1}_backend:
    image: hoppscotch/hoppscotch-backend:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  Dados do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/hoppscotch${1:+_$1}

    ## Configuracoes do App
      - REDIRECT_URL=https://$url_hoppscotch_frontend
      - WHITELISTED_ORIGINS=https://$url_hoppscotch_frontend,https://$url_hoppscotch_admin
      - VITE_BASE_URL=https://$url_hoppscotch_frontend
      - VITE_ADMIN_URL=https://$url_hoppscotch_admin

    ## " Provedores de AutenticaAAo
      - VITE_ALLOWED_AUTH_PROVIDERS=EMAIL ## Opcoes: EMAIL,GOOGLE,GITHUB,MICROSOFT

    ##  E-mail SMTP
      - MAILER_SMTP_ENABLE=true
      - MAILER_USE_CUSTOM_CONFIGS=true
      - MAILER_ADDRESS_FROM=$hoppscotch_smtp_email
      - MAILER_SMTP_USER=$hoppscotch_smtp_user
      - MAILER_SMTP_PASSWORD=$hoppscotch_smtp_pass
      - MAILER_SMTP_HOST=$hoppscotch_smtp_host
      - MAILER_SMTP_PORT=$hoppscotch_smtp_port
      - MAILER_SMTP_SECURE=$hoppscotch_smtp_secure
      - MAILER_TLS_REJECT_UNAUTHORIZED=true

    ## i Configuracoes de SeguranAa
      - DATA_ENCRYPTION_KEY=$encryption_key
      - JWT_SECRET=$jwt_secret_key
      - TOKEN_SALT_COMPLEXITY=10
      - MAGIC_LINK_TOKEN_VALIDITY=3
      - REFRESH_TOKEN_VALIDITY=604800000
      - ACCESS_TOKEN_VALIDITY=86400000
      - SESSION_SECRET=$sesstion_secret_key
      - ALLOW_SECURE_COOKIES=true

    ##  Rate Limit
      - RATE_LIMIT_TTL=60
      - RATE_LIMIT_MAX=100

    ##  Auth Google
      - GOOGLE_CLIENT_ID=disabled
      - GOOGLE_CLIENT_SECRET=disabled
      - GOOGLE_CALLBACK_URL=https://$url_hoppscotch_backend/v1/auth/google/callback
      - GOOGLE_SCOPE=email,profile
  
    ##  Auth Github
      - GITHUB_CLIENT_ID=disabled
      - GITHUB_CLIENT_SECRET=disabled
      - GITHUB_CALLBACK_URL=https://$url_hoppscotch_backend/v1/auth/github/callback
      - GITHUB_SCOPE=user:email

    ##  Auth Microsoft
      - MICROSOFT_CLIENT_ID=disabled
      - MICROSOFT_CLIENT_SECRET=disabled
      - MICROSOFT_CALLBACK_URL=https://$url_hoppscotch_backend/v1/auth/microsoft/callback
      - MICROSOFT_SCOPE=user.read
      - MICROSOFT_TENANT=common   

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.hoppscotch${1:+_$1}_backend.rule=Host(\`$url_hoppscotch_backend\`) ## Dominio para aplicacao
        - traefik.http.routers.hoppscotch${1:+_$1}_backend.entrypoints=websecure
        - traefik.http.routers.hoppscotch${1:+_$1}_backend.priority=1
        - traefik.http.routers.hoppscotch${1:+_$1}_backend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.hoppscotch${1:+_$1}_backend.service=hoppscotch${1:+_$1}_backend
        - traefik.http.services.hoppscotch${1:+_$1}_backend.loadbalancer.server.port=3170
        - traefik.http.services.hoppscotch${1:+_$1}_backend.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  hoppscotch${1:+_$1}_migrate:
    image: hoppscotch/hoppscotch-backend:latest
    command: sh -c "sleep 30 && pnpx prisma migrate deploy"

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  Dados do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/hoppscotch${1:+_$1}
    
    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: none
      placement:
        constraints:
          - node.role == manager      

## --------------------------- FELSEN --------------------------- ##

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Hoppscotch"
fi
STACK_NAME="hoppscotch${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c hoppscotch.yaml hoppscotch > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do hoppscotch"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull hoppscotch/hoppscotch-backend:latest hoppscotch/hoppscotch-frontend:latest hoppscotch/hoppscotch-admin:latest

## Usa o servico wait_hoppscotch para verificar se o servico esta online
wait_stack hoppscotch${1:+_$1}_hoppscotch${1:+_$1}_migrate hoppscotch${1:+_$1}_hoppscotch${1:+_$1}_app hoppscotch${1:+_$1}_hoppscotch${1:+_$1}_admin hoppscotch${1:+_$1}_hoppscotch${1:+_$1}_backend


cd dados_vps

cat > dados_hoppscotch${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ HOPPSCOTCH ]

Dominio do hoppscotch: https://$url_hoppscotch_frontend

Usuario: Precisa criar no Hoppscotch

Senha: Precisa criar no Hoppscotch

Dominio do Admin: https://$url_hoppscotch_admin

Dominio do Backend API: https://$url_hoppscotch_backend
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
echo -e "\e[32m[ HOPPSCOTCH ]\e[0m"
echo ""

echo -e "\e[33mDominio do App:\e[97m https://$url_hoppscotch_frontend\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no Hoppscotch\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no Hoppscotch\e[0m"
echo ""

echo -e "\e[33mDominio do Admin:\e[97m https://$url_hoppscotch_admin\e[0m"
echo ""

echo -e "\e[33mDominio do Backend API:\e[97m https://$url_hoppscotch_backend\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ################  ###### ####   ########### ############## ###########   ###########
## a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-
##    a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-'   a-a-a-'a-a-a-a-a-a--  
##    a-a-a-'   a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-  
##    a-a-a-'   a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a--
##    a-a-a-   a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-  a-a-a-a-a-a-a-a-
##                                                                                     
##                                ######## ###### #######                             
##                                a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--                            
##                                  a-a-a-a-"a- a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-                            
##                                 a-a-a-a-"a-  a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-                             
##                                ##########|  ##|##|                                 
##                                a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-                                 

