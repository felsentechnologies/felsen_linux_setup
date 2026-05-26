#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_documenso() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_documenso

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do Builder
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para o Builder do Documenso (ex: documenso.example.com): \e[0m" && read -r url_documenso
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_documenso
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_email_documenso
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_documenso
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_documenso
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_documenso
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_documenso" -eq 465 ]; then
    smtp_secure_documenso=true
    else
    smtp_secure_documenso=false
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_documenso
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Builder
    echo -e "\e[33mDominio do Documenso:\e[97m $url_documenso\e[0m"
    echo "" 

    ## Informacao sobre Email
    echo -e "\e[33mEmail do SMTP:\e[97m $email_documenso\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mUsuario do SMTP:\e[97m $usuario_email_documenso\e[0m"
    echo ""

    ## Informacao sobre Senha do Email
    echo -e "\e[33mSenha do Email:\e[97m $senha_email_documenso\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP do Email:\e[97m $smtp_email_documenso\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP do Email:\e[97m $porta_smtp_documenso\e[0m"
    echo ""

    ## Informacao sobre Secure SMTP
    echo -e "\e[33mSecure SMTP do Email:\e[97m $smtp_secure_documenso\e[0m"
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
        nome_documenso

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done


## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO DOCUMENSO \e[33m[1/5]\e[0m"
echo ""
sleep 1


## Nada nada nada.. so para aparecer a mensagem de passo..

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/5]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres
## Verifica container postgres e cria banco no postgres
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "documenso${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "documenso${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[3/5]\e[0m"
echo ""
sleep 1

pegar_senha_minio
minio.bucket documenso${1:+-$1} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
else
    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
    echo ""
fi

echo ""
## Mensagem de Passo
echo -e "\e[97m- INSTALANDO DOCUMENSO \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
key_documenso1=$(openssl rand -hex 16)
key_documenso2=$(openssl rand -hex 16)
key_documenso3=$(openssl rand -hex 16)

## Criando a stack documenso.yaml
cat > documenso${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  documenso${1:+_$1}:
    image: documenso/documenso:latest

    volumes:
      - documenso${1:+_$1}_cert:/opt/documenso/cert.p12

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Dados de Acesso
      - PORT=3000
      - NEXTAUTH_URL=https://$url_documenso
      - NEXT_PUBLIC_WEBAPP_URL=https://$url_documenso
      - NEXT_PUBLIC_MARKETING_URL=https://example.com

    ##  Secret Keys
      - NEXTAUTH_SECRET=$key_documenso1
      - NEXT_PRIVATE_ENCRYPTION_KEY=$key_documenso2
      - NEXT_PRIVATE_ENCRYPTION_SECONDARY_KEY=$key_documenso3

    ## Dados do Google Cloud
      #- NEXT_PRIVATE_GOOGLE_CLIENT_ID=
      #- NEXT_PRIVATE_GOOGLE_CLIENT_SECRET=

    ##  Dados Postgres
      - NEXT_PRIVATE_DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/documenso${1:+_$1}
      - NEXT_PRIVATE_DIRECT_DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/documenso${1:+_$1}

    ## -"i Configuracoes MinIO
      - NEXT_PUBLIC_UPLOAD_TRANSPORT=s3
      - NEXT_PRIVATE_UPLOAD_ENDPOINT=https://$url_s3
      - NEXT_PRIVATE_UPLOAD_FORCE_PATH_STYLE=true
      - NEXT_PRIVATE_UPLOAD_REGION=eu-south
      - NEXT_PRIVATE_UPLOAD_BUCKET=documenso${1:+-$1}
      - NEXT_PRIVATE_UPLOAD_ACCESS_KEY_ID=$S3_ACCESS_KEY
      - NEXT_PRIVATE_UPLOAD_SECRET_ACCESS_KEY=$S3_SECRET_KEY

    ## Dados de SMTP
      - NEXT_PRIVATE_SMTP_TRANSPORT=smtp-auth
      - NEXT_PRIVATE_SMTP_FROM_ADDRESS=$email_documenso
      - NEXT_PRIVATE_SMTP_USERNAME=$usuario_email_documenso
      - NEXT_PRIVATE_SMTP_PASSWORD=$senha_email_documenso
      - NEXT_PRIVATE_SMTP_HOST=$smtp_email_documenso
      - NEXT_PRIVATE_SMTP_PORT=$porta_smtp_documenso
      - NEXT_PRIVATE_SMTP_SECURE=$smtp_secure_documenso
      - NEXT_PRIVATE_SMTP_FROM_NAME=Suporte

    ## Configuracoes
      - NEXT_PUBLIC_DOCUMENT_SIZE_UPLOAD_LIMIT=10
      - NEXT_PUBLIC_DISABLE_SIGNUP=false
      - NEXT_PRIVATE_SIGNING_LOCAL_FILE_PATH=/opt/documenso/cert.p12

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
        - traefik.http.routers.documenso${1:+_$1}.rule=Host(\`$url_documenso\`)
        - traefik.http.services.documenso${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.documenso${1:+_$1}.service=documenso${1:+_$1}
        - traefik.http.routers.documenso${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.documenso${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.documenso${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  documenso${1:+_$1}_cert:
    external: true
    name: documenso${1:+_$1}_cert

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do documenso"
fi
STACK_NAME="documenso${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c documenso.yaml documenso > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do documenso"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull documenso/documenso:latest

## Usa o servico wait_stack "documenso" para verificar se o servico esta online
wait_stack documenso${1:+_$1}_documenso${1:+_$1}


cd dados_vps

cat > dados_documenso${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ DOCUMENSO ]

Dominio do Documenso: https://$url_documenso

Email: Precisa criar no primeiro acesso do Documenso

Senha: Precisa criar no primeiro acesso do Documenso
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
echo -e "\e[32m[ DOCUMENSO ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_documenso\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Precisa criar no primeiro acesso do Documenso\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Documenso\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ####   #### #######  ####### ####### ###     ########
## a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-a-a-
## ##########|##|   ##|##|   ##|##|  ##|##|     ######  
## a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-'     a-a-a-"a-a-a-  
## a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--
## a-a-a-     a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-
#
#ferramenta_moodle() {
#
### Verifica os recursos
#recursos 1 1 || return
#
### Limpa o terminal
#clear
#
### Ativa a funcao dados para pegar os dados da vps
#dados
#
### Mostra o nome da aplicacao
#nome_moodle
#
### Mostra mensagem para preencher informacoes
#preencha_as_info
#
### Inicia um Loop ate os dados estarem certos
#while true; do
#
#    ##Pergunta o Dominio para a ferramenta
#    echo -e "\e[97mPasso$amarelo 1/10\e[0m"
#    echo -en "\e[33mDigite o dominio para o Moodle (ex: moodle.example.com): \e[0m" && read -r url_moodle
#    echo ""
#
#    ##Pergunta o Dominio para a ferramenta
#    echo -e "\e[97mPasso$amarelo 2/10\e[0m"
#    echo -en "\e[33mDigite o nome para o projeto (ex: Felsen): \e[0m" && read -r project_name_moodle
#    echo ""
#
#    ##Pergunta o Dominio para a ferramenta
#    echo -e "\e[97mPasso$amarelo 3/10\e[0m"
#    echo -en "\e[33mDigite um Nome de Usuario (ex: Felsen): \e[0m" && read -r user_moodle
#    echo ""
#
#    ##Pergunta o Dominio para a ferramenta
#    echo -e "\e[97mPasso$amarelo 4/10\e[0m"
#    echo -e "$amarelo--> Sem caracteres especiais: \!#$"
#    echo -en "\e[33mDigite uma Senha para o Usuario (ex: @Senha123_): \e[0m" && read -r pass_moodle
#    echo ""
#
#    ##Pergunta o Dominio para a ferramenta
#    echo -e "\e[97mPasso$amarelo 5/10\e[0m"
#    echo -e "$amarelo--> Sem caracteres especiais: \!#$"
#    echo -en "\e[33mDigite um Email para o Usuario (ex: contato@example.com): \e[0m" && read -r mail_moodle
#    echo ""
#
#    ##Pergunta o Email SMTP
#    echo -e "\e[97mPasso$amarelo 6/10\e[0m"
#    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_moodle
#    echo ""
#
#    ##Pergunta o usuario do Email SMTP
#    echo -e "\e[97mPasso$amarelo 7/10\e[0m"
#    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
#    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_smtp_moodle
#    echo ""
#    
#    ## Pergunta a senha do SMTP
#    echo -e "\e[97mPasso$amarelo 8/10\e[0m"
#    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
#    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_smtp_moodle
#    echo ""
#
#    ## Pergunta o Host SMTP do email
#    echo -e "\e[97mPasso$amarelo 9/10\e[0m"
#    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_moodle
#    echo ""
#
#    ## Pergunta a porta SMTP do email
#    echo -e "\e[97mPasso$amarelo 10/10\e[0m"
#    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_moodle
#    echo ""
#
#    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
#    if [ "$porta_smtp_typebot" -eq 465 ]; then
#    smtp_secure_smtp_moodle=ssl
#    else
#    smtp_secure_smtp_moodle=tls
#    fi
#
#    
#    ## Limpa o terminal
#    clear
#    
#    ## Mostra o nome da aplicacao
#    nome_moodle
#    
#    ## Mostra mensagem para verificar as informacoes
#    conferindo_as_info
#    
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mDominio do Moodle:\e[97m $url_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mNome do Projeto:\e[97m $project_name_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mUsuario:\e[97m $user_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mSenha:\e[97m $pass_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mEmail:\e[97m $mail_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mEmail SMTP:\e[97m $email_smtp_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mUsuario SMTP:\e[97m $usuario_smtp_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mSenha SMTP:\e[97m $senha_smtp_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mHost SMTP\e[97m $host_smtp_moodle\e[0m"
#    echo ""
#
#    ## Informacao sobre URL do moodle
#    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_moodle\e[0m"
#    echo ""
#    
#    ## Pergunta se as respostas estao corretas
#    read -p "As respostas estao corretas? (Y/N): " confirmacao
#    if [ "$confirmacao" = "Y" ] || [ "$confirmacao" = "y" ]; then
#
#        ## Digitou Y para confirmar que as informacoes estao corretas
#
#        ## Limpar o terminal
#        clear
#
#        ## Mostrar mensagem de Instalando
#        instalando_msg
#
#        ## Sai do Loop
#        break
#    else
#
#        ## Digitou N para dizer que as informacoes nao estao corretas.
#
#        ## Limpar o terminal
#        clear
#
#        ## Mostra o nome da ferramenta
#        nome_moodle
#
#        ## Mostra mensagem para preencher informacoes
#        preencha_as_info
#
#    ## Volta para o inicio do loop com as perguntas
#    fi
#done
#
### Mensagem de Passo
#echo -e "\e[97m- INICIANDO A INSTALACAO DO MOODLE \e[33m[1/3]\e[0m"
#echo ""
#sleep 1
#
#
### Nadaaaaa
#
### Mensagem de Passo
#echo -e "\e[97m- INSTALANDO MOODLE \e[33m[2/3]\e[0m"
#echo ""
#sleep 1
#
#senha_marinadb=$(openssl rand -hex 16)
### Criando a stack moodle.yaml
#cat > moodle${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
#version: "3.7"
#services:
#
### --------------------------- FELSEN --------------------------- ##
#
#  moodle${1:+_$1}_app:
#    image: moodlehq/moodleapp:latest
#
#    volumes:
#      - moodle${1:+_$1}_data:/bitnami/moodle
#      - moodle${1:+_$1}data_data:/bitnami/moodledata
#
#    networks:
#       - $nome_rede_interna ## Nome da rede interna
#
#    environment:
#    ## Dados do projeto
#      - MOODLE_SITE_NAME=$project_name_moodle
#
#    ## Dados de acesso
#      - MOODLE_HOST=$url_moodle
#      - MOODLE_USERNAME=$user_moodle
#      - MOODLE_PASSWORD=$pass_moodle
#      - MOODLE_EMAIL=$mail_moodle
#
#    ## Dados SMTP
#      - MOODLE_SMTP_USER=$usuario_smtp_moodle
#      - MOODLE_SMTP_PASSWORD=$senha_smtp_moodle
#      - MOODLE_SMTP_HOST=$host_smtp_moodle
#      - MOODLE_SMTP_PORT_NUMBER=$porta_smtp_moodle
#      - MOODLE_SMTP_PROTOCOL=$smtp_secure_smtp_moodle ## 587 = tls ou plain | 465 = ssl 
#
#    ## Idioma
#      - MOODLE_LANG=pt
#      
#    ## Dados MarinaDB
#      - MOODLE_DATABASE_HOST=moodle${1:+_$1}_mariadb
#      - MOODLE_DATABASE_PORT_NUMBER=3306
#      - MOODLE_DATABASE_USER=FELSEN_moodle
#      - MOODLE_DATABASE_PASSWORD=$senha_marinadb
#      - MOODLE_DATABASE_NAME=FELSENbase_moodle
#      - ALLOW_EMPTY_PASSWORD=no
#
#    deploy:
#      mode: replicated
#      replicas: 1
#      placement:
#        constraints:
#          - node.role == manager
#      resources:
#        limits:
#          cpus: "1"
#          memory: 1024M
#      labels:
#        - traefik.enable=true
#        - traefik.http.routers.moodle${1:+_$1}.rule=Host(\`$url_moodle\`)
#        - traefik.http.services.moodle${1:+_$1}.loadbalancer.server.port=8080
#        - traefik.http.routers.moodle${1:+_$1}.service=moodle${1:+_$1}
#        - traefik.http.routers.moodle${1:+_$1}.tls.certresolver=letsencryptresolver
#        - traefik.http.routers.moodle${1:+_$1}.entrypoints=websecure
#        - traefik.http.routers.moodle${1:+_$1}.tls=true
#
### --------------------------- FELSEN --------------------------- ##
#
#  moodle${1:+_$1}_mariadb:
#    image: mariadb:latest
#
#    volumes:
#      - moodle${1:+_$1}_mariadb_data:/bitnami/mariadb
#
#    networks:
#       - $nome_rede_interna ## Nome da rede interna
#
#    environment:  
#    ## Dados MarinaDB
#      - MARIADB_USER=FELSEN_moodle
#      - MARIADB_ROOT_PASSWORD=$senha_marinadb
#      - MARIADB_DATABASE=FELSENbase_moodle
#      - MARIADB_PASSWORD=$senha_marinadb
#      - MARIADB_CHARACTER_SET=utf8mb4
#      - MARIADB_COLLATE=utf8mb4_unicode_ci
#      - ALLOW_EMPTY_PASSWORD=no
#
#    deploy:
#      mode: replicated
#      replicas: 1
#      placement:
#        constraints:
#          - node.role == manager
#      resources:
#        limits:
#          cpus: "1"
#          memory: 1024M
#
### --------------------------- FELSEN --------------------------- ##
#
#volumes:
#  moodle${1:+_$1}_data:
#    external: true
#    name: moodle${1:+_$1}_data
#  moodle${1:+_$1}data_data:
#    external: true
#    name: moodle${1:+_$1}data_data
#  moodle${1:+_$1}_mariadb_data:
#    external: true
#    name: moodle${1:+_$1}_mariadb_data
#
#networks:
#  $nome_rede_interna: ## Nome da rede interna
#    name: $nome_rede_interna ## Nome da rede interna
#    external: true
#__FELSEN_MANAGED_FILE__
#if [ $? -eq 0 ]; then
#    echo "1/10 - [ OK ] - Criando Stack"
#else
#    echo "1/10 - [ OFF ] - Criando Stack"
#    echo "Nao foi possivel criar a stack do Moodle"
#fi
#STACK_NAME="moodle${1:+_$1}"
#stack_editavel # > /dev/null 2>&1
##docker stack deploy --prune --resolve-image always -c moodle.yaml moodle > /dev/null 2>&1
##if [ $? -eq 0 ]; then
##    echo "2/2 - [ OK ] - Deploy Stack"
##else
##    echo "2/2 - [ OFF ] - Deploy Stack"
##    echo "Nao foi possivel Subir a stack do moodle"
##fi
#
### Mensagem de Passo
#echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
#echo ""
#sleep 1
#
### Baixando imagens:
#pull moodlehq/moodleapp:latest mariadb:latest
#
### Usa o servico wait_stack "moodle" para verificar se o servico esta online
#wait_stack moodle${1:+_$1}_moodle${1:+_$1}_app moodle${1:+_$1}_moodle${1:+_$1}_mariadb
#sleep 120
#
#
#cd dados_vps
#
#cat > dados_moodle${1:+_$1} <<__FELSEN_MANAGED_FILE__
#[ MOODLE ]
#
#Dominio do moodle: https://$url_moodle
#
#Usuario: $user_moodle
#
#Senha: $pass_moodle
#
#__FELSEN_MANAGED_FILE__
#
#cd
#cd
#
### Espera 30 segundos
#wait_30_sec
#
### Mensagem de finalizado
#instalado_msg
#
### Mensagem de Guarde os Dados
#guarde_os_dados_msg
#
### Dados da Aplicacao:
#echo -e "\e[32m[ MOODLE ]\e[0m"
#echo ""
#
#echo -e "\e[33mDominio:\e[97m https://$url_moodle\e[0m"
#echo ""
#
#echo -e "\e[33mUsuario:\e[97m $user_moodle\e[0m"
#echo ""
#
#echo -e "\e[33mSenha:\e[97m $pass_moodle\e[0m"
#echo ""
#
#echo -e "\e[97mObservacao:\e[33m Esta e uma ferramenta que pode demorar para iniciar na primeira vez\e[0m"
#echo -e "\e[33mrecomendo aguardar alguns instantes antes de tentar abrir para nao prejudicar\e[0m"
#echo -e "\e[33ma sua instalacao que ja foi realizado.\e[0m"
#
### Creditos do instalador
#creditos_msg
#
### Pergunta se deseja instalar outra aplicacao
#requisitar_outra_instalacao
#
#}

## ######### #######  ####### ###          ####################
## a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-'          a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-
##    ##|   ##|   ##|##|   ##|##|          ##|######     ##|   
##    a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-   a-a-a-'a-a-a-"a-a-a-     a-a-a-'   
##    a-a-a-'   a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--   a-a-a-'   
##    a-a-a-    a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a- a-a-a-a-a-a- a-a-a-a-a-a-a-a-   a-a-a-   

