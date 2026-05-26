#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_typebot() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_typebot

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do Builder
    echo -e "\e[97mPasso$amarelo 1/7\e[0m"
    echo -en "\e[33mDigite o Dominio para o Builder do Typebot (ex: typebot.example.com): \e[0m" && read -r url_typebot
    echo ""

    ##Pergunta o Dominio do Viewer
    echo -e "\e[97mPasso$amarelo 2/7\e[0m"
    echo -en "\e[33mDigite o Dominio para o Viewer do Typebot (ex: viewer.example.com): \e[0m" && read -r url_viewer
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 3/7\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_typebot
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 4/7\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_email_typebot
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 5/7\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_typebot
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 6/7\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_typebot
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 7/7\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_typebot
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_typebot" -eq 465 ]; then
    smtp_secure_typebot=true
    else
    smtp_secure_typebot=false
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_typebot
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Builder
    echo -e "\e[33mDominio do Typebot Builder:\e[97m $url_typebot\e[0m"
    echo ""

    ## Informacao sobre URL do Viewer
    echo -e "\e[33mDominio do Typebot Viewer:\e[97m $url_viewer\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mEmail do SMTP:\e[97m $email_typebot\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mUsuario do SMTP:\e[97m $usuario_email_typebot\e[0m"
    echo ""

    ## Informacao sobre Senha do Email
    echo -e "\e[33mSenha do Email:\e[97m $senha_email_typebot\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP do Email:\e[97m $smtp_email_typebot\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP do Email:\e[97m $porta_smtp_typebot\e[0m"
    echo ""

    ## Informacao sobre Secure SMTP
    echo -e "\e[33mSecure SMTP do Email:\e[97m $smtp_secure_typebot\e[0m"
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
        nome_typebot

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done


## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO TYPEBOT \e[33m[1/5]\e[0m"
echo ""
sleep 1


