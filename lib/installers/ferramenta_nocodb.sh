#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_nocodb() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_nocodb

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o NocoDB (ex: nocodb.example.com): \e[0m" && read -r url_nocodb
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_nocodb
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o NocoDB:\e[97m $url_nocodb\e[0m"
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
        nome_nocodb

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO NOCODB \e[33m[1/4]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Ja sabe ne ksk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "nocodb${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "nocodb${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO NOCODB \e[33m[3/4]\e[0m"
echo ""
sleep 1

secret_nocodb=$(openssl rand -hex 16)

## Criando a stack
cat > nocodb${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  nocodb${1:+_$1}_app: 
    image: nocodb/nocodb:latest

    volumes: 
      - nocodb${1:+_$1}_data:/usr/app/data

    networks:
      - $nome_rede_interna

    environment: 
    ##  Url do Nocobase
      - NC_PUBLIC_URL=https://$url_nocodb

    ##  Dados Postgres
      - NC_DB=pg://postgres:5432?u=postgres&p=$senha_postgres&d=nocodb${1:+_$1}

    ##  Dados do redis
      - NC_REDIS_URL=redis://nocodb${1:+_$1}_redis:6379

    ##  Desativar rastreamento
      - NC_DISABLE_TELE=true  

    ##  Secret Key
      - NC_AUTH_JWT_SECRET=$secret_nocodb

    ##  Dados do SMTP
      #- NC_SMTP_FROM=
      #- NC_SMTP_USERNAMENC_SMTP_USERNAME=
      #- NC_SMTP_HOST=
      #- NC_SMTP_PORT=587
      #- NC_SMTP_SECURE=false

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
        - traefik.http.routers.nocodb${1:+_$1}_app.rule=Host(\`$url_nocodb\`)
        - traefik.http.routers.nocodb${1:+_$1}_app.entrypoints=websecure
        - traefik.http.services.nocodb${1:+_$1}_app.loadbalancer.server.port=8080
        - traefik.http.routers.nocodb${1:+_$1}_app.service=nocodb${1:+_$1}_app
        - traefik.http.routers.nocodb${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - com.centurylinklabs.watchtower.enable=true

## --------------------------- FELSEN --------------------------- ##

  nocodb${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - nocodb${1:+_$1}_redis:/data

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
  nocodb${1:+_$1}_data:
    external: true
    name: nocodb${1:+_$1}_data
  nocodb${1:+_$1}_redis:
    external: true
    name: nocodb${1:+_$1}_redis

networks:
  $nome_rede_interna:
    name: $nome_rede_interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do NocoDB"
fi
STACK_NAME="nocodb${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c nocodb.yaml nocodb > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do NocoDB"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull nocodb/nocodb:latest

## Usa o servico wait_nocodb para verificar se o servico esta online
wait_stack nocodb${1:+_$1}_nocodb${1:+_$1}


cd dados_vps

cat > dados_nocodb${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ NOCODB ]

Dominio do NocoDB: https://$url_nocodb

Usuario: Precisa criar no primeiro acesso do NocoDB

Senha: Precisa criar no primeiro acesso do NocoDB

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
echo -e "\e[32m[ NOCODB ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_nocodb\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do NocoDB\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do NocoDB\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###      ###### ####   ### ####### ###########   ###################
## a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a- a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## ##|     #######|###### ##|##|  ##########  ##|   ##|##############  
## a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-  a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  
## a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-      a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

