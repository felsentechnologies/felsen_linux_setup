#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_docmost() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_docmost

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o Docmost (ex: docmost.example.com): \e[0m" && read -r url_docmost
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_docmost
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Docmost:\e[97m $url_docmost\e[0m"
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
        nome_docmost

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO DOCMOST \e[33m[1/4]\e[0m"
echo ""
sleep 1


# Mensagem de Passo
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
    criar_banco_postgres_da_stack "docmost${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "docmost${1:+_$1}"
fi

pegar_senha_postgres > /dev/null 2>&1

echo -e "\e[97m- INSTALANDO docmost \e[33m[3/4]\e[0m"
echo ""
sleep 1

secret_docmost=$(openssl rand -hex 16)

## Criando a stack docmost.yaml
cat > docmost${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  docmost${1:+_$1}_app:
    image: docmost/docmost:latest

    volumes:
      - docmost${1:+_$1}_storage:/app/data/storage

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracoes da Aplicacao
      - APP_URL=https://$url_docmost
      - PORT=3000
      - APP_SECRET=$secret_docmost
      - JWT_TOKEN_EXPIRES_IN=30d
      - DEBUG_MODE=false
      - DISABLE_TELEMETRY=true
      
    ## -"i Configuracoes do Banco de Dados
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/docmost${1:+_$1}?schema=public
      
    ##  Configuracoes do Redis
      - REDIS_URL=redis://docmost${1:+_$1}_redis:6379
      
    ## " Configuracoes de Armazenamento
      - STORAGE_DRIVER=local ## local ou s3
      - FILE_UPLOAD_SIZE_LIMIT=50mb
      #- AWS_S3_ACCESS_KEY_ID=
      #- AWS_S3_SECRET_ACCESS_KEY=
      #- AWS_S3_REGION=
      #- AWS_S3_BUCKET=
      #- AWS_S3_ENDPOINT=
      #- AWS_S3_FORCE_PATH_STYLE=
      
    ##  Configuracoes do SMTP
      #- MAIL_DRIVER=smtp
      #- MAIL_FROM_NAME=Docmost
      #- MAIL_FROM_ADDRESS=email@dominio.com
      #- SMTP_USERNAME=email@dominio.com
      #- SMTP_PASSWORD=@Senha123_
      #- SMTP_HOST=smtp.dominio.com
      #- SMTP_PORT=587
      #- SMTP_SECURE=false
      #- SMTP_IGNORETLS=true

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
        - traefik.http.routers.docmost${1:+_$1}_app.rule=Host(\`$url_docmost\`)
        - traefik.http.services.docmost${1:+_$1}_app.loadbalancer.server.port=3000
        - traefik.http.routers.docmost${1:+_$1}_app.service=docmost${1:+_$1}_app
        - traefik.http.routers.docmost${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.docmost${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.docmost${1:+_$1}_app.tls=true

## --------------------------- FELSEN --------------------------- ##

  docmost${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - docmost${1:+_$1}_redis:/data

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
  docmost${1:+_$1}_storage:
    external: true
    name: docmost${1:+_$1}_storage
  docmost${1:+_$1}_redis:
    external: true
    name: docmost${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do docmost"
fi

STACK_NAME="docmost${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c docmost.yaml docmost > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do docmost"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest docmost/docmost:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack docmost${1:+_$1}_docmost${1:+_$1}_redis docmost${1:+_$1}_docmost${1:+_$1}_app


cd dados_vps

cat > dados_docmost${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ DOCMOST ]

Dominio do docmost: https://$url_docmost
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
echo -e "\e[32m[ DOCMOST ]\e[0m"
echo ""

echo -e "\e[33mDominio do docmost:\e[97m https://$url_docmost\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no docmost\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no docmost\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   ###########################  ####### ###  ###
## a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-a--a-a-a-"a-
## a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a--     a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-' a-a-a-a-a-"a- 
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-     a-a-a-'   a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-' a-a-a-"a-a-a-- 
## a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-"a- a-a-a--
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-   a-a-a-   a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-  a-a-a-

