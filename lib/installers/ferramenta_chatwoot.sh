#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_chatwoot() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_chatwoot

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para o Chatwoot (ex: chatwoot.example.com): \e[0m" && read -r url_chatwoot
    echo ""
    
    ## Pega o nome do dominio para ser o nome da empresa
    nome_empresa_chatwoot="$nome_servidor"
    
    ## Pergunta o email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_admin_chatwoot
    echo ""

    ## Define o dominio SMTP com o dominio do email
    dominio_smtp_chatwoot=$(echo "$email_admin_chatwoot" | cut -d "@" -f 2)

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_smtp_chatwoot
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_chatwoot
    echo ""
    
    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_chatwoot
    echo ""
    
    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_chatwoot
    
    
    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_chatwoot" -eq 465 ]; then
     sobre_ssl=true
    else
     sobre_ssl=false
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_chatwoot
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Chatwoot:\e[97m $url_chatwoot\e[0m"
    echo ""

    ## Informacao sobre Nome da Empresa
    echo -e "\e[33mNome da Empresa:\e[97m $nome_empresa_chatwoot\e[0m"
    echo ""

    ## Informacao sobre Email de SMTP
    echo -e "\e[33mEmail do SMTP:\e[97m $email_admin_chatwoot\e[0m"
    echo ""

    ## Informacao sobre Usuario do SMTP
    echo -e "\e[33mUser do SMTP:\e[97m $user_smtp_chatwoot\e[0m"
    echo ""

    ## Informacao sobre Senha de SMTP
    echo -e "\e[33mSenha do SMTP:\e[97m $senha_email_chatwoot\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP:\e[97m $smtp_email_chatwoot\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_chatwoot\e[0m"
    echo ""
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
        nome_chatwoot

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done


## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO CHATWOOT \e[33m[1/6]\e[0m"
echo ""
sleep 1


## Ativa a funcao dados para pegar os dados da vps
dados

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO PGVECTOR \e[33m[2/6]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres
verificar_container_pgvector
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - PgVector ja instalado"
    pegar_senha_pgvector > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do PgVector"
    criar_banco_pgvector_da_stack "chatwoot${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_pgvector
    pegar_senha_pgvector > /dev/null 2>&1
    criar_banco_pgvector_da_stack "chatwoot${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO CHATWOOT \e[33m[3/6]\e[0m"
echo ""
sleep 1

## Neste passo vamos estar criando a Stack yaml do Chatwoot na pasta /root/
## Isso possibilitara que o usuario consiga edita-lo posteriormente

## Depois vamos instalar o Chatwoot e verificar se esta tudo certo.

## Criando key aleatoria
encryption_key=$(openssl rand -hex 16)

## Criando a stack chatwoot.yaml
cat > chatwoot${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  chatwoot${1:+_$1}_app:
    image: chatwoot/chatwoot:latest ## Versao do Chatwoot
    command: >
     sh -c "echo 'Rails.application.config.active_storage.variant_processor = :mini_magick' > /app/config/initializers/active_storage.rb && bundle exec rails db:chatwoot_prepare && bundle exec rails s -p 3000 -b 0.0.0.0"
    entrypoint: docker/entrypoints/rails.sh    

    volumes:
      - chatwoot${1:+_$1}_storage:/app/storage ## Arquivos de conversa
      - chatwoot${1:+_$1}_public:/app/public ## Arquivos de logos
      - chatwoot${1:+_$1}_mailer:/app/app/views/devise/mailer ## Arquivos de email
      - chatwoot${1:+_$1}_mailers:/app/app/views/mailers ## Arquivos de emails

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  Nome da Empresa
      - INSTALLATION_NAME=$nome_empresa_chatwoot

    ## " Secret key
      - SECRET_KEY_BASE=$encryption_key

    ##  Url Chatwoot
      - FRONTEND_URL=https://$url_chatwoot
      - FORCE_SSL=true

    ##  Idioma/LocalizaAAo padrao
      - DEFAULT_LOCALE=pt_BR
      - TZ=America/Sao_Paulo

    ## Google Cloud - Modifique de acordo com os seus dados
      #- GOOGLE_OAUTH_CLIENT_ID=369777777777-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
      #- GOOGLE_OAUTH_CLIENT_SECRET=ABCDEF-GHijklmnoPqrstuvwX-yz1234567
      #- GOOGLE_OAUTH_CALLBACK_URL=https://<your-server-domain>/omniauth/google_oauth2/callback

    ## " Facebook e Instagram
      #- IG_VERIFY_TOKEN=
      #- FB_VERIFY_TOKEN=
      #- FB_APP_SECRET=
      #- FB_APP_ID=

    ## 'aEUR' Dados do Redis
      - REDIS_URL=redis://chatwoot${1:+_$1}_redis:6379

    ## -"i Dados do Postgres
      - POSTGRES_HOST=pgvector
      - POSTGRES_USERNAME=postgres
      - POSTGRES_PASSWORD=$senha_pgvector ## Senha do postgres
      - POSTGRES_DATABASE=chatwoot${1:+_$1}

    ##  Armazenamento
      - ACTIVE_STORAGE_SERVICE=local ## use s3_compatible para MinIO
      #- STORAGE_BUCKET_NAME=chatwoot${1:+_$1}
      #- STORAGE_ACCESS_KEY_ID=ACCESS_KEY_MINIO
      #- STORAGE_SECRET_ACCESS_KEY=SECRET_KEY_MINIO
      #- STORAGE_REGION=eu-south
      #- STORAGE_ENDPOINT=https://s3.DOMINIO.COM
      #- STORAGE_FORCE_PATH_STYLE=true

    ##  Dados do SMTP
      - MAILER_SENDER_EMAIL=$email_admin_chatwoot <$email_admin_chatwoot> ## Email SMTP
      - SMTP_DOMAIN=$dominio_smtp_chatwoot ## Dominio do email
      - SMTP_ADDRESS=$smtp_email_chatwoot ## Host SMTP
      - SMTP_PORT=$porta_smtp_chatwoot ## Porta SMTP
      - SMTP_SSL=$sobre_ssl ## Se a porta for 465 = true | Se a porta for 587 = false
      - SMTP_USERNAME=$user_smtp_chatwoot ## Usuario SMTP
      - SMTP_PASSWORD=$senha_email_chatwoot ## Senha do SMTP
      - SMTP_AUTHENTICATION=login
      - SMTP_ENABLE_STARTTLS_AUTO=true
      - SMTP_OPENSSL_VERIFY_MODE=peer
      - MAILER_INBOUND_EMAIL_DOMAIN=$email_admin_chatwoot ## Email SMTP

    ## Melhorias
      - SIDEKIQ_CONCURRENCY=10
      - RACK_TIMEOUT_SERVICE_TIMEOUT=0
      - RAILS_MAX_THREADS=5
      - WEB_CONCURRENCY=2
      - ENABLE_RACK_ATTACK=false

    ##  Outras configuracoes
      - NODE_ENV=production
      - RAILS_ENV=production
      - INSTALLATION_ENV=docker
      - RAILS_LOG_TO_STDOUT=true
      - USE_INBOX_AVATAR_FOR_BOT=true
      - ENABLE_ACCOUNT_SIGNUP=false

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
        - traefik.http.routers.chatwoot${1:+_$1}_app.rule=Host(\`$url_chatwoot\`)
        - traefik.http.routers.chatwoot${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.chatwoot${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.chatwoot${1:+_$1}_app.priority=1
        - traefik.http.routers.chatwoot${1:+_$1}_app.service=chatwoot${1:+_$1}_app
        - traefik.http.services.chatwoot${1:+_$1}_app.loadbalancer.server.port=3000
        - traefik.http.services.chatwoot${1:+_$1}_app.loadbalancer.passHostHeader=true
        - traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https
        - traefik.http.routers.chatwoot${1:+_$1}_app.middlewares=sslheader

## --------------------------- FELSEN --------------------------- ##

  chatwoot${1:+_$1}_sidekiq:
    image: chatwoot/chatwoot:latest ## Versao do Chatwoot
    command: bundle exec sidekiq -C config/sidekiq.yml

    volumes:
      - chatwoot${1:+_$1}_storage:/app/storage ## Arquivos de conversa
      - chatwoot${1:+_$1}_public:/app/public ## Arquivos de logos
      - chatwoot${1:+_$1}_mailer:/app/app/views/devise/mailer ## Arquivos de email
      - chatwoot${1:+_$1}_mailers:/app/app/views/mailers ## Arquivos de emails

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Nome da Empresa
      - INSTALLATION_NAME=$nome_empresa_chatwoot

    ## " Secret key
      - SECRET_KEY_BASE=$encryption_key

    ##  Url Chatwoot
      - FRONTEND_URL=https://$url_chatwoot
      - FORCE_SSL=true

    ##  Idioma/LocalizaAAo padrao
      - DEFAULT_LOCALE=pt_BR
      - TZ=America/Sao_Paulo

    ## Google Cloud - Modifique de acordo com os seus dados
      #- GOOGLE_OAUTH_CLIENT_ID=369777777777-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
      #- GOOGLE_OAUTH_CLIENT_SECRET=ABCDEF-GHijklmnoPqrstuvwX-yz1234567
      #- GOOGLE_OAUTH_CALLBACK_URL=https://<your-server-domain>/omniauth/google_oauth2/callback

    ## " Facebook e Instagram
      #- IG_VERIFY_TOKEN=
      #- FB_VERIFY_TOKEN=
      #- FB_APP_SECRET=
      #- FB_APP_ID=

    ## 'aEUR' Dados do Redis
      - REDIS_URL=redis://chatwoot${1:+_$1}_redis:6379

    ## -"i Dados do Postgres
      - POSTGRES_HOST=pgvector
      - POSTGRES_USERNAME=postgres
      - POSTGRES_PASSWORD=$senha_pgvector ## Senha do postgres
      - POSTGRES_DATABASE=chatwoot${1:+_$1}

    ##  Armazenamento
      - ACTIVE_STORAGE_SERVICE=local ## use s3_compatible para MinIO
      #- STORAGE_BUCKET_NAME=chatwoot${1:+_$1}
      #- STORAGE_ACCESS_KEY_ID=ACCESS_KEY_MINIO
      #- STORAGE_SECRET_ACCESS_KEY=SECRET_KEY_MINIO
      #- STORAGE_REGION=eu-south
      #- STORAGE_ENDPOINT=https://s3.DOMINIO.COM
      #- STORAGE_FORCE_PATH_STYLE=true

    ##  Dados do SMTP
      - MAILER_SENDER_EMAIL=$email_admin_chatwoot <$email_admin_chatwoot> ## Email SMTP
      - SMTP_DOMAIN=$dominio_smtp_chatwoot ## Dominio do email
      - SMTP_ADDRESS=$smtp_email_chatwoot ## Host SMTP
      - SMTP_PORT=$porta_smtp_chatwoot ## Porta SMTP
      - SMTP_SSL=$sobre_ssl ## Se a porta for 465 = true | Se a porta for 587 = false
      - SMTP_USERNAME=$user_smtp_chatwoot ## Usuario SMTP
      - SMTP_PASSWORD=$senha_email_chatwoot ## Senha do SMTP
      - SMTP_AUTHENTICATION=login
      - SMTP_ENABLE_STARTTLS_AUTO=true
      - SMTP_OPENSSL_VERIFY_MODE=peer
      - MAILER_INBOUND_EMAIL_DOMAIN=$email_admin_chatwoot ## Email SMTP

    ## Melhorias
      - SIDEKIQ_CONCURRENCY=10
      - RACK_TIMEOUT_SERVICE_TIMEOUT=0
      - RAILS_MAX_THREADS=5
      - WEB_CONCURRENCY=2
      - ENABLE_RACK_ATTACK=false

    ##  Outras configuracoes
      - NODE_ENV=production
      - RAILS_ENV=production
      - INSTALLATION_ENV=docker
      - RAILS_LOG_TO_STDOUT=true
      - USE_INBOX_AVATAR_FOR_BOT=true
      - ENABLE_ACCOUNT_SIGNUP=false

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

  chatwoot${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - chatwoot${1:+_$1}_redis:/data

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
  chatwoot${1:+_$1}_storage:
    external: true
    name: chatwoot${1:+_$1}_storage
  chatwoot${1:+_$1}_public:
    external: true
    name: chatwoot${1:+_$1}_public
  chatwoot${1:+_$1}_mailer:
    external: true
    name: chatwoot${1:+_$1}_mailer
  chatwoot${1:+_$1}_mailers:
    external: true
    name: chatwoot${1:+_$1}_mailers
  chatwoot${1:+_$1}_redis:
    external: true
    name: chatwoot${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Chatwoot"
fi
STACK_NAME="chatwoot${1:+_$1}"
stack_editavel #> /dev/null 2>&1

#docker stack deploy --prune --resolve-image always -c chatwoot.yaml chatwoot > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Chatwoot"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/6]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest chatwoot/chatwoot:latest

## Usa o servico wait_chatwoot para verificar se o servico esta online
wait_stack chatwoot${1:+_$1}_chatwoot${1:+_$1}_redis chatwoot${1:+_$1}_chatwoot${1:+_$1}_app chatwoot${1:+_$1}_chatwoot${1:+_$1}_sidekiq

sleep 30
echo ""
## Mensagem de Passo
echo -e "\e[97m- MIGRANDO BANCO DE DADOS \e[33m[5/6]\e[0m"
echo ""
sleep 7

## Aqui vamos estar migrando o banco de dados usando o comando "bundle exec rails db:chatwoot_prepare"

## Basicamente voce poderia entrar no banco de dados do chatwoot e executar o comando por la tambem

container_name="chatwoot${1:+_$1}_chatwoot${1:+_$1}_app"

max_wait_time=1200

wait_interval=60

elapsed_time=0

while [ $elapsed_time -lt $max_wait_time ]; do
  CONTAINER_ID=$(docker ps -q --filter "name=$container_name")
  if [ -n "$CONTAINER_ID" ]; then
    break
  fi
  sleep $wait_interval
  elapsed_time=$((elapsed_time + wait_interval))
done

if [ -z "$CONTAINER_ID" ]; then
  echo "O conteiner nao foi encontrado apos $max_wait_time segundos."
  exit 1
fi

docker exec -it "$CONTAINER_ID" bundle exec rails db:chatwoot_prepare > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/2 - [ OK ] - Executando no container: bundle exec rails db:chatwoot_prepare"
else
    echo "1/2 - [ OFF ] - Executando no container: bundle exec rails db:chatwoot_prepare"
    echo "Nao foi possivel migrar o banco de dados"
fi

# Nome base do container (pode variar, por isso usamos grep para achar)
pg_container_name="pgvector_pgvector"

# Tempo maximo de espera (em segundos)
max_wait_time=1200
wait_interval=60
elapsed_time=0

# Aguarda ate o container aparecer
while [ $elapsed_time -lt $max_wait_time ]; do
  PG_CONTAINER_ID=$(docker ps -q --filter "name=$pg_container_name")
  if [ -n "$PG_CONTAINER_ID" ]; then
    break
  fi
  sleep $wait_interval
  elapsed_time=$((elapsed_time + wait_interval))
done

if [ -z "$PG_CONTAINER_ID" ]; then
  echo "O conteiner do PostgreSQL nao foi encontrado apos $max_wait_time segundos."
  exit 1
fi

# Executa os comandos SQL dentro do container
docker exec -i "$PG_CONTAINER_ID" psql -U postgres <<'SQL' > /dev/null 2>&1
ALTER SYSTEM SET timezone = 'UTC';
SET timezone = 'UTC';
ALTER DATABASE chatwoot${1:+_$1} SET timezone TO 'UTC';
SHOW timezone;
SQL

if [ $? -eq 0 ]; then
    echo "2/2 - [ OK ] - Executando no container: timezone configurado para UTC"
else
    echo "2/2 - [ OFF ] - Falha ao configurar timezone no PostgreSQL"
    echo "Verifique se o banco de dados e o usuario 'postgres' estao acessiveis."
fi

echo ""
## Mensagem de Passo
echo -e "\e[97m- ATIVANDO FUNCOES DO SUPER ADMIN \e[33m[6/6]\e[0m"
echo ""
sleep 1

##  Aqui vamos alterar um dado no postgres para liberar algumas funcoes ocultas no painel de super admin
wait_for_pgvector

docker exec -i $CONTAINER_ID psql -U postgres <<__FELSEN_MANAGED_FILE__ > /dev/null 2>&1
\c chatwoot${1:+_$1};
update installation_configs set locked = false;
\q
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/1 - [ OK ] - Desbloqueando tabela installation_configs no pgvector"
else
    echo "1/1 - [ OFF ] - Desbloqueando tabela installation_configs no pgvector"
    echo "Nao foi possivel liberar as funcoes do super_admin"
fi

echo ""


## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_chatwoot${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ CHATWOOT ]

Dominio do Chatwoot: https://$url_chatwoot

Usuario: Precisa criar dentro do Chatwoot

Senha: Precisa criar dentro do Chatwoot
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
echo -e "\e[32m[ CHATWOOT ]\e[0m"
echo ""

echo -e "\e[97mDominio:\e[33m https://$url_chatwoot\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m Precisa criar dentro do Chatwoot\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m Precisa criar dentro do Chatwoot\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########   ### ####### ###     ###   ############### ####### ####   ###     ###### ####### ###
## a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-a-a--  a-a-a-'    a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'
## a-a-a-a-a-a--  a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-- a-a-a-'    a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'
## a-a-a-"a-a-a-  a-a-a-a-- a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'    a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-'
## a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'    a-a-a-'  a-a-a-'a-a-a-'     a-a-a-'
## a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-a-a-a-a- a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-    a-a-a-   a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-    a-a-a-  a-a-a-a-a-a-     a-a-a-

