#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_supabase() {

## Verifica os recursos
recursos 2 4 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_supabase

## Mostra mensagem para preencher informacoes
preencha_as_info

generate_jwt_tokens() {
    # Verificar a disponibilidade dos comandos necessarios e instala-los se necessario
    if ! command -v openssl &> /dev/null; then
        echo "O comando 'openssl' nao esta disponivel. Tentando instalar..."
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS
            brew install openssl
        elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
            # Linux
            if [[ -f /etc/redhat-release ]]; then
                # Red Hat, CentOS, Fedora
                sudo yum install -y openssl
            elif [[ -f /etc/debian_version ]]; then
                # Debian, Ubuntu
                sudo apt-get install -y openssl
            else
                echo "Nao foi possivel identificar a distribuicao Linux. Por favor, instale o OpenSSL manualmente."
                return 1
            fi
        else
            echo "Sistema operacional nao suportado. Por favor, instale o OpenSSL manualmente."
            return 1
        fi
    fi

    if ! command -v jq &> /dev/null; then
        echo "O comando 'jq' nao esta disponivel. Tentando instalar..."
        if [[ "$(uname)" == "Darwin" ]]; then
            # macOS
            brew install jq
        elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
            # Linux
            if [[ -f /etc/redhat-release ]]; then
                # Red Hat, CentOS, Fedora
                sudo yum install -y jq
            elif [[ -f /etc/debian_version ]]; then
                # Debian, Ubuntu
                sudo apt-get install -y jq
            else
                echo "Nao foi possivel identificar a distribuicao Linux. Por favor, instale o jq manualmente."
                return 1
            fi
        else
            echo "Sistema operacional nao suportado. Por favor, instale o jq manualmente."
            return 1
        fi
    fi

# Definir os payloads dos JWTs
    payload_service_key=$(echo '{
      "role": "service_role",
      "iss": "supabase",
      "iat": 1715050800,
      "exp": 1872817200
    }' | jq .)

    
    payload_anon_key=$(echo '{
      "role": "anon",
      "iss": "supabase",
      "iat": 1715050800,
      "exp": 1872817200
    }' | jq .)

    # Gerar uma chave secreta aleatoria e segura
    secret=$(openssl rand -hex 20)

    # Codificar o header em base64url
    header=$(echo -n '{"alg":"HS256","typ":"JWT"}' | openssl base64 | tr -d '=' | tr '+/' '-_' | tr -d '\n')
    
    # Codificar os payloads em base64url
    payload_service_key_base64=$(echo -n "$payload_service_key" | openssl base64 | tr -d '=' | tr '+/' '-_' | tr -d '\n')
    payload_anon_key_base64=$(echo -n "$payload_anon_key" | openssl base64 | tr -d '=' | tr '+/' '-_' | tr -d '\n')

    # Criar as assinaturas dos tokens usando a mesma chave secreta
    signature_service_key=$(echo -n "$header.$payload_service_key_base64" | openssl dgst -sha256 -hmac "$secret" -binary | openssl base64 | tr -d '=' | tr '+/' '-_' | tr -d '\n')
    signature_anon_key=$(echo -n "$header.$payload_anon_key_base64" | openssl dgst -sha256 -hmac "$secret" -binary | openssl base64 | tr -d '=' | tr '+/' '-_' | tr -d '\n')

    # Combinar as partes dos tokens
    token_service_key="$header.$payload_service_key_base64.$signature_service_key"
    token_anon_key="$header.$payload_anon_key_base64.$signature_anon_key"

    # Retornar os valores gerados como uma string separada por espacos
    echo "$secret $token_service_key $token_anon_key"
}

# Chamar a funcao e armazenar o retorno em uma variavel
result=$(generate_jwt_tokens)

# Verificar se o resultado esta vazio
if [[ -z "$result" ]]; then
    echo "A funcao retornou um resultado vazio. Verifique a configuracao do ambiente e as dependencias."
    exit 1
fi

# Extrair os valores individuais usando o comando 'read'
read secret token_service_key token_anon_key <<< "$result"


## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do Builder
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para o Supabase (ex: supabase.example.com): \e[0m" && read -r url_supabase
    echo ""

    ##Pergunta o Dominio do Viewer
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o Usuario para o Supabase (ex: Felsen): \e[0m" && read -r user_supabase
    echo ""

    ##Pergunta a versao da ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "$amarelo--> Sem NENHUM caracteres especiais, tais como: @\!#$ entre outros"
    echo -en "\e[33mDigite a Senha do usuario para o Supabase (ex: Senha123): \e[0m" && read -r pass_supabase
    echo ""

    ###Pergunta o Email SMTP
    #echo -e "\e[97mPasso$amarelo 4/10\e[0m"
    #echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_supabase
    #echo ""

    ##Pergunta o usuario do Email SMTP
    #echo -e "\e[97mPasso$amarelo 5/10\e[0m"
    #echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    #echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_email_supabase
    #echo ""
    
    ## Pergunta a senha do SMTP
    #echo -e "\e[97mPasso$amarelo 6/10\e[0m"
    #echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    #echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_supabase
    #echo ""

    ## Pergunta o Host SMTP do email
    #echo -e "\e[97mPasso$amarelo 7/10\e[0m"
    #echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_supabase
    #echo ""

    ## Pergunta a porta SMTP do email
    #echo -e "\e[97mPasso$amarelo 8/10\e[0m"
    #echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_supabase
    #echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    #if [ "$porta_smtp_supabase" -eq 465 ]; then
    #smtp_secure_supabase=true
    #else
    #smtp_secure_supabase=false
    #fi

    ## Gera a JWT_Key
    JWT_Key="$secret"

    ## Gera a ANON_KEY
    ANON_KEY="$token_anon_key"

    ## Gera o SERVICE_KEY
    SERVICE_KEY="$token_service_key"

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_supabase
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Builder
    echo -e "\e[33mDominio do Supabase:\e[97m $url_supabase\e[0m"
    echo ""

    ## Informacao sobre URL do Viewer
    echo -e "\e[33mUsuario:\e[97m $user_supabase\e[0m"
    echo ""

    ## Informacao sobre a versao da ferramenta
    echo -e "\e[33mSenha:\e[97m $pass_supabase\e[0m"
    echo ""    

    ## Informacao sobre Email
    #echo -e "\e[33mEmail do SMTP:\e[97m $email_supabase\e[0m"
    #echo ""

    ## Informacao sobre Email
    #echo -e "\e[33mUsuario do SMTP:\e[97m $usuario_email_supabase\e[0m"
    #echo ""

    ## Informacao sobre Senha do Email
    #echo -e "\e[33mSenha do Email:\e[97m $senha_email_supabase\e[0m"
    #echo ""

    ## Informacao sobre Host SMTP
    #echo -e "\e[33mHost SMTP do Email:\e[97m $smtp_email_supabase\e[0m"
    #echo ""

    ## Informacao sobre Porta SMTP
    #echo -e "\e[33mPorta SMTP do Email:\e[97m $porta_smtp_supabase\e[0m"
    #echo ""

    ## Informacao sobre Secure SMTP
    #echo -e "\e[33mSecure SMTP do Email:\e[97m $smtp_secure_supabase\e[0m"
    #echo ""

    ## Informacao sobre JWT_Key
    echo -e "\e[33mJWT_Key:\e[97m $JWT_Key\e[0m"
    echo ""

    ## Informacao sobre ANON_KEY
    echo -e "\e[33mAnon Key:\e[97m $ANON_KEY\e[0m"
    echo ""

    ## Informacao sobre SERVICE_KEY
    echo -e "\e[33mService Key:\e[97m $SERVICE_KEY\e[0m"
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
        nome_supabase

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done


## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO SUPABASE \e[33m[1/3]\e[0m"
echo ""
sleep 1


cd
if [ -d "/root/supabase${1:+_$1}" ]; then
  sudo rm -r /root/supabase${1:+_$1}
fi
mkdir supabase${1:+_$1}

mkdir temp${1:+_$1}

cd temp${1:+_$1}

#git clone --depth 1 https://github.com/felsen-labs/linux-setup > /dev/null 2>&1
git clone --depth 1 https://github.com/supabase/supabase.git > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Baixando Repositorio do Supabase"
else
    echo "1/3 - [ OFF ] - Baixando Repositorio do Supabase"
    echo "Nao foi possivel Baixar."
fi
cd supabase
git checkout 3f6f8aa906f67dbc7674759e6b2560703e8c5201 > /dev/null 2>&1

#mv Felsen Linux Setup/Extras/Supabase /root/supabase${1:+_$1}
cd docker

rm -r dev .env.example .gitignore README.md docker-compose.s3.yml docker-compose.yml reset.sh

cd ..

mv docker /root/supabase${1:+_$1}/docker

cd
cd

rm -r temp${1:+_$1}

sudo mkdir -p /root/supabase${1:+_$1}/docker/volumes/db/data
if [ $? -eq 0 ]; then
    echo "2/3 - [ OK ] - Criando diretorio 1"
else
    echo "2/3 - [ OFF ] - Criando diretorio 1"
    echo "Nao foi criar o diretorio"
fi

#sudo mkdir -p /var/lib/postgresql/data
#if [ $? -eq 0 ]; then
#    echo "1/4 - [ OK ] - Criando diretorio 2"
#else
#    echo "1/4 - [ OFF ] - Criando diretorio 2"
#    echo "Nao foi criar o diretorio"
#fi

sudo mkdir -p /root/supabase${1:+_$1}/docker/volumes/storage
if [ $? -eq 0 ]; then
    echo "3/3 - [ OK ] - Criando diretorio 2"
else
    echo "3/3 - [ OFF ] - Criando diretorio 2"
    echo "Nao foi criar o diretorio"
fi

HASH=$(openssl rand -hex 6 | cut -c1-10)

cat > kong.yml <<__FELSEN_MANAGED_FILE__
_format_version: '2.1'
_transform: true

###
### Consumers / Users
###
consumers:
  - username: DASHBOARD
  - username: anon
    keyauth_credentials:
      - key: \$SUPABASE_ANON_KEY
  - username: service_role
    keyauth_credentials:
      - key: \$SUPABASE_SERVICE_KEY

###
### Access Control List
###
acls:
  - consumer: anon
    group: anon
  - consumer: service_role
    group: admin

###
### Dashboard credentials
###
basicauth_credentials:
  - consumer: DASHBOARD
    username: '\$DASHBOARD_USERNAME'
    password: '\$DASHBOARD_PASSWORD'

###
### API Routes
###
services:
  ## Open Auth routes
  - name: auth-v1-open
    url: http://supabase${1:+_$1}_auth:9999/verify
    routes:
      - name: auth-v1-open
        strip_path: true
        paths:
          - /auth/v1/verify
    plugins:
      - name: cors
  - name: auth-v1-open-callback
    url: http://supabase${1:+_$1}_auth:9999/callback
    routes:
      - name: auth-v1-open-callback
        strip_path: true
        paths:
          - /auth/v1/callback
    plugins:
      - name: cors
  - name: auth-v1-open-authorize
    url: http://supabase${1:+_$1}_auth:9999/authorize
    routes:
      - name: auth-v1-open-authorize
        strip_path: true
        paths:
          - /auth/v1/authorize
    plugins:
      - name: cors

  ## Secure Auth routes
  - name: auth-v1
    _comment: 'GoTrue: /auth/v1/* -> http://supabase${1:+_$1}_auth:9999/*'
    url: http://supabase${1:+_$1}_auth:9999/
    routes:
      - name: auth-v1-all
        strip_path: true
        paths:
          - /auth/v1/
    plugins:
      - name: cors
      - name: key-auth
        config:
          hide_credentials: false
      - name: acl
        config:
          hide_groups_header: true
          allow:
            - admin
            - anon

  ## Secure REST routes
  - name: rest-v1
    _comment: 'PostgREST: /rest/v1/* -> http://supabase${1:+_$1}_rest:3000/*'
    url: http://supabase${1:+_$1}_rest:3000/
    routes:
      - name: rest-v1-all
        strip_path: true
        paths:
          - /rest/v1/
    plugins:
      - name: cors
      - name: key-auth
        config:
          hide_credentials: true
      - name: acl
        config:
          hide_groups_header: true
          allow:
            - admin
            - anon

  ## Secure GraphQL routes
  - name: graphql-v1
    _comment: 'PostgREST: /graphql/v1/* -> http://supabase${1:+_$1}_rest:3000/rpc/graphql'
    url: http://supabase${1:+_$1}_rest:3000/rpc/graphql
    routes:
      - name: graphql-v1-all
        strip_path: true
        paths:
          - /graphql/v1
    plugins:
      - name: cors
      - name: key-auth
        config:
          hide_credentials: true
      - name: request-transformer
        config:
          add:
            headers:
              - Content-Profile:graphql_public
      - name: acl
        config:
          hide_groups_header: true
          allow:
            - admin
            - anon

  ## Secure Realtime routes
  - name: realtime-v1-ws
    _comment: 'Realtime: /realtime/v1/* -> ws://supabase${1:+_$1}_realtime:4000/socket/*'
    url: http://supabase${1:+_$1}_realtime:4000/socket
    protocol: ws
    routes:
      - name: realtime-v1-ws
        strip_path: true
        paths:
          - /realtime/v1/
    plugins:
      - name: cors
      - name: key-auth
        config:
          hide_credentials: false
      - name: acl
        config:
          hide_groups_header: true
          allow:
            - admin
            - anon
  - name: realtime-v1-rest
    _comment: 'Realtime: /realtime/v1/* -> ws://supabase${1:+_$1}_realtime:4000/socket/*'
    url: http://supabase${1:+_$1}_realtime:4000/api
    protocol: http
    routes:
      - name: realtime-v1-rest
        strip_path: true
        paths:
          - /realtime/v1/api
    plugins:
      - name: cors
      - name: key-auth
        config:
          hide_credentials: false
      - name: acl
        config:
          hide_groups_header: true
          allow:
            - admin
            - anon
  ## Storage routes: the storage server manages its own auth
  - name: storage-v1
    _comment: 'Storage: /storage/v1/* -> http://supabase${1:+_$1}_storage:5000/*'
    url: http://supabase${1:+_$1}_storage:5000/
    routes:
      - name: storage-v1-all
        strip_path: true
        paths:
          - /storage/v1/
    plugins:
      - name: cors

  ## Edge Functions routes
  - name: functions-v1
    _comment: 'Edge Functions: /functions/v1/* -> http://supabase${1:+_$1}_functions:9000/*'
    url: http://supabase${1:+_$1}_functions:9000/
    routes:
      - name: functions-v1-all
        strip_path: true
        paths:
          - /functions/v1/
    plugins:
      - name: cors

  ## Analytics routes
  - name: analytics-v1
    _comment: 'Analytics: /analytics/v1/* -> http://supabase${1:+_$1}_analytics:4000/*'
    url: http://supabase${1:+_$1}_analytics:4000/
    routes:
      - name: analytics-v1-all
        strip_path: true
        paths:
          - /analytics/v1/

  ## Secure Database routes
  - name: meta
    _comment: 'pg-meta: /pg/* -> http://supabase${1:+_$1}_meta:8080/*'
    url: http://supabase${1:+_$1}_meta:8080/
    routes:
      - name: meta-all
        strip_path: true
        paths:
          - /pg/
    plugins:
      - name: key-auth
        config:
          hide_credentials: false
      - name: acl
        config:
          hide_groups_header: true
          allow:
            - admin

  ## Block access to /api/mcp
  - name: mcp-blocker
    _comment: 'Block direct access to /api/mcp'
    url: http://supabase${1:+_$1}_studio:3000/api/mcp
    routes:
      - name: mcp-blocker-route
        strip_path: true
        paths:
          - /api/mcp
    plugins:
      - name: request-termination
        config:
          status_code: 403
          message: "Access is forbidden."

  - name: mcp
    _comment: 'MCP: /mcp/Felsen Linux Setup/$HASH -> http://supabase${1:+_$1}_studio:3000/api/mcp (public access)'
    url: http://supabase${1:+_$1}_studio:3000/api/mcp
    routes:
      - name: mcp
        strip_path: true
        paths:
          - /mcp/Felsen Linux Setup/$HASH
    plugins:
      - name: cors

  ## Protected Dashboard - catch all remaining routes
  - name: dashboard
    _comment: 'Studio: /* -> http://supabase${1:+_$1}_studio:3000/*'
    url: http://supabase${1:+_$1}_studio:3000/
    routes:
      - name: dashboard-all
        strip_path: true
        paths:
          - /
    plugins:
      - name: cors
      - name: basic-auth
        config:
          hide_credentials: true
__FELSEN_MANAGED_FILE__
rm /root/supabase${1:+_$1}/docker/volumes/api/kong.yml

mv kong.yml /root/supabase${1:+_$1}/docker/volumes/api/kong.yml

echo ""

## Mensagem de Passo
#echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[2/4]\e[0m"
#echo ""
#sleep 1
#
#pegar_senha_minio
#minio.bucket supabase${1:+-$1} > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
#else
#    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
#    echo ""
#fi
#
#echo ""
### Mensagem de Passo
echo -e "\e[97m- INSTALANDO SUPABASE \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando key Aleatorias
Senha_Postgres=$(openssl rand -hex 16)

Logflare_key=$(openssl rand -hex 16)

Logflare_key_public=$(openssl rand -hex 16)

SECRET_KEY_BASE=$(openssl rand -hex 32)

VAULT_ENC_KEY=$(openssl rand -base64 32 | tr -d '\n' | cut -c1-32)

MCP_API_KEY=$(openssl rand -hex 16)

PG_META_CRYPTO_KEY=$(openssl rand -hex 32)

## Criando a stack supabase.yaml
cat > supabase${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_studio:
    image: supabase/studio:2025.11.10-sha-5291fe3

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:     
      - HOSTNAME=0.0.0.0
      - SUPABASE_URL=http://supabase${1:+_$1}_kong:8000
      - SUPABASE_PUBLIC_URL=https://$url_supabase
      - SUPABASE_ANON_KEY=$ANON_KEY
      - SUPABASE_SERVICE_KEY=$SERVICE_KEY
      - AUTH_JWT_SECRET=$JWT_Key

    ##  Configuracao de Branding
      - DEFAULT_ORGANIZATION_NAME=FELSENAcademy
      - DEFAULT_PROJECT_NAME=Felsen Linux Setup

      - POSTGRES_DB=postgres
      - POSTGRES_HOST=supabase${1:+_$1}_db
      - POSTGRES_PORT=5432
      - POSTGRES_PASSWORD=$Senha_Postgres
      - PG_META_CRYPTO_KEY=$PG_META_CRYPTO_KEY

    ##  Integracao com Logflare
      - LOGFLARE_URL=http://supabase${1:+_$1}_analytics:4000
      - LOGFLARE_API_KEY=$Logflare_key
      - LOGFLARE_PUBLIC_ACCESS_TOKEN=$Logflare_key_public
      - LOGFLARE_PRIVATE_ACCESS_TOKEN=$Logflare_key
      - NEXT_PUBLIC_ENABLE_LOGS=true
      - NEXT_ANALYTICS_BACKEND_PROVIDER=postgres
      - DEBUG=next:*

      - STUDIO_PG_META_URL=http://supabase${1:+_$1}_meta:8080

    ##  Configuracao do OpenAI (opcional)
      # - OPENAI_API_KEY=

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_kong:
    image: kong:2.8.1
    entrypoint: bash -c 'eval "echo \"\$\$(cat ~/temp.yml)\"" > ~/kong.yml && /docker-entrypoint.sh kong docker-start'

    volumes:
      - /root/supabase${1:+_$1}/docker/volumes/api/kong.yml:/home/kong/temp.yml:ro,z

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - DASHBOARD_USERNAME=$user_supabase
      - DASHBOARD_PASSWORD=$pass_supabase

      - JWT_SECRET=$JWT_Key
      - SUPABASE_ANON_KEY=$ANON_KEY
      - SUPABASE_SERVICE_KEY=$SERVICE_KEY

      - KONG_DATABASE=off
      - KONG_DECLARATIVE_CONFIG=/home/kong/kong.yml

      - KONG_DNS_ORDER=LAST,A,CNAME

    ##  Configuracao de Plugins
      - KONG_PLUGINS=request-transformer,cors,key-auth,acl,basic-auth,request-termination,ip-restriction

    ##  Configuracoes de Buffers do NGINX
      - KONG_NGINX_PROXY_PROXY_BUFFER_SIZE=160k
      - KONG_NGINX_PROXY_PROXY_BUFFERS=64 160k

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager  
      labels:
        - traefik.enable=true
        - traefik.http.routers.supabase${1:+_$1}_kong.rule=Host(\`$url_supabase\`) && PathPrefix(\`/\`) ## Url do Supabase
        - traefik.http.services.supabase${1:+_$1}_kong.loadbalancer.server.port=8000
        - traefik.http.routers.supabase${1:+_$1}_kong.service=supabase${1:+_$1}_kong
        - traefik.http.routers.supabase${1:+_$1}_kong.entrypoints=websecure
        - traefik.http.routers.supabase${1:+_$1}_kong.tls.certresolver=letsencryptresolver
        - traefik.http.routers.supabase${1:+_$1}_kong.tls=true

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_auth:
    image: supabase/gotrue:v2.182.1

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - GOTRUE_API_HOST=0.0.0.0
      - GOTRUE_API_PORT=9999
      - API_EXTERNAL_URL=https://$url_supabase

      - GOTRUE_DB_DRIVER=postgres
      - GOTRUE_DB_DATABASE_URL=postgres://supabase_auth_admin:$Senha_Postgres@supabase${1:+_$1}_db:5432/postgres ## Troque a senha do postgres

      - GOTRUE_SITE_URL=https://$url_supabase
      - GOTRUE_URI_ALLOW_LIST=
      - GOTRUE_DISABLE_SIGNUP=false

      - GOTRUE_JWT_ADMIN_ROLES=service_role
      - GOTRUE_JWT_AUD=authenticated
      - GOTRUE_JWT_DEFAULT_GROUP_NAME=authenticated
      - GOTRUE_JWT_EXP=31536000
      - GOTRUE_JWT_SECRET=$JWT_Key

    ##  Configuracao de email
      - GOTRUE_EXTERNAL_EMAIL_ENABLED=false
      - GOTRUE_EXTERNAL_ANONYMOUS_USERS_ENABLED=false
      - GOTRUE_MAILER_AUTOCONFIRM=true
      - GOTRUE_EXTERNAL_SKIP_NONCE_CHECK=true
      - GOTRUE_MAILER_SECURE_EMAIL_CHANGE_ENABLED=true
      - GOTRUE_SMTP_MAX_FREQUENCY=1s

      #- GOTRUE_SMTP_SENDER_NAME=email@dominio.com # Nome do remetente SMTP
      #- GOTRUE_SMTP_ADMIN_EMAIL=email@dominio.com # Email administrador SMTP
      #- GOTRUE_SMTP_USER=email@dominio.com # Usuario SMTP
      #- GOTRUE_SMTP_PASS=senha # Senha SMTP
      #- GOTRUE_SMTP_HOST=smtp.dominio.com # Host SMTP
      #- GOTRUE_SMTP_PORT=587 # Porta SMTP

    ##  Configuracoes de URL para Emails
      - GOTRUE_MAILER_URLPATHS_INVITE=/auth/v1/verify
      - GOTRUE_MAILER_URLPATHS_CONFIRMATION=/auth/v1/verify
      - GOTRUE_MAILER_URLPATHS_RECOVERY=/auth/v1/verify
      - GOTRUE_MAILER_URLPATHS_EMAIL_CHANGE=/auth/v1/verify

    ## Configuracoes de Hooks (descomente para usar)
      #- GOTRUE_HOOK_SEND_EMAIL_ENABLED=false
      #- GOTRUE_HOOK_SEND_EMAIL_URI=http://host.docker.internal:54321/functions/v1/email_sender
      #- GOTRUE_HOOK_SEND_EMAIL_SECRETS=v1,whsec_VGhpcyBpcyBhbiBleGFtcGxlIG9mIGEgc2hvcnRlciBCYXNlNjQgc3RyaW5n
    
    ## Configuracoes de SMS
      - GOTRUE_EXTERNAL_PHONE_ENABLED=false
      - GOTRUE_SMS_AUTOCONFIRM=false

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_rest:
    image: postgrest/postgrest:v13.0.7
    command:
      [
        "postgrest"
      ]
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - PGRST_DB_URI=postgres://authenticator:$Senha_Postgres@supabase${1:+_$1}_db:5432/postgres
      - PGRST_DB_SCHEMAS=public,storage,graphql_public
      - PGRST_DB_ANON_ROLE=anon

      - PGRST_JWT_SECRET=$JWT_Key
      - PGRST_APP_SETTINGS_JWT_SECRET=$JWT_Key
      - PGRST_APP_SETTINGS_JWT_EXP=31536000
    
      - PGRST_DB_USE_LEGACY_GUCS=false
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_realtime:
    image: supabase/realtime:v2.63.0

    networks:
      - $nome_rede_interna ## Nome da rede interna
    dns:
      - 127.0.0.11

    environment:
      - PORT=4000
      - API_JWT_SECRET=$JWT_Key
      - SECRET_KEY_BASE=$SECRET_KEY_BASE
      - APP_NAME=realtime

      - DB_HOST=supabase${1:+_$1}_db
      - DB_PORT=5432
      - DB_USER=supabase_admin
      - DB_PASSWORD=$Senha_Postgres
      - DB_NAME=postgres
      - DB_AFTER_CONNECT_QUERY=SET search_path TO _realtime
      - DB_ENC_KEY=supabaserealtime

      - ERL_AFLAGS=-proto_dist inet_tcp
      - DNS_NODES="''"
      - RLIMIT_NOFILE=10000

    ##  Configuracao do Ambiente
      - SEED_SELF_HOST=true
      - RUN_JANITOR=true
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_storage:
    image: supabase/storage-api:v1.29.0

    volumes:
      #- /root/supabase${1:+_$1}/docker/volumes/storage:/var/lib/storage:z
      - supabase${1:+_$1}_storage:/var/lib/storage:z
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - ANON_KEY=$ANON_KEY
      - SERVICE_KEY=$SERVICE_KEY
      - POSTGREST_URL=http://supabase${1:+_$1}_rest:3000
      - PGRST_JWT_SECRET=$JWT_Key
      - DATABASE_URL=postgres://supabase_storage_admin:$Senha_Postgres@supabase${1:+_$1}_db:5432/postgres

      - REQUEST_ALLOW_X_FORWARDED_PATH=true
      - FILE_SIZE_LIMIT=52428800
      - STORAGE_BACKEND=file ## file ou s3
      - GLOBAL_S3_BUCKET=supabase${1:+-$1} ## Nome da bucket
      #- GLOBAL_S3_ENDPOINT=https://s3.dominio.com ## URL S3 do MinIO
      #- GLOBAL_S3_PROTOCOL=https
      #- GLOBAL_S3_FORCE_PATH_STYLE=true
      #- AWS_ACCESS_KEY_ID=ACCESS_KEY ## Access Key
      #- AWS_SECRET_ACCESS_KEY=SECRET_KEY ## Secret Key
      #- AWS_DEFAULT_REGION=eu-south ## Regiao MinIO
      - FILE_STORAGE_BACKEND_PATH=/var/lib/storage

      - REGION=eu-south
      - TENANT_ID=stub

      - ENABLE_IMAGE_TRANSFORMATION=true
      - IMGPROXY_URL=http://supabase${1:+_$1}_imgproxy:5001

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_imgproxy:
    image: darthsim/imgproxy:v3.8.0

    volumes:
      - /root/supabase${1:+_$1}/docker/volumes/storage:/var/lib/storage:z

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracao do IMGPROXY
      - IMGPROXY_BIND=:5001
      - IMGPROXY_LOCAL_FILESYSTEM_ROOT=/
      - IMGPROXY_USE_ETAG=true
      - IMGPROXY_ENABLE_WEBP_DETECTION=true
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_meta:
    image: supabase/postgres-meta:v0.93.1

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - PG_META_PORT=8080
      - PG_META_DB_HOST=supabase${1:+_$1}_db
      - PG_META_DB_PORT=5432
      - PG_META_DB_NAME=postgres
      - PG_META_DB_USER=supabase_admin
      - PG_META_DB_PASSWORD=$Senha_Postgres
      - CRYPTO_KEY=$PG_META_CRYPTO_KEY
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_functions:
    image: supabase/edge-runtime:v1.69.23
    command:
      [
        "start",
        "--main-service",
        "/home/deno/functions/main"
      ]

    volumes:
      - /root/supabase${1:+_$1}/docker/volumes/functions:/home/deno/functions:Z
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - VERIFY_JWT=false
      - JWT_SECRET=$JWT_Key
    
      - SUPABASE_URL=http://supabase${1:+_$1}_kong:8000
      - SUPABASE_ANON_KEY=$ANON_KEY
      - SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
    
      - SUPABASE_DB_URL=postgresql://postgres:$Senha_Postgres@supabase${1:+_$1}_db:5432/postgres

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_analytics:
    image: supabase/logflare:1.22.6

    networks:
      - $nome_rede_interna ## Nome da rede interna
    #ports:
    #  - 4000:4000

    environment:
      - DB_USERNAME=supabase_admin
      - DB_DATABASE=_supabase
      - DB_HOSTNAME=supabase${1:+_$1}_db
      - DB_PORT=5432
      - DB_PASSWORD=$Senha_Postgres
      - DB_SCHEMA=_analytics
      - POSTGRES_BACKEND_URL=postgresql://supabase_admin:$Senha_Postgres@supabase${1:+_$1}_db:5432/_supabase
      - POSTGRES_BACKEND_SCHEMA=_analytics
      - LOGFLARE_FEATURE_FLAG_OVERRIDE=multibackend=true

    ##  Configuracao do Logflare
      - LOGFLARE_NODE_HOST=127.0.0.1
      - LOGFLARE_PUBLIC_ACCESS_TOKEN=$Logflare_key_public
      - LOGFLARE_PRIVATE_ACCESS_TOKEN=$Logflare_key
      - LOGFLARE_SINGLE_TENANT=true
      - LOGFLARE_SUPABASE_MODE=true
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_db:
    image: supabase/postgres:15.8.1.085
    command:
      [
        "postgres",
        "-c",
        "config_file=/etc/postgresql/postgresql.conf",
        "-c",
        "log_min_messages=fatal"
      ]

    volumes:
      - /root/supabase${1:+_$1}/docker/volumes/db/realtime.sql:/docker-entrypoint-initdb.d/migrations/99-realtime.sql:Z
      - /root/supabase${1:+_$1}/docker/volumes/db/webhooks.sql:/docker-entrypoint-initdb.d/init-scripts/98-webhooks.sql:Z
      - /root/supabase${1:+_$1}/docker/volumes/db/roles.sql:/docker-entrypoint-initdb.d/init-scripts/99-roles.sql:Z
      - /root/supabase${1:+_$1}/docker/volumes/db/jwt.sql:/docker-entrypoint-initdb.d/init-scripts/99-jwt.sql:Z
      - /root/supabase${1:+_$1}/docker/volumes/db/data:/var/lib/postgresql/data:Z
      - /root/supabase${1:+_$1}/docker/volumes/db/_supabase.sql:/docker-entrypoint-initdb.d/migrations/97-_supabase.sql:Z
      - /root/supabase${1:+_$1}/docker/volumes/db/logs.sql:/docker-entrypoint-initdb.d/migrations/99-logs.sql:Z
      - /root/supabase${1:+_$1}/docker/volumes/db/pooler.sql:/docker-entrypoint-initdb.d/migrations/99-pooler.sql:Z
      - supabase${1:+_$1}_db_config:/etc/postgresql-custom

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - POSTGRES_HOST=/var/run/postgresql
      - PGPORT=5432
      - POSTGRES_PORT=5432
      - PGPASSWORD=$Senha_Postgres
      - POSTGRES_PASSWORD=$Senha_Postgres
      - POSTGRES_DB=postgres
      - PGDATABASE=postgres

      - JWT_SECRET=$JWT_Key
      - JWT_EXP=31536000

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_vector:
    image: timberio/vector:0.28.1-alpine
    command:
      [
        "--config",
        "/etc/vector/vector.yml"
      ]

    volumes:
    - /root/supabase${1:+_$1}/docker/volumes/logs/vector.yml:/etc/vector/vector.yml:ro,z
    - /var/run/docker.sock:/var/run/docker.sock:ro,z
    security_opt:
      - "label=disable"
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracao do Logflare
      - LOGFLARE_PUBLIC_ACCESS_TOKEN=$Logflare_key_public

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  supabase${1:+_$1}_supavisor:
    image: supabase/supavisor:2.7.4
    command:
      [
        "/bin/sh",
        "-c",
        "/app/bin/migrate && /app/bin/supavisor eval \"\$\$(cat /etc/pooler/pooler.exs)\" && /app/bin/server"
      ]

    volumes:
      - /root/supabase${1:+_$1}/docker/volumes/pooler/pooler.exs:/etc/pooler/pooler.exs:ro,z

    networks:
      - $nome_rede_interna ## Nome da rede interna
    #ports:
    #  - 5432:5432
    #  - 6543:6543

    environment:
      - POSTGRES_PORT=5432
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=$Senha_Postgres
      - DATABASE_URL=ecto://supabase_admin:$Senha_Postgres@supabase${1:+_$1}_db:5432/_supabase
      - CLUSTER_POSTGRES=true

      - SECRET_KEY_BASE=$SECRET_KEY_BASE
      - VAULT_ENC_KEY=$VAULT_ENC_KEY

      - API_JWT_SECRET=$JWT_Key
      - METRICS_JWT_SECRET=$JWT_Key

      - REGION=local

    ##  Configuracao de Erlang
      - ERL_AFLAGS=-proto_dist inet_tcp

    ##  Configuracao do Pooler
      - POOLER_TENANT_ID=1
      - POOLER_DEFAULT_POOL_SIZE=20
      - POOLER_MAX_CLIENT_CONN=100
      - POOLER_POOL_MODE=transaction
      - DB_POOL_SIZE=5

    ##  Configuracao de Porta
      - PORT=4000

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

volumes:
  supabase${1:+_$1}_db_config:
    external: true
    name: supabase${1:+_$1}_db_config
  supabase${1:+_$1}_storage:
    external: true
    name: supabase${1:+_$1}_storage

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do supabase"
fi
STACK_NAME="supabase${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c supabase.yaml supabase > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do supabase"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull supabase/studio:2025.11.10-sha-5291fe3 kong:2.8.1 supabase/gotrue:v2.182.1 postgrest/postgrest:v13.0.7 supabase/realtime:v2.63.0 supabase/storage-api:v1.29.0 darthsim/imgproxy:v3.8.0 supabase/postgres-meta:v0.93.1 supabase/edge-runtime:v1.69.23 supabase/logflare:1.22.6 supabase/postgres:15.8.1.085 timberio/vector:0.28.1-alpine supabase/supavisor:2.7.4 

## Usa o servico wait_stack "supabase" para verificar se o servico esta online
wait_stack supabase${1:+_$1}_supabase${1:+_$1}_db supabase${1:+_$1}_supabase${1:+_$1}_vector supabase${1:+_$1}_supabase${1:+_$1}_analytics supabase${1:+_$1}_supabase${1:+_$1}_meta supabase${1:+_$1}_supabase${1:+_$1}_rest supabase${1:+_$1}_supabase${1:+_$1}_auth supabase${1:+_$1}_supabase${1:+_$1}_realtime supabase${1:+_$1}_supabase${1:+_$1}_storage supabase${1:+_$1}_supabase${1:+_$1}_imgproxy supabase${1:+_$1}_supabase${1:+_$1}_kong supabase${1:+_$1}_supabase${1:+_$1}_functions supabase${1:+_$1}_supabase${1:+_$1}_supavisor supabase${1:+_$1}_supabase${1:+_$1}_studio 

cd dados_vps

cat > dados_supabase${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ SUPABASE ]

Dominio do Supabase: https://$url_supabase

Usuario: $user_supabase

Senha: $pass_supabase

JWT Key: $JWT_Key

Anon Key: $ANON_KEY

Service Key: $SERVICE_KEY

MCP URL: https://$url_supabase/mcp/Felsen Linux Setup/$HASH

Host do Postgres: supabase${1:+_$1}_db

Port: 5432

User: postgres

Pass: $Senha_Postgres
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
echo -e "\e[32m[ SUPABASE ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_supabase\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_supabase\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_supabase\e[0m"
echo ""

echo -e "\e[33mAnon key:\e[97m $ANON_KEY\e[0m"
echo ""

echo -e "\e[33mService key:\e[97m $SERVICE_KEY\e[0m"
echo ""

echo -e "\e[33mMCP URL:\e[97m https://$url_supabase/mcp/Felsen Linux Setup/$HASH\e[0m"
echo ""

echo -e "\e[33mHost do Postgres:\e[97m supabase${1:+_$1}_db\e[0m"
echo ""

echo -e "\e[33mPort:\e[97m 5432\e[0m"
echo ""

echo -e "\e[33mUser:\e[97m postgres\e[0m"
echo ""

echo -e "\e[33mPass:\e[97m $Senha_Postgres\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}
