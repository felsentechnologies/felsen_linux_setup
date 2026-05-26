#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_krayincrm() {

## Verifica os recursos
recursos 2 4 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_krayincrm

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o dominio para o Krayin CRM (ex: krayincrm.example.com): \e[0m" && read -r url_krayincrm
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_krayincrm
    echo ""

    ## Sepera dominio
    dominio_smtp=$(echo "$email_krayincrm" | cut -d'@' -f2)

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_email_krayincrm
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_krayincrm
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_krayincrm
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_krayincrm
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_krayincrm" -eq 465 ]; then
    smtp_secure_krayincrm=ssl
    else
    smtp_secure_krayincrm=tls
    fi   
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_krayincrm
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do krayincrm
    echo -e "\e[33mDominio do krayincrm:\e[97m $url_krayincrm\e[0m"
    echo ""

     ## Informacao sobre Email
    echo -e "\e[33mEmail do SMTP:\e[97m $email_krayincrm\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mUsuario do SMTP:\e[97m $usuario_email_krayincrm\e[0m"
    echo ""

    ## Informacao sobre Senha do Email
    echo -e "\e[33mSenha do Email:\e[97m $senha_email_krayincrm\e[0m"
    echo ""

    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP do Email:\e[97m $smtp_email_krayincrm\e[0m"
    echo ""

    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP do Email:\e[97m $porta_smtp_krayincrm\e[0m"
    echo ""

    ## Informacao sobre Secure SMTP
    echo -e "\e[33mSecure SMTP do Email:\e[97m $smtp_secure_krayincrm\e[0m"
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
        nome_krayincrm

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO KRAYIN CRM \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO KRAYIN CRM \e[33m[2/4]\e[0m"
echo ""
sleep 1

secret_key="base64:$(openssl rand -base64 32)"
senha_percona_krayin=$(openssl rand -hex 16)

## Criando a stack krayincrm.yaml
cat > krayincrm${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  krayin${1:+_$1}_app:
    image: webkul/krayin:v2.1.2-https

    volumes:
      - krayin${1:+_$1}_app:/var/www/html/
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
      ##  Configuracoes basicas da aplicacao
      - APP_URL=https://$url_krayincrm
      - APP_NAME=Krayin CRM
      - APP_ENV=local
      - APP_KEY=$secret_key
      - APP_TIMEZONE=America/Sao_Paulo
      - APP_LOCALE=pt_BR
      - APP_CURRENCY=BRL
      
      ## Configuracoes do Frontend (Vite)
      - VITE_HOST=0.0.0.0
      - VITE_PORT=5173
      
      ##  Logs da aplicacao
      - LOG_CHANNEL=stack
      - LOG_LEVEL=debug
      - APP_DEBUG=true
      
      ## -"i Banco de Dados
      - DB_CONNECTION=mysql
      - DB_HOST=krayin${1:+_$1}_db
      - DB_PORT=3306
      - DB_DATABASE=krayincrm${1:+_$1}
      - DB_USERNAME=root
      - DB_PASSWORD=$senha_percona_krayin
      - DB_PREFIX=
      
      ## Drivers da aplicacao
      - BROADCAST_DRIVER=log
      - CACHE_DRIVER=file
      - QUEUE_CONNECTION=sync
      - SESSION_DRIVER=file
      - SESSION_LIFETIME=120
      
      ##  Redis (opcional)
      - REDIS_HOST=krayin${1:+_$1}_redis
      - REDIS_PASSWORD=null
      - REDIS_PORT=6379
      
      ## E-mail (SMTP)
      - MAIL_MAILER=smtp
      - MAIL_FROM_ADDRESS=$email_krayincrm
      - MAIL_DOMAIN=$dominio_smtp
      - MAIL_USERNAME=$usuario_email_krayincrm
      - MAIL_PASSWORD=$senha_email_krayincrm
      - MAIL_HOST=$smtp_email_krayincrm
      - MAIL_PORT=$porta_smtp_krayincrm
      - MAIL_ENCRYPTION=$smtp_secure_krayincrm
      - MAIL_FROM_NAME=Krayin CRM
      
      ## AWS (armazenamento em nuvem - opcional)
      #- AWS_ACCESS_KEY_ID=
      #- AWS_SECRET_ACCESS_KEY=
      #- AWS_DEFAULT_REGION=eu-south
      #- AWS_BUCKET=

    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.krayin${1:+_$1}_app.rule=Host(\`$url_krayincrm\`)
        - traefik.http.services.krayin${1:+_$1}_app.loadbalancer.server.port=80
        - traefik.http.routers.krayin${1:+_$1}_app.service=krayin${1:+_$1}_app
        - traefik.http.routers.krayin${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.krayin${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.krayin${1:+_$1}_app.tls=true
        - traefik.http.middlewares.headers.headers.customrequestheaders.X-Forwarded-Proto=https
        - traefik.http.routers.krayin.middlewares=headers

## --------------------------- FELSEN --------------------------- ##

  krayin${1:+_$1}_db:
    image: percona/percona-server:latest
    command:
      - --character-set-server=utf8mb4
      - --collation-server=utf8mb4_general_ci
      - --sql-mode=
      - --default-authentication-plugin=mysql_native_password
      - --max-allowed-packet=512MB
      - --expire_logs_days=7
      - --max_binlog_size=100M

    volumes:
      - krayin${1:+_$1}_db:/var/lib/mysql

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
     ## -"i Configuracoes do MySQL
      - MYSQL_ROOT_PASSWORD=$senha_percona_krayin
      - MYSQL_DATABASE=krayincrm${1:+_$1}
    
    ##  TimeZone
      - TZ=America/Sao_Paulo

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

  krayin${1:+_$1}_redis:
    image: redis:latest
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - krayin${1:+_$1}_redis:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

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

volumes:
  krayin${1:+_$1}_app:
    external: true
    name: krayin${1:+_$1}_app
  krayin${1:+_$1}_db:
    external: true
    name: krayin${1:+_$1}_db
  krayin${1:+_$1}_redis:
    external: true
    name: krayin${1:+_$1}_redis


networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do krayincrm"
fi
STACK_NAME="krayincrm${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c krayincrm.yaml krayincrm > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do krayincrm"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull percona/percona-server:latest redis:latest webkul/krayin:v2.1.2-https

## Usa o servico wait_krayincrm para verificar se o servico esta online
wait_stack krayincrm${1:+_$1}_krayin${1:+_$1}_db krayincrm${1:+_$1}_krayin${1:+_$1}_redis krayincrm${1:+_$1}_krayin${1:+_$1}_app 

sleep 30

## Mensagem de Passo
echo ""
echo -e "\e[97m- MIGRANDO BANCO E ATIVANDO API \e[33m[4/4]\e[0m"
echo ""
sleep 1

docker exec -it $(docker ps --filter "name=krayincrm_krayin_app" -q) sh -c "cd laravel-crm && php artisan migrate" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/4 - [ OK ] - Migracoes Executadas"
else
    echo "1/4 - [ OFF ] - Falha ao executar migracoes"
fi

docker exec -it $(docker ps --filter "name=krayincrm_krayin_app" -q) sh -c "cd laravel-crm && php artisan db:seed" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "2/4 - [ OK ] - Seeds Executados"
else
    echo "2/4 - [ OFF ] - Falha ao executar Seeds"
fi

docker exec -it $(docker ps --filter "name=krayincrm_krayin_app" -q) sh -c "cd laravel-crm && composer require krayin/rest-api" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "3/4 - [ OK ] - Pacote Rest-API instalado"
else
    echo "3/4 - [ OFF ] - Falha ao instalar pacote Rest-API"
fi

docker exec -it $(docker ps --filter "name=krayincrm_krayin_app" -q) sh -c "cd laravel-crm && php artisan krayin-rest-api:install" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "4/4 - [ OK ] - Rest-API configurado"
else
    echo "4/4 - [ OFF ] - Falha ao configurar Rest-API"
fi


cd dados_vps

cat > dados_krayincrm${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ KRAYIN CRM ]

Dominio do Krayin CRM: https://$url_krayincrm

Usuario: admin@example.com

Senha: admin123

Documentacao: https://$url_krayincrm/api/documentation

----

Host Mysql: krayin${1:+_$1}_db

Porta Mysql: 3306

Usuario Mysql: root

Senha Mysql: $senha_percona_krayin

Database Mysql: krayincrm${1:+_$1}

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
echo -e "\e[32m[ KRAYIN CRM ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_krayincrm\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m admin@example.com\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m admin123\e[0m"
echo ""

echo -e "\e[33mDocumentacao:\e[97m https://$url_krayincrm/api/documentation\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ####### ###      ###### ####   ######  ### ###### 
## a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-' a-a-a-"a-a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-'
## a-a-a-"a-a-a-a- a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-- a-a-a-"a-a-a-a-a-'
## ##|     ##########|  ##|##| #####|##|  #####|  ##|
## a-a-a-     a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-

