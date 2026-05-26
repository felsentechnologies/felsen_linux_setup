#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_passbolt() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_passbolt

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para o Passbolt (ex: passbolt.example.com): \e[0m" && read -r url_passbolt
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email do usuario Admin do Passbolt (ex: contato@example.com): \e[0m" && read -r email_user_passbolt
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r smtp_email_passbolt
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r smtp_user_passbolt
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r smtp_pass_passbolt
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_host_passbolt
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r smtp_port_passbolt
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$smtp_port_passbolt" -eq 465 ]; then
    smtp_ssltls_passbolt=false
    else
    smtp_ssltls_passbolt=true
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_passbolt
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do Passbolt:\e[97m $url_passbolt_front\e[0m"
    echo ""

    ## Informacao sobre Email do usuario Admin do Passbolt
    echo -e "\e[33mEmail Admin:\e[97m $email_user_passbolt\e[0m"
    echo ""

    ## Informacao sobre Email SMTP
    echo -e "\e[33mEmail SMTP:\e[97m $smtp_email_passbolt\e[0m"
    echo ""

    ## Informacao sobre Email SMTP
    echo -e "\e[33mUser SMTP:\e[97m $smtp_user_passbolt\e[0m"
    echo ""
    
    ## Informacao sobre Senha SMTP
    echo -e "\e[33mSenha SMTP:\e[97m $smtp_pass_passbolt\e[0m"
    echo ""
    
    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP:\e[97m $smtp_host_passbolt\e[0m"
    echo ""
    
    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP:\e[97m $smtp_port_passbolt\e[0m"
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
        nome_passbolt

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO PASSBOLT \e[33m[1/7]\e[0m"
echo ""
sleep 1


## Literalmente nada, apenas um espaco vazio caso precisar de adicionar alguma coisa
## Antes..
## E claro, para aparecer a mensagem do passo..


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO MYSQL \e[33m[2/7]\e[0m"
echo ""
sleep 1

dados

## Cria banco de dados do site no mysql
verificar_container_mysql
    if [ $? -eq 0 ]; then
        echo "1/3 - [ OK ] - MySQL ja instalado"
        pegar_senha_mysql > /dev/null 2>&1
        echo "2/3 - [ OK ] - Copiando senha do MySQL"
        criar_banco_mysql_da_stack "passbolt${1:+_$1}"
        echo "3/3 - [ OK ] - Criando banco de dados"
        echo ""
    else
        ferramenta_mysql
        pegar_senha_mysql > /dev/null 2>&1
        criar_banco_mysql_da_stack "passbolt${1:+_$1}"
    fi
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[3/7]\e[0m"
echo ""
sleep 1

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO A PASSBOLT \e[33m[4/7]\e[0m"
echo ""
sleep 1

## Aqui de fato vamos iniciar a instalacao do Passbolt

## Criando a stack passbolt.yaml
cat > passbolt${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  passbolt${1:+_$1}:
    image: passbolt/passbolt:latest ## Versao da aplicacao

    volumes:
      - passbolt${1:+_$1}_data:/var/www/passbolt/webroot
      - passbolt${1:+_$1}_config:/etc/passbolt/

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracoes Gerais
      - APP_FULL_BASE_URL=https://$url_passbolt
      - PASSBOLT_REGISTRATION_PUBLIC=false ## false = Nao permite registro de novos usuarios
      - PASSBOLT_SSL_FORCE=false
      - PASSBOLT_FORCE_SSL=false

    ## " JWT Authentication
      - PASSBOLT_PLUGINS_JWT_AUTHENTICATION_ENABLED=true
      - PASSBOLT_JWT_SERVER_KEY=
      - PASSBOLT_JWT_SERVER_PEM=

    ## -"i Banco do MySQL
      - DATASOURCES_DEFAULT_HOST=mysql
      - DATASOURCES_DEFAULT_PORT=3306
      - DATASOURCES_DEFAULT_DATABASE=passbolt${1:+_$1}
      - DATASOURCES_DEFAULT_USERNAME=root
      - DATASOURCES_DEFAULT_PASSWORD=$senha_mysql

    ##  Dados do SMTP
      - EMAIL_DEFAULT_FROM_NAME=Suporte
      - EMAIL_DEFAULT_FROM=$smtp_email_passbolt
      - EMAIL_TRANSPORT_DEFAULT_USERNAME=$smtp_user_passbolt
      - EMAIL_TRANSPORT_DEFAULT_PASSWORD=$smtp_pass_passbolt
      - EMAIL_TRANSPORT_DEFAULT_HOST=$smtp_host_passbolt
      - EMAIL_TRANSPORT_DEFAULT_PORT=$smtp_port_passbolt
      - EMAIL_TRANSPORT_DEFAULT_TLS=$smtp_ssltls_passbolt

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
        - traefik.http.routers.passbolt${1:+_$1}.rule=Host(\`$url_passbolt\`)
        - traefik.http.services.passbolt${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.passbolt${1:+_$1}.service=passbolt${1:+_$1}
        - traefik.http.routers.passbolt${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.passbolt${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.passbolt${1:+_$1}.tls=true
        ## Mobile APP
        - traefik.http.routers.passbolt${1:+_$1}.middlewares=passbolt${1:+_$1}_mobile
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.customrequestheaders.X-Forwarded-Proto=https
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.customrequestheaders.X-Forwarded-Port=443
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.customrequestheaders.X-Forwarded-Host=$url_passbolt
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.customrequestheaders.X-Real-IP=
        - traefik.http.routers.passbolt${1:+_$1}_mobile.rule=Host(\`$url_passbolt\`) && (PathPrefix(\`/auth/jwt/\`) || PathPrefix(\`/mobile/\`) || PathPrefix(\`/auth/verify\`))
        - traefik.http.routers.passbolt${1:+_$1}_mobile.entrypoints=websecure
        - traefik.http.routers.passbolt${1:+_$1}_mobile.tls=true
        - traefik.http.routers.passbolt${1:+_$1}_mobile.tls.certresolver=letsencryptresolver
        - traefik.http.routers.passbolt${1:+_$1}_mobile.service=passbolt${1:+_$1}
        - traefik.http.routers.passbolt${1:+_$1}_mobile.middlewares=passbolt${1:+_$1}_mobile
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.framedeny=false
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.sslredirect=false
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.stsincludesubdomains=true
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.stspreload=true
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.stsseconds=31536000
        - "traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.contentsecuritypolicy=default-src 'self' 'unsafe-inline' 'unsafe-eval'; img-src 'self' data:; connect-src 'self'"
        - traefik.http.middlewares.passbolt${1:+_$1}_mobile.headers.referrerpolicy=strict-origin-when-cross-origin

## --------------------------- FELSEN --------------------------- ##

volumes:
  passbolt${1:+_$1}_data:
    external: true
    name: passbolt${1:+_$1}_data
  passbolt${1:+_$1}_config:
    external: true
    name: passbolt${1:+_$1}_config

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da Passbolt"
fi
STACK_NAME="passbolt${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c passbolt.yaml passbolt > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack da Passbolt"
#fi

sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/7]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull passbolt/passbolt:latest

## Usa o servico wait_passbolt para verificar se o servico esta online
wait_stack "passbolt${1:+_$1}_passbolt${1:+_$1}"

wait_30_sec
wait_30_sec

## Mensagem de Passo
echo ""
echo -e "\e[97m- CADASTRANDO EMAIL COMO ADMINISTRADOR \e[33m[6/7]\e[0m"
echo ""
sleep 1

#docker exec -u www-data $(docker ps --format "{{.Names}}" | grep "^passbolt${1:+_$1}") /usr/share/php/passbolt/bin/cake passbolt register_user -u "$email_user_passbolt" -f Administrador -l Master -r admin

url_setup=$(docker exec -u www-data $(docker ps --format "{{.Names}}" | grep "^passbolt${1:+_$1}") \
/usr/share/php/passbolt/bin/cake passbolt register_user \
-u "$email_user_passbolt" -f Administrador -l Master -r admin | grep -o 'https://.*')

echo "1/1 - [ OK ] - Usuario administrador criado no email: $email_user_passbolt"
echo ""
## Mensagem de Passo
echo -e "\e[97m- CONFIGURANDO PASSBOLT.PHP \e[33m[7/7]\e[0m"
echo ""
sleep 1

PASSBOLT_FILE="/var/lib/docker/volumes/passbolt${1:+_$1}_config/_data/passbolt.php"
echo "1/5 - [ OK ] - Verificando diretorio"

# Captura o fingerprint do servidor GPG (substitua "server@passbolt" pelo seu email/keyid)
FINGERPRINT=$(gpg --show-keys --with-fingerprint /var/lib/docker/volumes/passbolt${1:+_$1}_config/_data/gpg/serverkey.asc | grep -A1 "pub" | tail -1 | tr -d ' ')

echo "2/5 - [ OK ] - Pegando Fingerprint"

cat > "$PASSBOLT_FILE" <<__FELSEN_MANAGED_FILE__
<?php
return [

    'App' => [
        'fullBaseUrl' => env('APP_FULL_BASE_URL', 'https://$url_passbolt'),
    ],

    'Datasources' => [
        'default' => [
            'host' => env('DATASOURCES_DEFAULT_HOST', 'mysql'),
            'port' => env('DATASOURCES_DEFAULT_PORT', 3306),
            'username' => env('DATASOURCES_DEFAULT_USERNAME', 'root'),
            'password' => env('DATASOURCES_DEFAULT_PASSWORD', '$senha_mysql'),
            'database' => env('DATASOURCES_DEFAULT_DATABASE', 'passbolt${1:+_$1}'),
        ],
    ],

    'EmailTransport' => [
        'default' => [
            'host' => env('EMAIL_TRANSPORT_DEFAULT_HOST', '$smtp_host_passbolt'),
            'port' => env('EMAIL_TRANSPORT_DEFAULT_PORT', $smtp_port_passbolt),
            'timeout' => env('EMAIL_TRANSPORT_DEFAULT_TIMEOUT', 30),
            'username' => env('EMAIL_TRANSPORT_DEFAULT_USERNAME', '$smtp_user_passbolt'),
            'password' => env('EMAIL_TRANSPORT_DEFAULT_PASSWORD', '$smtp_pass_passbolt'),
            'client' => env('EMAIL_TRANSPORT_DEFAULT_CLIENT', null),
            'tls' => env('EMAIL_TRANSPORT_DEFAULT_TLS', '$smtp_ssltls_passbolt'),
            'url' => env('EMAIL_TRANSPORT_DEFAULT_URL', null),
        ],
    ],

    'Email' => [
        'default' => [
            'transport' => env('EMAIL_DEFAULT_TRANSPORT', 'default'),
            'from' => [
                '$smtp_email_passbolt' => 'Suporte'
            ],
        ],
    ],

    'passbolt' => [
        'gpg' => [
            'serverKey' => [
                'fingerprint' => env('PASSBOLT_GPG_SERVER_KEY_FINGERPRINT', '$FINGERPRINT'),
                'public' => env('PASSBOLT_GPG_SERVER_KEY_PUBLIC', CONFIG . 'gpg' . DS . 'serverkey.asc'),
                'private' => env('PASSBOLT_GPG_SERVER_KEY_PRIVATE', CONFIG . 'gpg' . DS . 'serverkey_private.asc'),
            ],
        ],
        'security' => [
            'checkDomainMismatch' => false,
        ],
    ],
];
__FELSEN_MANAGED_FILE__
echo "3/5 - [ OK ] - Criando passbolt.php"

chmod 640 "$PASSBOLT_FILE"
chown www-data:www-data "$PASSBOLT_FILE"
echo "4/5 - [ OK ] - Dando permissao ao arquivo"

sleep 5

echo "5/5 - [ OK ] - Reiniciando o servico..."
docker service update --force passbolt${1:+_$1}_passbolt${1:+_$1} >/dev/null 2>&1

sleep 15
docker ps -a --filter "name=passbolt" --filter "status=exited" -q | xargs -r docker rm > /dev/null 2>&1



cd dados_vps

cat > dados_passbolt${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ PASSBOLT ]

Link do Passbolt: https://$url_passbolt

Email Administrador: $email_user_passbolt

Senha Administrador: Via link magico no email

Link de Setup: $url_setup
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
echo -e "\e[32m[ PASSBOLT ]\e[0m"
echo ""

echo -e "\e[97mLink do Painel:\e[33m https://$url_passbolt\e[0m"
echo ""

echo -e "\e[97mEmail Administrador:\e[33m $email_user_passbolt\e[0m"
echo ""

echo -e "\e[97mSenha Administrador:\e[33m Via link magico no email\e[0m"
echo ""

echo -e "\e[97mLink de Setup:\e[33m $url_setup\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  #######  ####### #####################   ########## ###############  ####### 
## a-a-a-"a-a-a-a-a- a-a-a-"a-a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a- 
## a-a-a-'  a-a-a-a--a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-a-a-a--  a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-a--
## a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'
## a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-
##  a-a-a-a-a-a-a-  a-a-a-a-a-a-a-    a-a-a-   a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a- 

