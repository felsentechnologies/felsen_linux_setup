#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_langfuse() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_langfuse

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Langfuse (ex: langfuse.example.com): \e[0m" && read -r url_langfuse
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_langfuse
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ARQUIVO_CLICKHOUSE="/root/dados_vps/dados_clickhouse"

    API_CLICKHOUSE=$(grep "API do clickhouse:" "$ARQUIVO_CLICKHOUSE" | cut -d ":" -f2- | xargs)
    USUARIO_CLICKHOUSE=$(grep "Usuario:" "$ARQUIVO_CLICKHOUSE" | cut -d ":" -f2- | xargs)
    SENHA_CLICKHOUSE=$(grep "Senha:" "$ARQUIVO_CLICKHOUSE" | cut -d ":" -f2- | xargs)
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o Langfuse:\e[97m $url_langfuse\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mDominio do ClickHouse:\e[97m $API_CLICKHOUSE\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mUsuario do ClickHouse:\e[97m $USUARIO_CLICKHOUSE\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mSenha do ClickHouse:\e[97m $SENHA_CLICKHOUSE\e[0m"
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
        nome_langfuse

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO LANGFUSE \e[33m[1/6]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/6]\e[0m"
echo ""
sleep 1

## Ja sabe ne ksk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "langfuse${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "langfuse${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BANCO NO CLICKHOUSE \e[33m[3/6]\e[0m"
echo ""
sleep 1

docker exec -it "$(docker ps --filter 'name=clickhouse' -q)" clickhouse-client -q "CREATE DATABASE langfuse${1:+_$1};" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/1 - [ OK ] - Banco langfuse${1:+_$1} criado"
else
    echo "1/1 - [ OFF ] - Erro ao criar Banco langfuse${1:+_$1}"
fi

echo ""

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[4/6]\e[0m"
echo ""
sleep 1

pegar_senha_minio
minio.bucket langfuse${1:+-$1} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
else
    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
    echo ""
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO LANGFUSE \e[33m[5/6]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria 64caracteres
key_encryption=$(openssl rand -hex 32)

## Criando key Aleatoria 64caracteres
key_secret=$(openssl rand -hex 32)

## Criando key Aleatoria 32caracteres
key_salt=$(openssl rand -hex 32)

## Criando a stack langfuse.yaml
cat > langfuse${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  langfuse${1:+_$1}_app:
    image: langfuse/langfuse:latest

    networks:
     - $nome_rede_interna ## Rede interna

    environment:
    ##  Url do Langfuse
      - NEXTAUTH_URL=https://$url_langfuse

    ##  Desativar novas incricoes
      - NEXT_PUBLIC_SIGN_UP_DISABLED=false

    ## " Secrets Key
      - ENCRYPTION_KEY=$key_encryption
      - NEXTAUTH_SECRET=$key_secret
      - SALT=$key_salt

    ## -"i Dados Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/langfuse${1:+_$1}
      
    ## -"i Dados do ClickHouse
      - CLICKHOUSE_MIGRATION_URL=clickhouse://clickhouse:9000
      - CLICKHOUSE_URL=$API_CLICKHOUSE
      - CLICKHOUSE_USER=$USUARIO_CLICKHOUSE
      - CLICKHOUSE_PASSWORD=$SENHA_CLICKHOUSE
      - CLICKHOUSE_CLUSTER_ENABLED=false
      - CLICKHOUSE_DB=langfuse${1:+_$1}

    ## " Dados Redis
      - REDIS_CONNECTION_STRING=redis://langfuse${1:+_$1}_redis:6379

    ## -"i Dados do S3 - Eventos
      - LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT=https://$url_s3
      - LANGFUSE_S3_EVENT_UPLOAD_BUCKET=langfuse${1:+-$1}
      - LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID=$S3_ACCESS_KEY
      - LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY=$S3_SECRET_KEY
      - LANGFUSE_S3_EVENT_UPLOAD_REGION=auto
      - LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE=true
      - LANGFUSE_S3_EVENT_UPLOAD_PREFIX=events/

    ## -"i Dados do S3 - Medias
      - LANGFUSE_S3_MEDIA_UPLOAD_ENDPOINT=https://$url_s3
      - LANGFUSE_S3_MEDIA_UPLOAD_BUCKET=langfuse${1:+-$1}
      - LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID=$S3_ACCESS_KEY
      - LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY=$S3_SECRET_KEY
      - LANGFUSE_S3_MEDIA_UPLOAD_REGION=auto
      - LANGFUSE_S3_MEDIA_UPLOAD_FORCE_PATH_STYLE=true
      - LANGFUSE_S3_MEDIA_UPLOAD_PREFIX=media/

    ##  Ativar rastreamento
      - TELEMETRY_ENABLED=false

    ## " Features experimentais
      - LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES=false

    ## " Node
      - NODE_ENV=production

    deploy:
      mode: replicated
      replicas: 1
      placement:
          constraints:
            - node.role == manager
      resources:
          limits:
            cpus: '1'
            memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.langfuse${1:+_$1}.rule=Host(\`$url_langfuse\`)
        - traefik.http.routers.langfuse${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.langfuse${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.langfuse${1:+_$1}.service=langfuse${1:+_$1}
        - traefik.http.services.langfuse${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.services.langfuse${1:+_$1}.loadbalancer.server.port=3000

## --------------------------- FELSEN --------------------------- ##

  langfuse${1:+_$1}_worker:
    image: langfuse/langfuse-worker:latest

    networks:
     - $nome_rede_interna ## Rede interna

    environment:
    ##  Url do Langfuse
      - NEXTAUTH_URL=https://$url_langfuse

    ##  Desativar novas incricoes
      - NEXT_PUBLIC_SIGN_UP_DISABLED=false

    ## " Secrets Key
      - ENCRYPTION_KEY=$key_encryption
      - NEXTAUTH_SECRET=$key_secret
      - SALT=$key_salt

    ## -"i Dados Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/langfuse${1:+_$1}
      
    ## -"i Dados do ClickHouse
      - CLICKHOUSE_MIGRATION_URL=clickhouse://clickhouse:9000
      - CLICKHOUSE_URL=$API_CLICKHOUSE
      - CLICKHOUSE_USER=$USUARIO_CLICKHOUSE
      - CLICKHOUSE_PASSWORD=$SENHA_CLICKHOUSE
      - CLICKHOUSE_CLUSTER_ENABLED=false
      - CLICKHOUSE_DB=langfuse${1:+_$1}

    ## " Dados Redis
      - REDIS_CONNECTION_STRING=redis://langfuse${1:+_$1}_redis:6379

    ## -"i Dados do S3 - Eventos
      - LANGFUSE_S3_EVENT_UPLOAD_ENDPOINT=https://$url_s3
      - LANGFUSE_S3_EVENT_UPLOAD_BUCKET=langfuse${1:+-$1}
      - LANGFUSE_S3_EVENT_UPLOAD_ACCESS_KEY_ID=$S3_ACCESS_KEY
      - LANGFUSE_S3_EVENT_UPLOAD_SECRET_ACCESS_KEY=$S3_SECRET_KEY
      - LANGFUSE_S3_EVENT_UPLOAD_REGION=auto
      - LANGFUSE_S3_EVENT_UPLOAD_FORCE_PATH_STYLE=true
      - LANGFUSE_S3_EVENT_UPLOAD_PREFIX=events/

    ## -"i Dados do S3 - Medias
      - LANGFUSE_S3_MEDIA_UPLOAD_ENDPOINT=https://$url_s3
      - LANGFUSE_S3_MEDIA_UPLOAD_BUCKET=langfuse${1:+-$1}
      - LANGFUSE_S3_MEDIA_UPLOAD_ACCESS_KEY_ID=$S3_ACCESS_KEY
      - LANGFUSE_S3_MEDIA_UPLOAD_SECRET_ACCESS_KEY=$S3_SECRET_KEY
      - LANGFUSE_S3_MEDIA_UPLOAD_REGION=auto
      - LANGFUSE_S3_MEDIA_UPLOAD_FORCE_PATH_STYLE=true
      - LANGFUSE_S3_MEDIA_UPLOAD_PREFIX=media/

    ##  Ativar rastreamento
      - TELEMETRY_ENABLED=false

    ## " Features experimentais
      - LANGFUSE_ENABLE_EXPERIMENTAL_FEATURES=false

    ## " Node
      - NODE_ENV=production

    deploy:
      mode: replicated
      replicas: 1
      placement:
          constraints:
            - node.role == manager
      resources:
          limits:
            cpus: '1'
            memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  langfuse${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - langfuse${1:+_$1}_redis:/data

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
   langfuse${1:+_$1}_redis:
    external: true
    name: langfuse${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Rede interna
    external: true
    name: $nome_rede_interna ## Rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do langfuse"
fi
STACK_NAME="langfuse${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c langfuse.yaml langfuse > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do langfuse"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[6/6]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest langfuse/langfuse-worker:latest langfuse/langfuse:latest

## Usa o servico wait_langfuse para verificar se o servico esta online
wait_stack langfuse${1:+_$1}_langfuse${1:+_$1}_redis langfuse${1:+_$1}_langfuse${1:+_$1}_worker langfuse${1:+_$1}_langfuse${1:+_$1}_app


cd dados_vps

cat > dados_langfuse${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ LANGFUSE ]

Dominio do Langfuse: https://$url_langfuse

Usuario: Precisa criar no primeiro acesso do langfuse

Senha: Precisa criar no primeiro acesso do langfuse

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
echo -e "\e[32m[ LANGFUSE ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_langfuse\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Langfuse\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Langfuse\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   ##################### ###### #######  ###### ################
## a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a--     a-a-a-'   a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a--  
## a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-     a-a-a-'   a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  
## a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-     a-a-a-a-a-a-a-a-a-a-a-   a-a-a-   a-a-a-  a-a-a-a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

