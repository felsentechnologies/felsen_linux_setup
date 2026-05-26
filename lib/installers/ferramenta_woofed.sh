#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_woofed() {

## Verifica os recursos
recursos 1 1 && continue || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_woofedcrm

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos    
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para o WoofedCRM (ex: woofedcrm.example.com): \e[0m" && read -r url_woofed
    echo ""

    ## Pergunta o nome do Usuario do Motor
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -e "$amarelo--> Evite os caracteres especiais: @\!#$ e/ou espaco"
    echo -en "\e[33mDigite o User do MOTOR (ex: Felsen): \e[0m" && read -r email_admin_woofed
    echo ""

    ## Pergunta o nome do Senha do Motor
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "$amarelo--> Evite os caracteres especiais: \!#$ e/ou espaco"
    echo -en "\e[33mDigite a Senha do MOTOR (ex: @Senha123_): \e[0m" && read -r senha_email_woofed
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_woofedcrm
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre o dominio
    echo -e "\e[33mDominio:\e[97m $url_woofed\e[0m"
    echo ""

    ## Informacao sobre o usuario
    echo -e "\e[33mUser MOTOR:\e[97m $email_admin_woofed\e[0m"
    echo ""

    ## Informacao sobre a senha
    echo -e "\e[33mSenha MOTOR:\e[97m $senha_email_woofed\e[0m"
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
        nome_woofedcrm

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO WOOFED CRM \e[33m[1/6]\e[0m"
echo ""
sleep 1

dados

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES VECTOR \e[33m[2/6]\e[0m"
echo ""
sleep 1

verificar_container_pgvector
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - PgVector ja instalado"
    pegar_senha_pgvector > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do PgVector"
    criar_banco_pgvector_da_stack "woofedcrm${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_pgvector
    pegar_senha_pgvector > /dev/null 2>&1
    criar_banco_pgvector_da_stack "woofedcrm${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO WOOFED CRM \e[33m[3/6]\e[0m"
echo ""
sleep 1

## Criando uma Encryption Key Aleatoria
encryption_key_woofed=$(openssl rand -hex 32)

# Verifica se o arquivo evolution.yaml existe
if [ -f "/root/evolution_v1.yaml" ]; then
    # Extrai os valores do arquivo evolution.yaml e formata no estilo desejado
    EVOLUTION_API_ENDPOINT="- EVOLUTION_API_ENDPOINT=$(grep -oP '(?<=- SERVER_URL=)[^#]*' /root/evolution.yaml | sed 's/ //g')"
    EVOLUTION_API_ENDPOINT_TOKEN="- EVOLUTION_API_ENDPOINT_TOKEN=$(grep -oP '(?<=- AUTHENTICATION_API_KEY=)[^#]*' /root/evolution.yaml | sed 's/ //g')"
else
    # Define os valores padrao se o arquivo nao existir
    EVOLUTION_API_ENDPOINT="#- EVOLUTION_API_ENDPOINT="
    EVOLUTION_API_ENDPOINT_TOKEN="#- EVOLUTION_API_ENDPOINT_TOKEN="
fi

## Criando a stack woofedcrm.yaml
cat > woofedcrm${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  woofedcrm${1:+_$1}_web:
    image: douglara/woofedcrm:latest
    command: bash -c "bundle exec rails db:prepare && bundle exec puma -C config/puma.rb"

    volumes:
      - woofedcrm${1:+_$1}_data:/app/storage

    networks:
      - $nome_rede_interna

    environment:
    ##  Url WoofedCRM
      - FRONTEND_URL=https://$url_woofed
      - SECRET_KEY_BASE=$encryption_key_woofed

    ## -i Idioma
      - LANGUAGE=pt-BR

    ##  Permitir/Bloquear novas Inscricoes
      - ENABLE_USER_SIGNUP=true

    ##  Credenciais Motor
      - MOTOR_AUTH_USERNAME=$email_admin_woofed
      - MOTOR_AUTH_PASSWORD=$senha_email_woofed

    ##  Endpoints Evolution API
      $EVOLUTION_API_ENDPOINT ## BaseUrl
      $EVOLUTION_API_ENDPOINT_TOKEN ## Global Api Key

    ##  Timezone
      - DEFAULT_TIMEZONE=Brasilia

    ##  Dados OpenAI
      #- OPENAI_API_KEY=

    ##  Dados PgVector
      - DATABASE_URL=postgres://postgres:$senha_pgvector@pgvector:5432/woofedcrm${1:+_$1}

    ## " Dados Redis
      - REDIS_URL=redis://redis:6379/0

    ##  Dados Storage
      - ACTIVE_STORAGE_SERVICE=local

    ##  Modo de Producao
      - RAILS_ENV=production
      - RACK_ENV=production
      - NODE_ENV=production
      - RAILS_LOG_LEVEL=debug

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
        - traefik.http.routers.woofedcrm${1:+_$1}.rule=Host(\`$url_woofed\`)
        - traefik.http.routers.woofedcrm${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.woofedcrm${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.woofedcrm${1:+_$1}.priority=1
        - traefik.http.routers.woofedcrm${1:+_$1}.service=woofedcrm${1:+_$1}
        - traefik.http.services.woofedcrm${1:+_$1}.loadbalancer.server.port=3000 
        - traefik.http.services.woofedcrm${1:+_$1}.loadbalancer.passHostHeader=true 
        - traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https
        - traefik.http.routers.woofedcrm${1:+_$1}.middlewares=sslheader

## --------------------------- FELSEN --------------------------- ##

  woofedcrm${1:+_$1}_sidekiq:
    image: douglara/woofedcrm:latest
    command: bundle exec sidekiq -C config/sidekiq.yml

    volumes:
      - woofedcrm${1:+_$1}_data:/app/storage

    networks:
      - $nome_rede_interna

    environment:
    ##  Url WoofedCRM
      - FRONTEND_URL=https://$url_woofed
      - SECRET_KEY_BASE=$encryption_key_woofed

    ## -i Idioma
      - LANGUAGE=pt-BR

    ##  Permitir/Bloquear novas Inscricoes
      - ENABLE_USER_SIGNUP=true

    ##  Credenciais Motor
      - MOTOR_AUTH_USERNAME=$email_admin_woofed
      - MOTOR_AUTH_PASSWORD=$senha_email_woofed

    ##  Endpoints Evolution API
      $EVOLUTION_API_ENDPOINT ## BaseUrl
      $EVOLUTION_API_ENDPOINT_TOKEN ## Global Api Key

    ##  Timezone
      - DEFAULT_TIMEZONE=Brasilia

    ##  Dados OpenAI
      #- OPENAI_API_KEY=

    ##  Dados PgVector
      - DATABASE_URL=postgres://postgres:$senha_pgvector@pgvector:5432/woofedcrm${1:+_$1}

    ## " Dados Redis
      - REDIS_URL=redis://redis:6379/0

    ##  Dados Storage
      - ACTIVE_STORAGE_SERVICE=local

    ##  Modo de Producao
      - RAILS_ENV=production
      - RACK_ENV=production
      - NODE_ENV=production
      - RAILS_LOG_LEVEL=debug
      
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

  woofedcrm${1:+_$1}_job:
    image: douglara/woofedcrm:latest
    command: bundle exec good_job

    volumes:
      - woofedcrm${1:+_$1}_data:/app/storage

    networks:
      - $nome_rede_interna

    environment:
    ##  Url WoofedCRM
      - FRONTEND_URL=https://$url_woofed
      - SECRET_KEY_BASE=$encryption_key_woofed

    ## -i Idioma
      - LANGUAGE=pt-BR

    ##  Permitir/Bloquear novas Inscricoes
      - ENABLE_USER_SIGNUP=true

    ##  Credenciais Motor
      - MOTOR_AUTH_USERNAME=$email_admin_woofed
      - MOTOR_AUTH_PASSWORD=$senha_email_woofed

    ##  Endpoints Evolution API
      $EVOLUTION_API_ENDPOINT ## BaseUrl
      $EVOLUTION_API_ENDPOINT_TOKEN ## Global Api Key

    ##  Timezone
      - DEFAULT_TIMEZONE=Brasilia

    ##  Dados OpenAI
      #- OPENAI_API_KEY=

    ##  Dados PgVector
      - DATABASE_URL=postgres://postgres:$senha_pgvector@pgvector:5432/woofedcrm${1:+_$1}

    ## " Dados Redis
      - REDIS_URL=redis://redis:6379/0

    ##  Dados Storage
      - ACTIVE_STORAGE_SERVICE=local

    ##  Modo de Producao
      - RAILS_ENV=production
      - RACK_ENV=production
      - NODE_ENV=production
      - RAILS_LOG_LEVEL=debug

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

  woofedcrm${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - woofedcrm${1:+_$1}_redis:/data

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
  woofedcrm${1:+_$1}_data:
    external: true
    name: woofedcrm${1:+_$1}_data
  woofedcrm${1:+_$1}_redis:
    external: true
    name: woofedcrm${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do WoofedCRM"
fi
STACK_NAME="woofedcrm${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c woofedcrm.yaml woofedcrm #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do WoofedCRM"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/6]\e[0m"
wait_30_sec
echo ""
sleep 1

## Baixando imagens:
pull douglara/woofedcrm:latest

## Usa o servico wait_stack "woofedcrm" para verificar se o servico esta online
wait_stack woofedcrm${1:+_$1}_woofedcrm${1:+_$1}_web woofedcrm${1:+_$1}_woofedcrm${1:+_$1}_sidekiq woofedcrm${1:+_$1}_woofedcrm${1:+_$1}_job



## Mensagem de Passo
echo -e "\e[97m- CONFIGURANDO E MIGRANDO BANCO DE DADOS \e[33m[5/6]\e[0m"
echo ""
sleep 1

#MIGRANDO BANCO DE DADOS DO WOOFED CRM
container_name="woofedcrm${1:+_$1}_web"

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

docker exec -it "$CONTAINER_ID" bundle exec rails db:create > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "1/2 - [ OK ] - Executando: bundle exec rails db:create"
else
    echo "1/2- [ OFF ] - Executando: bundle exec rails db:create"
fi
docker exec -it "$CONTAINER_ID" bundle exec rails db:migrate > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "2/2 - [ OK ] - Executando: bundle exec rails db:migrate"
else
    echo "2/2- [ OFF ] - Executando: bundle exec rails db:migrate"
fi
echo ""

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[6/6]\e[0m"
echo ""
sleep 1

## Usa o servico wait_stack "woofedcrm" para verificar se o servico esta online
wait_stack woofedcrm${1:+_$1}_woofedcrm${1:+_$1}_web woofedcrm${1:+_$1}_woofedcrm${1:+_$1}_sidekiq woofedcrm${1:+_$1}_woofedcrm${1:+_$1}_job

cd dados_vps

cat > dados_woofedcrm${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ WOOFED CRM ]

Dominio do WoofedCRM: https://$url_woofed

Email: Precisa criar dentro do WoofedCRM

Senha: Precisa criar dentro do WoofedCRM

Acesso ao Motor: https://$url_woofed/motor_admin

Usuario do Motor: $email_admin_woofed

Senha do Motor: $senha_email_woofed
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
echo -e "\e[32m[ WOOFED CRM ]\e[0m"
echo ""

echo -e "\e[97mDominio:\e[33m https://$url_woofed\e[0m"
echo ""

echo -e "\e[97mEmail:\e[33m Precisa criar dentro do WoofedCRM\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m Precisa criar dentro do WoofedCRM\e[0m"
echo ""

echo -e "\e[97mURL MOTOR:\e[33m https://$url_woofed/motor_admin\e[0m"
echo ""

echo -e "\e[97mUser MOTOR:\e[33m $email_admin_woofed\e[0m"
echo ""

echo -e "\e[97mSenha MOTOR:\e[33m $senha_email_woofed\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ######## ####### ####### ####   ########### ####### ### ##########  ###########
## a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-' a-a-a-"a-a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a--  a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-'     a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a--
## a-a-a-"a-a-a-  a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-- a-a-a-a-a-a-a-a-'
## a-a-a-'     a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a--a-a-a-a-a-a-a-a-'
## a-a-a-      a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-     a-a-a-a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-
                                                                               
