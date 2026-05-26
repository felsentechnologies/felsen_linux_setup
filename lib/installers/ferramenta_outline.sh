#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_outline() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_outline

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/8\e[0m"
    echo -en "\e[33mDigite o dominio para o Outline (ex: outline.example.com): \e[0m" && read -r url_outline
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/8\e[0m"
    echo -e "$amarelo--> Caso nao tiver crie em: https://console.cloud.google.com/welcome"
    echo -en "\e[33mDigite o seu ID do Cliente Google (ex: XXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.apps.googleusercontent.com): \e[0m" && read -r id_google_outline
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/8\e[0m"
    echo -e "$amarelo--> Caso nao tiver crie em: https://console.cloud.google.com/apis/credentials"
    echo -en "\e[33mDigite a sua Chave Secreta do Cliente Google (ex: XXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX-XXX): \e[0m" && read -r key_google_outline
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 4/8\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_outline
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 5/8\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_email_outline
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 6/8\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_outline
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 7/8\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_outline
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 8/8\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_outline
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_outline" -eq 465 ]; then
    smtp_secure_outline=true
    else
    smtp_secure_outline=false
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_outline
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do outline
    echo -e "\e[33mDominio do Outline:\e[97m $url_outline\e[0m"
    echo ""

    ## Informacao sobre URL do outline
    echo -e "\e[33mID do Cliente Google:\e[97m $id_google_outline\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mEmail do SMTP:\e[97m $email_outline\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mUsuario do SMTP:\e[97m $usuario_email_outline\e[0m"
    echo ""

    ## Informacao sobre Senha do Email
    echo -e "\e[33mSenha do Email:\e[97m $senha_email_outline\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP do Email:\e[97m $smtp_email_outline\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP do Email:\e[97m $porta_smtp_outline\e[0m"
    echo ""

    ## Informacao sobre Secure SMTP
    echo -e "\e[33mSecure SMTP do Email:\e[97m $smtp_secure_outline\e[0m"
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
        nome_outline

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO OUTLINE \e[33m[1/4]\e[0m"
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
    criar_banco_postgres_da_stack "outline${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "outline${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO OUTLINE \e[33m[3/4]\e[0m"
echo ""
sleep 1

Key_aleatoria_outline_1=$(openssl rand -hex 32)
Key_aleatoria_outline_2=$(openssl rand -hex 32)

## Criando a stack outline.yaml
cat > outline${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  outline${1:+_$1}_app:
    image: outlinewiki/outline:latest

    volumes:
      - outline${1:+_$1}_uploads:/var/lib/outline/uploads

    networks:
      - $nome_rede_interna

    environment:
    ## " Dados de acesso
      - URL=https://$url_outline
      - PORT=3000
      - ENABLE_EMAIL_SIGNIN=true
      - FORCE_HTTPS=true

    ##  Secret Keys
      - SECRET_KEY=$Key_aleatoria_outline_1
      - UTILS_SECRET=$Key_aleatoria_outline_2

    ##  Dados do Postgres
      - DATABASE_URL=postgres://postgres:$senha_postgres@postgres:5432/outline${1:+_$1}?sslmode=disable

    ##  Dados do Redis
      - REDIS_URL=redis://outline${1:+_$1}_redis:6379

    ## -'i Dados de armazenamento
      - FILE_STORAGE_UPLOAD_LOCAL=true
      #- AWS_S3_UPLOAD_BUCKET_URL=https://
      #- AWS_S3_UPLOAD_BUCKET_NAME=outline
      #- AWS_ACCESS_KEY_ID=
      #- AWS_SECRET_ACCESS_KEY=
      #- AWS_REGION=eu-south

    ## Dados SMTP
      - SMTP_FROM_EMAIL=Outline <$email_outline>
      - SMTP_USERNAME=$usuario_email_outline
      - SMTP_PASSWORD=$senha_email_outline
      - SMTP_HOST=$smtp_email_outline
      - SMTP_PORT=$porta_smtp_outline
      - MAIL_SSL_ENABLE=$smtp_secure_outline

    ##  ConfoiguraAAes Globais
      - DEFAULT_LANGUAGE=pt_BR
      - WEB_CONCURRENCY=2

    ##  Dados Google
      - OIDC_CLIENT_ID=$id_google_outline
      - OIDC_CLIENT_SECRET=$key_google_outline
      - OIDC_AUTH_URI=https://accounts.google.com/o/oauth2/auth
      - OIDC_TOKEN_URI=https://accounts.google.com/o/oauth2/token
      - OIDC_USERINFO_URI=https://www.googleapis.com/oauth2/v3/userinfo
      - OIDC_USERNAME_CLAIM=preferred_username
      - OIDC_DISPLAY_NAME=Google
      - OIDC_SCOPES=email profile openid
      - OIDC_LOGOUT_URI=https://$url_outline

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
        - traefik.http.routers.outline${1:+_$1}_app.rule=Host(\`$url_outline\`)
        - traefik.http.routers.outline${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.outline${1:+_$1}_app.tls=true
        - traefik.http.routers.outline${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.outline${1:+_$1}_app.service=outline${1:+_$1}_app
        - traefik.http.services.outline${1:+_$1}_app.loadbalancer.server.port=3000

## --------------------------- FELSEN --------------------------- ##

  outline${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - outline${1:+_$1}_redis:/data

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
  outline${1:+_$1}_uploads:
    external: true
    name: outline${1:+_$1}_uploads
  outline${1:+_$1}_redis:
    external: true
    name: outline${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Outline"
fi
STACK_NAME="outline${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c outline.yaml outline > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do outline"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest outlinewiki/outline:latest

## Usa o servico wait_stack "outline" para verificar se o servico esta online
wait_stack outline${1:+_$1}_outline${1:+_$1}_redis outline${1:+_$1}_outline${1:+_$1}_app


cd dados_vps

cat > dados_outline${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ OUTLINE ]

Dominio do Outline: https://$url_outline

Usuario: Login e feito com o Google

Senha: Login e feito com o Google
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
echo -e "\e[32m[ OUTLINE ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_outline\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Login e feito com o Google\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Login e feito com o Google\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ######## #######  ####### ###### ###     #######  #######  ###### ####### ####### 
## a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a--  a-a-a-'   a-a-a-'a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'
## a-a-a-"a-a-a-  a-a-a-'   a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'  a-a-a-'
## a-a-a-'     a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-
## a-a-a-      a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a- 

