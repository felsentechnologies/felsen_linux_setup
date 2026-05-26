#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_evolution_go() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_evolution_go

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o Evolution Go (ex: go.example.com): \e[0m" && read -r url_evolution_go
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_evolution_go
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio da Evolution Go:\e[97m $url_evolution_go\e[0m"
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
        nome_evolution_go

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DA EVOLUTION GO \e[33m[1/4]\e[0m"
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
    criar_banco_postgres_da_stack "evolution_go${1:+_$1}_auth"
    criar_banco_postgres_da_stack "evolution_go${1:+_$1}_users"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "evolution_go${1:+_$1}_auth"
    criar_banco_postgres_da_stack "evolution_go${1:+_$1}_users"
fi

pegar_senha_postgres > /dev/null 2>&1

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO A EVOLUTION GO \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Aqui de fato vamos iniciar a instalacao da Evolution API

## Criando uma Global Key Aleatoria
apikeyglobal=$(openssl rand -hex 16)

## Criando a stack evolution.yaml
cat > evolution_go${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  evolution_go${1:+_$1}:
    image: evoapicloud/evolution-go:latest

    volumes:
      - evolution_go${1:+_$1}_data:/app/dbdata
      - evolution_go${1:+_$1}_logs:/app/logs
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      ##  Configuracao do Servidor
      - SERVER_PORT=4000
      - CLIENT_NAME=evolution

      ## " Configuracao de SeguranAa
      - GLOBAL_API_KEY=$apikeyglobal

      ## -"i Configuracao do PostgreSQL
      - POSTGRES_AUTH_DB=postgresql://postgres:$senha_postgres@postgres:5432/evolution_go${1:+_$1}_auth?sslmode=disable
      - POSTGRES_USERS_DB=postgresql://postgres:$senha_postgres@postgres:5432/evolution_go${1:+_$1}_users?sslmode=disable
      - DATABASE_SAVE_MESSAGES=true

      ##  Configuracao de Logs e Debug
      - WADEBUG=INFO
      - LOGTYPE=console
      - LOG_DIRECTORY=/app/logs
      - LOG_MAX_SIZE=100
      - LOG_MAX_BACKUPS=5
      - LOG_MAX_AGE=30
      - LOG_COMPRESS=true

      ##  Configuracao de Conexao
      - CONNECT_ON_STARTUP=false
      - WEBHOOKFILES=true

      ## -i Configuracao do Sistema
      - OS_NAME=Linux

      ##  Configuracao do Conversor de Audio
      #- API_AUDIO_CONVERTER=
      #- API_AUDIO_CONVERTER_KEY=

      ##  Configuracao de Proxy
      #- PROXY_HOST=
      #- PROXY_PORT=
      #- PROXY_USERNAME=
      #- PROXY_PASSWORD=

      ## o Configuracao do RabbitMQ
      #- AMQP_URL=
      #- AMQP_GLOBAL_ENABLED=false
      #- AMQP_GLOBAL_EVENTS=

      ##  Configuracao do NATS
      #- NATS_URL=
      #- NATS_GLOBAL_ENABLED=false

      ##  Configuracao de Eventos
      #- EVENT_IGNORE_GROUP=false
      #- EVENT_IGNORE_STATUS=true

      ## Configuracao do S3
      #- MINIO_ENABLED=false
      #- MINIO_ENDPOINT=
      #- MINIO_ACCESS_KEY=
      #- MINIO_SECRET_KEY=
      #- MINIO_BUCKET=
      #- MINIO_USE_SSL=false

    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.evolution_go${1:+_$1}.rule=Host(\`$url_evolution_go\`)
        - traefik.http.routers.evolution_go${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.evolution_go${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.evolution_go${1:+_$1}.service=evolution_go${1:+_$1}
        - traefik.http.services.evolution_go${1:+_$1}.loadbalancer.server.port=4000
        - traefik.http.services.evolution_go${1:+_$1}.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  evolution_go${1:+_$1}_data:
    external: true
    name: evolution_go${1:+_$1}_data
  evolution_go${1:+_$1}_logs:
    external: true
    name: evolution_go${1:+_$1}_logs

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da Evolution Go"
fi
STACK_NAME="evolution_go${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c evolution.yaml evolution > /dev/null 2>&1

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
pull evoapicloud/evolution-go:latest

## Usa o servico wait_evolution para verificar se o servico esta online
wait_stack evolution_go${1:+_$1}_evolution_go${1:+_$1}


cd dados_vps

cat > dados_evolution_go${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ EVOLUTION GO ]

Dominio da Evolution Go: https://$url_evolution_go

Global API Key: $apikeyglobal
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
echo -e "\e[32m[ EVOLUTION GO ]\e[0m"
echo ""

echo -e "\e[97mManager da Evolution Go:\e[33m https://$url_evolution_go/manager\e[0m"
echo ""

echo -e "\e[97mBaseUrl:\e[33m https://$url_evolution_go\e[0m"
echo ""

echo -e "\e[97mGlobal API Key:\e[33m $apikeyglobal\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########   ### #######      ############## ####   ####
## a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a--    a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'
## a-a-a-a-a-a--  a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'    a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-"a-a-a-'
## a-a-a-"a-a-a-  a-a-a-a-- a-a-a-"a-a-a-a-'   a-a-a-'    a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-"a-a-a-a-'
## a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-"a-    a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'
## a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-a-a-a-a-      a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-

