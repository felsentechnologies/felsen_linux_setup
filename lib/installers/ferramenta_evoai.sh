#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_evoai() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_evoai

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/9\e[0m"
    echo -en "\e[33mDigite o Dominio para o painel da EvoAI (ex: evoai.example.com): \e[0m" && read -r url_evoai_front
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 2/9\e[0m"
    echo -en "\e[33mDigite o Dominio para a API da EvoAI (ex: evoapi.example.com): \e[0m" && read -r url_evoai_api
    echo ""

    ##Pergunta o Usuario para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/9\e[0m"
    echo -en "\e[33mDigite um email para o usuario admin (ex: contato@example.com): \e[0m" && read -r email_evoai
    echo ""
    
    ##Pergunta a Senha para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/9\e[0m"
    echo -e "$amarelo--> Minimo 8 caracteres. Use Letras MAIUSCULAS e minusculas, numero e um caractere especial @ ou _"
    echo -e "$amarelo--> Evite os caracteres especiais: \!#$"
    echo -en "\e[33mDigite uma senha para o usuario (ex: @Senha123_): \e[0m" && read -r pass_evoai
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 5/9\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r smtp_email_evoai
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 6/9\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r smtp_user_evoai
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 7/9\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r smtp_pass_evoai
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 8/9\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_host_evoai
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 9/9\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r smtp_port_evoai
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$smtp_port_evoai" -eq 465 ]; then
    SMTP_USE_TLS=false
    SMTP_USE_SSL=true
    else
    SMTP_USE_TLS=true
    SMTP_USE_SSL=false
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_evoai
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do painel:\e[97m $url_evoai_front\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mDominio da api:\e[97m $url_evoai_api\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mEmail do usuario:\e[97m $email_evoai\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do usuario:\e[97m $pass_evoai\e[0m"
    echo ""

    ## Informacao sobre Email SMTP
    echo -e "\e[33mEmail SMTP:\e[97m $smtp_email_evoai\e[0m"
    echo ""

    ## Informacao sobre Email SMTP
    echo -e "\e[33mUser SMTP:\e[97m $smtp_user_evoai\e[0m"
    echo ""    
    
    ## Informacao sobre Senha SMTP
    echo -e "\e[33mSenha SMTP:\e[97m $smtp_pass_evoai\e[0m"
    echo ""
    
    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP:\e[97m $smtp_host_evoai\e[0m"
    echo ""
    
    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP:\e[97m $smtp_port_evoai\e[0m"
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
        nome_evoai

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DA EVO AI \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Literalmente nada, apenas um espaco vazio caso precisar de adicionar alguma coisa
## Antes..
## E claro, para aparecer a mensagem do passo..

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres Instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "evoai${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "evoai${1:+_$1}"
fi

pegar_senha_postgres > /dev/null 2>&1

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO A EVO AI \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Aqui de fato vamos iniciar a instalacao da Evolution API

## Criando uma Global Key Aleatoria
EVO_AI_ENCRYPTION_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")
EVO_AI_JWT_SECRET_KEY=$(openssl rand -base64 32)

## Criando a stack evoai.yaml
cat > evoai${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  evoai${1:+_$1}_api:
    image: evoapicloud/evo-ai:latest ## Versao da imagem

    volumes:
      - evoai${1:+_$1}_logs:/app/logs
      - evoai${1:+_$1}_static:/app/static
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Informacoes da API
      - API_URL=https://$url_evoai_api

    ##  Informacoes do Front
      - APP_URL=https://$url_evoai_front
      
    ##  Dados do Admin
      - ADMIN_EMAIL=$email_evoai
      - ADMIN_INITIAL_PASSWORD=$pass_evoai

    ##  Configuracao de SMTP
      - EMAIL_PROVIDER=smtp
      - SMTP_FROM=$smtp_email_evoai
      - SMTP_USER=$smtp_user_evoai
      - SMTP_PASSWORD=$smtp_pass_evoai
      - SMTP_HOST=$smtp_host_evoai
      - SMTP_PORT=$smtp_port_evoai
      - SMTP_USE_TLS=$SMTP_USE_TLS
      - SMTP_USE_SSL=$SMTP_USE_SSL

    ## i Configuracao do Postgres
      - POSTGRES_CONNECTION_STRING=postgresql://postgres:$senha_postgres@postgres:5432/evoai${1:+_$1}

    ##  Configuracao do Redis
      - REDIS_HOST=evoai${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_DB=9
      - REDIS_KEY_PREFIX=a2a_
      - REDIS_SSL=false
      - REDIS_TTL=3600
      - TOOLS_CACHE_TTL=3600

    ## " EncriptaAAo e JWT
      - ENCRYPTION_KEY=$EVO_AI_ENCRYPTION_KEY
      - JWT_SECRET_KEY=$EVO_AI_JWT_SECRET_KEY
      - JWT_ALGORITHM=HS256
      - JWT_EXPIRATION_TIME=3600

    ##  Logs
      - LOG_LEVEL=INFO
      - LOG_DIR=logs
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.evoai${1:+_$1}_api.rule=Host(\`$url_evoai_api\`) ## Url da Evolution API
        - traefik.http.routers.evoai${1:+_$1}_api.entrypoints=websecure
        - traefik.http.routers.evoai${1:+_$1}_api.priority=1
        - traefik.http.routers.evoai${1:+_$1}_api.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evoai${1:+_$1}_api.service=evoai${1:+_$1}_api
        - traefik.http.services.evoai${1:+_$1}_api.loadbalancer.server.port=8000
        - traefik.http.services.evoai${1:+_$1}_api.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  evoai${1:+_$1}_frontend:
    image: evoapicloud/evo-ai-frontend:latest ## Versao da imagem
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - NEXT_PUBLIC_API_URL=https://$url_evoai_api
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.evoai${1:+_$1}_frontend.rule=Host(\`$url_evoai_front\`) ## Url da Evolution API
        - traefik.http.routers.evoai${1:+_$1}_frontend.entrypoints=websecure
        - traefik.http.routers.evoai${1:+_$1}_frontend.priority=1
        - traefik.http.routers.evoai${1:+_$1}_frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evoai${1:+_$1}_frontend.service=evoai${1:+_$1}_frontend
        - traefik.http.services.evoai${1:+_$1}_frontend.loadbalancer.server.port=3000
        - traefik.http.services.evoai${1:+_$1}_frontend.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  evoai${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - evoai${1:+_$1}_redis:/data

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
  evoai${1:+_$1}_logs:
    external: true
    name: evoai${1:+_$1}_logs
  evoai${1:+_$1}_static:
    external: true
    name: evoai${1:+_$1}_static
  evoai${1:+_$1}_redis:
    external: true
    name: evoai${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna

__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da Evolution API"
fi
STACK_NAME="evoai${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c evoai.yaml evoai > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack da Evolution API"
#fi

sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest evoapicloud/evo-ai:latest evoapicloud/evo-ai-frontend:latest

## Usa o servico wait_evoai para verificar se o servico esta online
wait_stack evoai${1:+_$1}_evoai${1:+_$1}_redis evoai${1:+_$1}_evoai${1:+_$1}_api evoai${1:+_$1}_evoai${1:+_$1}_frontend


cd dados_vps

cat > dados_evoai${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ EVO AI ]

Painel: https://$url_evoai_front

API: https://$url_evoai_api

Email Admin: $email_evoai

Senha Admin: $pass_evoai
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
echo -e "\e[32m[ EVO AI ]\e[0m"
echo ""

echo -e "\e[97mLink do Painel:\e[33m https://$url_evoai_front\e[0m"
echo ""

echo -e "\e[97mAPI URL:\e[33m https://$url_evoai_api\e[0m"
echo ""

echo -e "\e[97mEmail Admin:\e[33m $email_evoai\e[0m"
echo ""

echo -e "\e[97mSenha Admin:\e[33m $pass_evoai\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###  ##############   ### ##########      #######  ###### ###  ###
## a-a-a-' a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-'     a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-' a-a-a-"a-
## a-a-a-a-a-a-"a- a-a-a-a-a-a--   a-a-a-a-a-a-"a- a-a-a-'     a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-"a- 
## a-a-a-"a-a-a-a-- a-a-a-"a-a-a-    a-a-a-a-"a-  a-a-a-'     a-a-a-'     a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-- 
## a-a-a-'  a-a-a--a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'  a-a-a--
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a-   a-a-a-    a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-  a-a-a-

