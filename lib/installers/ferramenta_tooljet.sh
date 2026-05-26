#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_tooljet() {

## Verifica os recursos
recursos 2 4 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_tooljet

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para a ToolJet (ex: tooljet.example.com): \e[0m" && read -r url_tooljet
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_tooljet
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_smtp_tooljet
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_smtp_tooljet
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_tooljet
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_tooljet
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_tooljet
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio da ToolJet:\e[97m $url_tooljet\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mEmail SMTP:\e[97m $email_smtp_tooljet\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mUser SMTP:\e[97m $usuario_smtp_tooljet\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha SMTP:\e[97m $senha_smtp_tooljet\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mHost SMTP:\e[97m $host_smtp_tooljet\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_tooljet\e[0m"
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
        nome_tooljet

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DA TOOLJET \e[33m[1/4]\e[0m"
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
    criar_banco_postgres_da_stack "tooljet${1:+_$1}_app"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "tooljet${1:+_$1}_app"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO A TOOLJET \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Aqui de fato vamos iniciar a instalacao da tooljet

## Criando uma Global Key Aleatoria
master_key=$(openssl rand -hex 16)
secret_key=$(openssl rand -hex 16)
jwt_key=$(openssl rand -hex 16)

## Criando a stack tooljet.yaml
cat > tooljet${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  tooljet${1:+_$1}_app:
    image: tooljet/tooljet:ee-lts-latest
    command: npm run start:prod

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracao basica
      - TOOLJET_HOST=https://$url_tooljet
      - SERVE_CLIENT=true
      - LANGUAGE=pt
      - PORT=80

    ##  Desativar novas inscricoes
      - DISABLE_SIGNUPS=false

    ## a" Ativar perguntas no Onboarding
      - ENABLE_ONBOARDING_QUESTIONS_FOR_ALL_SIGN_UPS=true

    ## " Chaves de seguranAa
      - LOCKBOX_MASTER_KEY=$master_key
      - SECRET_KEY_BASE=$secret_key

    ##  Configuracao do banco de dados principal
      - DATABASE_URL=postgres://postgres:$senha_postgres@postgres:5432/tooljet${1:+_$1}_app?sslmode=disable

    ## -i Configuracao do banco interno do ToolJet
      - ENABLE_TOOLJET_DB=true
      - TOOLJET_DB=tooljet${1:+_$1}
      - TOOLJET_DB_USER=postgres
      - TOOLJET_DB_HOST=postgres
      - TOOLJET_DB_PASS=$senha_postgres

    ##  Configuracao do PostgREST
      - PGRST_HOST=tooljet_postgrest${1:+_$1}
      - PGRST_JWT_SECRET=$jwt_key

    ##  Configuracao do Redis
      - REDIS_HOST=redis
      - REDIS_PORT=6379

    ##  Configuracoes do Chroma
      - CHROMA_DB_URL=http://tooljet${1:+_$1}_chroma:8000

    ## Configuracao do SMTP
      - DEFAULT_FROM_EMAIL=$email_smtp_tooljet
      - SMTP_USERNAME=$usuario_smtp_tooljet
      - SMTP_PASSWORD=$senha_smtp_tooljet
      - SMTP_DOMAIN=$host_smtp_tooljet
      - SMTP_PORT=$porta_smtp_tooljet

    ##  Features do ToolJet
      - COMMENT_FEATURE_ENABLE=true
      - ENABLE_MULTIPLAYER_EDITING=true
      - ENABLE_MARKETPLACE_FEATURE=true
      - DISABLE_TOOLJET_TELEMETRY=true

    ##  Atualizacoes e expiracao de sessao
      - CHECK_FOR_UPDATES=false
      - USER_SESSION_EXPIRY=120

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M
      labels:
        - traefik.enable=true
        - traefik.http.routers.tooljet${1:+_$1}.rule=Host(\`$url_tooljet\`)
        - traefik.http.services.tooljet${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.tooljet${1:+_$1}.service=tooljet${1:+_$1}
        - traefik.http.routers.tooljet${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.tooljet${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.tooljet${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  tooljet${1:+_$1}_postgrest:
    image: postgrest/postgrest:v12.0.2

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - PGRST_SERVER_PORT=80
      - PGRST_DB_URI=postgres://postgres:$senha_postgres@postgres:5432/tooljet${1:+_$1}_app?sslmode=disable
      - PGRST_DB_SCHEMA=public 
      - PGRST_DB_ANON_ROLE=anon 
      - PGRST_JWT_SECRET=$jwt_key
      - PGRST_JWT_AUD=tooljet${1:+_$1}

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

  tooljet${1:+_$1}_chroma:
    image: chromadb/chroma:latest

    volumes:
      - tooljet_chromadb${1:+_$1}:/chroma

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - CHROMA_HOST_PORT=8000
    
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

  tooljet${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - tooljet${1:+_$1}_redis:/data

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
  tooljet_chromadb${1:+_$1}:
    external: true
    name: tooljet_chromadb${1:+_$1}
  tooljet${1:+_$1}_redis:
    external: true
    name: tooljet${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da TOOLJET"
fi
STACK_NAME="tooljet${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c tooljet.yaml tooljet > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack da tooljet"
#fi

sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest tooljet/tooljet:ee-lts-latest postgrest/postgrest:v12.0.2 chromadb/chroma:latest

## Usa o servico wait_stack "tooljet" para verificar se o servico esta online
wait_stack tooljet${1:+_$1}_tooljet${1:+_$1}_redis tooljet${1:+_$1}_tooljet${1:+_$1}_app tooljet${1:+_$1}_tooljet${1:+_$1}_postgrest tooljet${1:+_$1}_tooljet${1:+_$1}_chroma


cd dados_vps

cat > dados_tooljet${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ TOOLJET ]

Dominio: https://$url_tooljet

Usuario: Precisa de criar no primeiro acesso ao ToolJet

Senha: Precisa de criar no primeiro acesso ao ToolJet
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
echo -e "\e[32m[ TOOLJET ]\e[0m"
echo ""

echo -e "\e[97mDominio:\e[33m https://$url_tooljet\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m Precisa de criar no primeiro acesso ao ToolJet\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m Precisa de criar no primeiro acesso ao ToolJet\e[0m"
echo ""

echo "> Aguarde aproximadamente 5 minutos antes de acessar devido a migracao em andamento."

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ########################### ###     #######   ### #######     ####### ####### ########
## a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-     a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-'  a-a-a-a--    a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a--  
## a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'    a-a-a-"a-a-a-a- a-a-a-'  a-a-a-'a-a-a-"a-a-a-  
## a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-    a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-'     
## a-a-a-a-a-a-a-a-   a-a-a-   a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a-     a-a-a-     a-a-a-a-a-a-a- a-a-a-     
                                                                                      
