#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_formbricks() {

## Verifica os recursos
recursos 1 1 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_formbricks

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para o Formbricks (ex: formbricks.example.com): \e[0m" && read -r url_formbricks
    echo ""
    
    ## Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite um Email para o SMTP (ex: contato@example.com): \e[0m" && read -r email_formbricks
    echo ""

    ## Pergunta o User SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario do SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_smtp_formbricks
    echo ""
    
    ## Pergunta a Senha SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do email (ex: @Senha123_): \e[0m" && read -r senha_formbricks
    echo ""
    
    ## Pergunta o Host SMTP
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do email (ex: smtp.hostinger.com): \e[0m" && read -r host_formbricks
    echo ""
    
    ## Pergunta a Porta SMTP 
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a Porta SMTP do email (ex: 465): \e[0m" && read -r porta_formbricks
    echo ""
    
    if [ "$porta_formbricks" -eq 465 ] || [ "$porta_formbricks" -eq 25 ]; then
        ssl_formbricks=1
    else
        ssl_formbricks=0
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_formbricks
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio:\e[97m $url_formbricks\e[0m"
    echo ""
    
    ## Informacao sobre Email
    echo -e "\e[33mEmail SMTP:\e[97m $email_formbricks\e[0m"
    echo ""

    ## Informacao sobre UserSMTP
    echo -e "\e[33mUser SMTP:\e[97m $user_smtp_formbricks\e[0m"
    echo ""
    
    ## Informacao sobre Senha
    echo -e "\e[33mSenha SMTP:\e[97m $senha_formbricks\e[0m"
    echo ""
    
    ## Informacao sobre Host
    echo -e "\e[33mHost SMTP:\e[97m $host_formbricks\e[0m"
    echo ""
    
    ## Informacao sobre Porta
    echo -e "\e[33mPorta SMTP:\e[97m $porta_formbricks\e[0m"
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
        nome_formbricks

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO FORMBRICKS \e[33m[1/5]\e[0m"
echo ""
sleep 1


## Nada nada nada.. so para aparecer a mensagem de passo..

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO PGVECTOR \e[33m[2/5]\e[0m"
echo ""
sleep 1

verificar_container_pgvector
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - PgVector ja instalado"
    pegar_senha_pgvector > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do PgVector"
    criar_banco_pgvector_da_stack "formbricks${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_pgvector
    pegar_senha_pgvector > /dev/null 2>&1
    criar_banco_pgvector_da_stack "formbricks${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[3/5]\e[0m"
echo ""
sleep 1

pegar_senha_minio
minio.bucket formbricks${1:+-$1} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
    echo ""
else
    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
    echo ""
fi

echo ""
## Mensagem de Passo
echo -e "\e[97m- INSTALANDO FORMBRICKS \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Gera keys aleatorias
encryption_key_form=$(openssl rand -hex 32)
next_key_form=$(openssl rand -hex 32)
cron_key_form=$(openssl rand -hex 32)

## Criando a stack formbricks.yaml
cat > formbricks${1:+_$1}.yaml <<-__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  formbricks${1:+_$1}_app:
    image: ghcr.io/formbricks/formbricks:latest

    volumes:
      - formbricks${1:+_$1}_data:/home/nextjs/apps/web/uploads/

    networks:
      - $nome_rede_interna

    environment:
      ## Url da aplicacao
      - WEBAPP_URL=https://$url_formbricks
      - NEXTAUTH_URL=https://$url_formbricks

      ## Banco de dados Postgres
      - DATABASE_URL=postgresql://postgres:$senha_pgvector@pgvector:5432/formbricks${1:+_$1}?schema=public

      ## Licenca Enterprise ou Self-hosting
      ## Solicitar licenta Self-hosting -->  <-- ##
      - ENTERPRISE_LICENSE_KEY=

      ## Keys aleatorias 32 caracteres
      - ENCRYPTION_KEY=$encryption_key_form
      - NEXTAUTH_SECRET=$next_key_form
      - CRON_SECRET=$cron_key_form

      ## Dados do SMTP
      - MAIL_FROM=$email_formbricks
      - SMTP_HOST=$host_formbricks
      - SMTP_PORT=$porta_formbricks
      - SMTP_SECURE_ENABLED=$ssl_formbricks #(0= false | 1= true)
      - SMTP_USER=$user_smtp_formbricks
      - SMTP_PASSWORD=$senha_formbricks

      ## Ativar/Desativar registros e convites (0= false | 1= true)
      - SIGNUP_DISABLED=0
      - INVITE_DISABLED=0
      - EMAIL_VERIFICATION_DISABLED=0
      - PASSWORD_RESET_DISABLED=0

    ## Dados do S3
      - S3_ACCESS_KEY=$S3_ACCESS_KEY
      - S3_SECRET_KEY=$S3_SECRET_KEY
      - S3_REGION=eu-south
      - S3_BUCKET_NAME=formbricks${1:+-$1}
      - S3_ENDPOINT_URL=https://$url_s3
      - S3_FORCE_PATH_STYLE=1
    
    ## Dados do Redis
      - REDIS_URL=redis://formbricks${1:+_$1}_redis:6379

      ## Dados do Formbricks (para pesquisa)
      - NEXT_PUBLIC_FORMBRICKS_API_HOST=
      - NEXT_PUBLIC_FORMBRICKS_ENVIRONMENT_ID=
      - NEXT_PUBLIC_FORMBRICKS_ONBOARDING_SURVEY_ID=

      ## Login Google Cloud
      - GOOGLE_AUTH_ENABLED=0
      - GOOGLE_CLIENT_ID=
      - GOOGLE_CLIENT_SECRET=

      ## Google Sheets
      - GOOGLE_SHEETS_CLIENT_ID=
      - GOOGLE_SHEETS_CLIENT_SECRET=
      - GOOGLE_SHEETS_REDIRECT_URL=

      ## Login Github
      - GITHUB_AUTH_ENABLED=0
      - GITHUB_ID=
      - GITHUB_SECRET=

      ## Login Github
      - NOTION_OAUTH_CLIENT_ID=
      - NOTION_OAUTH_CLIENT_SECRET=   
      
      ## Login Airtable
      - AIRTABLE_CLIENT_ID=

      ## Termos e politica de privacidade
      #- PRIVACY_URL=
      #- TERMS_URL=
      #- IMPRINT_URL=

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
        - traefik.http.routers.formbricks${1:+_$1}_app.rule=Host(\`$url_formbricks\`)
        - traefik.http.services.formbricks${1:+_$1}_app.loadbalancer.server.port=3000
        - traefik.http.routers.formbricks${1:+_$1}_app.service=formbricks${1:+_$1}_app
        - traefik.http.routers.formbricks${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.formbricks${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.formbricks${1:+_$1}_app.tls=true

## --------------------------- FELSEN --------------------------- ##

  formbricks${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - formbricks${1:+_$1}_redis:/data

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
  formbricks${1:+_$1}_data:
    external: true
    name: formbricks${1:+_$1}_data
  formbricks${1:+_$1}_redis:
    external: true
    name: formbricks${1:+_$1}_redis

networks:
  $nome_rede_interna:
    name: $nome_rede_interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Formbricks"
fi
STACK_NAME="formbricks${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c formbricks.yaml formbricks > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Formbricks"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest ghcr.io/formbricks/formbricks:latest

## Usa o servico wait_stack "formbricks" para verificar se o servico esta online
wait_stack formbricks${1:+_$1}_formbricks${1:+_$1}_redis formbricks${1:+_$1}_formbricks${1:+_$1}_app
wait_30_sec

cd dados_vps

cat > dados_formbricks${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ FORMBRICKS ]

Dominio do Formbricks: https://$url_formbricks

Email: Precisa de criar dentro do Formbricks

Senha: Precisa de criar dentro do Formbricks
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
echo -e "\e[32m[ FORMBRICKS ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_formbricks\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Precisa de criar dentro do Formbricks\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar dentro do Formbricks\e[0m"
echo ""
echo "> Aguarde aproximadamente 5 minutos antes de acessar devido a migracao em andamento."

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   ### #######  ####### ####### ####### ####### 
## a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--
## a-a-a-"a-a-a-- a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-
## a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- 

