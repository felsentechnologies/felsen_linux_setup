#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_activepieces() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_activepieces

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o ActivePieces (ex: activepieces.example.com): \e[0m" && read -r url_activepieces
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_activepieces
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do ActivePieces:\e[97m $url_activepieces\e[0m"
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
        nome_activepieces

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO ACTIVEPIECES \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO ACTIVEPIECES \e[33m[2/4]\e[0m"
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
    criar_banco_postgres_da_stack "activepieces${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "activepieces${1:+_$1}"
fi

echo -e "\e[97m- INSTALANDO ACTIVEPIECES \e[33m[3/4]\e[0m"
echo ""
sleep 1

apikey_activepieces=$(openssl rand -hex 16)
encryptionkey_activepieces=$(openssl rand -hex 16)
jwtsecret_activepieces=$(openssl rand -hex 16)

## Criando a stack activepieces.yaml
cat > activepieces${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  activepieces${1:+_$1}_app:
    image: activepieces/activepieces:latest

    volumes:
      - activepieces${1:+_$1}_cache:/usr/src/app/cache

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Ambiente e URLs
      - AP_ENVIRONMENT=prod
      - AP_FRONTEND_URL=https://$url_activepieces ## Url da Aplicacao
      - AP_TEMPLATES_SOURCE_URL=https://cloud.activepieces.com/api/v1/flow-templates

    ## " SeguranAa e AutenticaAAo
      - AP_API_KEY=$apikey_activepieces
      - AP_ENCRYPTION_KEY=$encryptionkey_activepieces
      - AP_JWT_SECRET=$jwtsecret_activepieces

    ## -"i Banco de Dados (PostgreSQL)
      - AP_POSTGRES_HOST=postgres
      - AP_POSTGRES_PORT=5432
      - AP_POSTGRES_DATABASE=activepieces${1:+_$1}
      - AP_POSTGRES_USERNAME=postgres
      - AP_POSTGRES_PASSWORD=$senha_postgres

    ##  Redis
      - AP_REDIS_HOST=activepieces${1:+_$1}_redis
      - AP_REDIS_PORT=6379
      
    ##  Execucao e Engine
      - AP_ENGINE_EXECUTABLE_PATH=dist/packages/engine/main.js
      - AP_EXECUTION_MODE=UNSANDBOXED
      - AP_FLOW_TIMEOUT_SECONDS=600
      - AP_TRIGGER_DEFAULT_POLL_INTERVAL=5
      - AP_WEBHOOK_TIMEOUT_SECONDS=30

    ##  rastreamento
      - AP_TELEMETRY_ENABLED=false

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
        - traefik.http.routers.activepieces${1:+_$1}.rule=Host(\`$url_activepieces\`) ## Url da Aplicacao
        - traefik.http.services.activepieces${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.activepieces${1:+_$1}.service=activepieces${1:+_$1}
        - traefik.http.routers.activepieces${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.activepieces${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.activepieces${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  activepieces${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - activepieces${1:+_$1}_redis:/data

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
          memory: 2048M

## --------------------------- FELSEN --------------------------- ##

volumes:
  activepieces${1:+_$1}_cache:
    external: true
    name: activepieces${1:+_$1}_cache
  activepieces${1:+_$1}_redis:
    external: true
    name: activepieces${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do ActivePieces"
fi

STACK_NAME="activepieces${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c activepieces.yaml activepieces > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do activepieces"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest activepieces/activepieces:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack activepieces${1:+_$1}_activepieces${1:+_$1}_redis activepieces${1:+_$1}_activepieces${1:+_$1}_app


cd dados_vps

cat > dados_activepieces${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ ACTIVEPIECES ]

Dominio do ActivePieces: https://$url_activepieces

Usuario: Precisa criar no primeiro acesso do ActivePieces

Senha: Precisa criar no primeiro acesso do ActivePieces
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
echo -e "\e[32m[ ACTIVEPIECES ]\e[0m"
echo ""

echo -e "\e[33mDominio do ActivePieces:\e[97m https://$url_activepieces\e[0m"
echo ""

echo -e "\e[33mUsuario do ActivePieces:\e[97m Precisa criar no primeiro acesso do ActivePieces\e[0m"
echo ""

echo -e "\e[33mSenha do ActivePieces:\e[97m Precisa criar no primeiro acesso do ActivePieces\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ###### ###   ###############  ###############   ##################  ###
## a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-' a-a-a-"a-
## a-a-a-a-a-a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-'a-a-a-a-a-a--  a-a-a-"a-a-a-- a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a-a-a-"a- 
## a-a-a-"a-a-a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'   a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-- 
## a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'  a-a-a--
## a-a-a-  a-a-a- a-a-a-a-a-a-a-    a-a-a-   a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-   a-a-a-a-a-a-  a-a-a-