## Nada nada nada.. so para aparecer a mensagem de passo..

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/5]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "typebot${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "typebot${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[3/5]\e[0m"
echo ""
sleep 1

pegar_senha_minio
minio.bucket typebot${1:+-$1} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
    echo ""
else
    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
    echo ""
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO TYPEBOT \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
key_typebot=$(openssl rand -hex 16)

## Criando a stack typebot.yaml
cat > typebot${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  typebot${1:+_$1}_builder:
    image: baptistearno/typebot-builder:latest ## Versao do Builder do Typebot

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Dados do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/typebot${1:+_$1}

    ## " Encryption key
      - ENCRYPTION_SECRET=$key_typebot
      - AUTH_TRUST_HOST=https://$url_typebot

    ##  Plano Padrao (das novas contas)
      - DEFAULT_WORKSPACE_PLAN=UNLIMITED ## FREE, STARTER, PRO, LIFETIME ou UNLIMITED

    ##  Urls do typebot
      - NEXTAUTH_URL=https://$url_typebot ## URL Builder
      - NEXT_PUBLIC_VIEWER_URL=https://$url_viewer ## URL Viewer
      - NEXTAUTH_URL_INTERNAL=http://localhost:3000

    ##  Desativar/ativar novos cadastros
      - DISABLE_SIGNUP=false

    ##  Dados do SMTP
      - ADMIN_EMAIL=$email_typebot ## Email SMTP
      - NEXT_PUBLIC_SMTP_FROM='Suporte' <$email_typebot>
      - SMTP_AUTH_DISABLED=false
      - SMTP_USERNAME=$usuario_email_typebot
      - SMTP_PASSWORD=$senha_email_typebot
      - SMTP_HOST=$smtp_email_typebot
      - SMTP_PORT=$porta_smtp_typebot
      - SMTP_SECURE=$smtp_secure_typebot

    ## Dados Google Cloud
      #- GOOGLE_AUTH_CLIENT_ID=
      #- GOOGLE_SHEETS_CLIENT_ID=
      #- GOOGLE_AUTH_CLIENT_SECRET=
      #- GOOGLE_SHEETS_CLIENT_SECRET=
      #- NEXT_PUBLIC_GOOGLE_SHEETS_API_KEY=

    ## -i Dados do Minio/S3
      - S3_ACCESS_KEY=$S3_ACCESS_KEY
      - S3_SECRET_KEY=$S3_SECRET_KEY
      - S3_BUCKET=typebot${1:+-$1}
      - S3_ENDPOINT=$url_s3
      - S3_REGION=eu-south
      - NEXT_PUBLIC_BOT_FILE_UPLOAD_MAX_SIZE=250

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
        - io.portainer.accesscontrol.users=admin
        - traefik.enable=true
        - traefik.http.routers.typebot${1:+_$1}_builder.rule=Host(\`$url_typebot\`) ## Url do Builder do Typebot
        - traefik.http.routers.typebot${1:+_$1}_builder.entrypoints=websecure
        - traefik.http.routers.typebot${1:+_$1}_builder.tls.certresolver=letsencryptresolver
        - traefik.http.services.typebot${1:+_$1}_builder.loadbalancer.server.port=3000
        - traefik.http.services.typebot${1:+_$1}_builder.loadbalancer.passHostHeader=true
        - traefik.http.routers.typebot${1:+_$1}_builder.service=typebot${1:+_$1}_builder

## --------------------------- FELSEN --------------------------- ##

  typebot${1:+_$1}_viewer:
    image: baptistearno/typebot-viewer:latest ## Versao do Viewer do Typebot

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Dados do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/typebot${1:+_$1}

    ## " Encryption key
      - ENCRYPTION_SECRET=$key_typebot
      - AUTH_TRUST_HOST=https://$url_typebot

    ##  Plano Padrao (das novas contas)
      - DEFAULT_WORKSPACE_PLAN=UNLIMITED ## FREE, STARTER, PRO, LIFETIME ou UNLIMITED

    ##  Urls do typebot
      - NEXTAUTH_URL=https://$url_typebot ## URL Builder
      - NEXT_PUBLIC_VIEWER_URL=https://$url_viewer ## URL Viewer
      - NEXTAUTH_URL_INTERNAL=http://localhost:3000

    ##  Desativar/ativar novos cadastros
      - DISABLE_SIGNUP=false

    ##  Dados do SMTP
      - ADMIN_EMAIL=$email_typebot ## Email SMTP
      - NEXT_PUBLIC_SMTP_FROM='Suporte' <$email_typebot>
      - SMTP_AUTH_DISABLED=false
      - SMTP_USERNAME=$usuario_email_typebot
      - SMTP_PASSWORD=$senha_email_typebot
      - SMTP_HOST=$smtp_email_typebot
      - SMTP_PORT=$porta_smtp_typebot
      - SMTP_SECURE=$smtp_secure_typebot

    ## Dados Google Cloud
      #- GOOGLE_AUTH_CLIENT_ID=
      #- GOOGLE_SHEETS_CLIENT_ID=
      #- GOOGLE_AUTH_CLIENT_SECRET=
      #- GOOGLE_SHEETS_CLIENT_SECRET=
      #- NEXT_PUBLIC_GOOGLE_SHEETS_API_KEY=

    ## -i Dados do Minio/S3
      - S3_ACCESS_KEY=$S3_ACCESS_KEY
      - S3_SECRET_KEY=$S3_SECRET_KEY
      - S3_BUCKET=typebot${1:+-$1}
      - S3_ENDPOINT=$url_s3
      - S3_REGION=eu-south
      - NEXT_PUBLIC_BOT_FILE_UPLOAD_MAX_SIZE=250

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
        - io.portainer.accesscontrol.users=admin
        - traefik.enable=true
        - traefik.http.routers.typebot${1:+_$1}_viewer.rule=Host(\`$url_viewer\`) ## Url do Viewer do Typebot
        - traefik.http.routers.typebot${1:+_$1}_viewer.entrypoints=websecure
        - traefik.http.routers.typebot${1:+_$1}_viewer.tls.certresolver=letsencryptresolver
        - traefik.http.services.typebot${1:+_$1}_viewer.loadbalancer.server.port=3000
        - traefik.http.services.typebot${1:+_$1}_viewer.loadbalancer.passHostHeader=true
        - traefik.http.routers.typebot${1:+_$1}_viewer.service=typebot${1:+_$1}_viewer

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
    echo "Nao foi possivel criar a stack do Typebot"
fi
STACK_NAME="typebot${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c typebot.yaml typebot > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Typebot"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull baptistearno/typebot-builder:latest baptistearno/typebot-viewer:latest

## Usa o servico wait_typebot para verificar se o servico esta online
wait_stack typebot${1:+_$1}_typebot${1:+_$1}_builder typebot${1:+_$1}_typebot${1:+_$1}_viewer


cd dados_vps

cat > dados_typebot${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ TYPEBOT ]

Dominio do Typebot: https://$url_typebot

Email: Qualquer um (cada email e um workspace)

Senha: Nao tem senha, chega no seu email o link magico de acesso
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
echo -e "\e[32m[ TYPEBOT ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_typebot\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Qualquer um (nao precisa ser o mesmo que usou na instalacao)\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Nao tem senha, chega no seu email um link magico de acesso.\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   ### ###### ####   ###
## a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'
## a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-- a-a-a-'
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'
## a-a-a-  a-a-a-a-a- a-a-a-a-a-a- a-a-a-  a-a-a-a-a-

