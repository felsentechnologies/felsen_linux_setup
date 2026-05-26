#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_directus() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_directus

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/7\e[0m"
    echo -en "\e[33mDigite o dominio para o Directus (ex: directus.example.com): \e[0m" && read -r url_directus
    echo ""

     ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/7\e[0m"
    echo -en "\e[33mDigite a Email de Admin (ex: contato@example.com): \e[0m" && read -r email_directus
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/7\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$"
    echo -en "\e[33mDigite a Senha para o Admin (ex: @Senha123_): \e[0m" && read -r senha_directus
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/7\e[0m"
    echo -en "\e[33mDigite a Email SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_directus
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 5/7\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP (ex: @Senha123_): \e[0m" && read -r senha_smtp_directus
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 6/7\e[0m"
    echo -en "\e[33mDigite o Host SMTP (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_directus
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 7/7\e[0m"
    echo -en "\e[33mDigite a Porta SMTP (ex: 465): \e[0m" && read -r porta_smtp_directus
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_directus
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do directus
    echo -e "\e[33mDominio do Directus:\e[97m $url_directus\e[0m"
    echo ""

    ## Informacao sobre URL do directus
    echo -e "\e[33mEmail de Admin:\e[97m $email_directus\e[0m"
    echo ""

    ## Informacao sobre URL do directus
    echo -e "\e[33mSenha de Admin:\e[97m $senha_directus\e[0m"
    echo ""

    ## Informacao sobre URL do directus
    echo -e "\e[33mEmail SMTP:\e[97m $email_smtp_directus\e[0m"
    echo ""

    ## Informacao sobre URL do directus
    echo -e "\e[33mSenha SMTP:\e[97m $senha_smtp_directus\e[0m"
    echo ""

    ## Informacao sobre URL do directus
    echo -e "\e[33mHost SMTP:\e[97m $host_smtp_directus\e[0m"
    echo ""

    ## Informacao sobre URL do directus
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_directus\e[0m"
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_directus" -eq 465 ]; then
    ssl_smtp_directus=true
    else
    ssl_smtp_directus=false
    fi
    
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
        nome_directus

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO DIRECTUS \e[33m[1/5]\e[0m"
echo ""
sleep 1

## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/5]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "directus${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "directus${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO BUCKET NO MINIO \e[33m[3/5]\e[0m"
echo ""
sleep 1

pegar_senha_minio
minio.bucket directus${1:+-$1} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "1/1 - [ OK ] - Criando Bucket\e[33m $BUCKET\e[0m"
    echo ""
else
    echo "1/1 - [ OFF ] - Erro ao criar Bucket"
    echo ""
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO DIRECTUS \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Gerar Secret Key
key_directus=$(openssl rand -hex 16)
key_directus2=$(openssl rand -hex 16)

## Criando a stack directus.yaml
cat > directus${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  directus${1:+_$1}_app:
    image: directus/directus:latest

    volumes:
      - directus${1:+_$1}_uploads:/directus/uploads
      - directus${1:+_$1}_data:/directus/database

    networks:
      - $nome_rede_interna

    environment:
    ##  Dados de acesso
      - ADMIN_EMAIL=$email_directus
      - ADMIN_PASSWORD=$senha_directus
      - PUBLIC_URL=https://$url_directus

    ##  Dados SMTP
      - EMAIL_SMTP_USER=$email_smtp_directus
      - EMAIL_SMTP_PASSWORD=$senha_smtp_directus
      - EMAIL_SMTP_HOST=$host_smtp_directus
      - EMAIL_SMTP_PORT=$porta_smtp_directus
      - EMAIL_SMTP_SECURE=$ssl_smtp_directus

    ## -i Dados MinIO
      - STORAGE_s3_KEY=$S3_ACCESS_KEY
      - STORAGE_s3_SECRET=$S3_SECRET_KEY
      - STORAGE_s3_BUCKET=directus${1:+-$1}
      - STORAGE_s3_REGION=eu-south
      - STORAGE_s3_ENDPOINT=$url_s3

    ##  Redis
      - CACHE_ENABLED=true
      - CACHE_AUTO_PURGE=true
      - CACHE_STORE=redis
      - REDIS=redis://redis:6379

    ## " Secret Keys & Env
      - KEY=$key_directus
      - SECRET=$key_directus2
      - APP_ENV=production

    ##  Dados Postgres
      - DB_CLIENT=postgres
      - DB_HOST=postgres
      - DB_PORT=5432
      - DB_DATABASE=directus${1:+_$1}
      - DB_USER=postgres
      - DB_PASSWORD=$senha_postgres
      - DB_CONNECTION_STRING=postgresql://postgres:$senha_postgres@postgres:5432/directus${1:+_$1}
      - DB_PREFIX=drcts_

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.directus${1:+_$1}_app.rule=Host(\`$url_directus\`)
        - traefik.http.services.directus${1:+_$1}_app.loadbalancer.server.port=8055
        - traefik.http.routers.directus${1:+_$1}_app.service=directus${1:+_$1}_app
        - traefik.http.routers.directus${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.directus${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.directus${1:+_$1}_app.tls=true

## --------------------------- FELSEN --------------------------- ##

  directus${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - directus${1:+_$1}_redis:/data

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
  directus${1:+_$1}_uploads:
    external: true
    name: directus${1:+_$1}_uploads
  directus${1:+_$1}_data:
    external: true
    name: directus${1:+_$1}_data
  directus${1:+_$1}_redis:
    external: true
    name: directus${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    attachable: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do directus"
fi
STACK_NAME="directus${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c directus.yaml directus > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do directus"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest directus/directus:latest

## Usa o servico wait_tack "directus" para verificar se o servico esta online
wait_stack directus${1:+_$1}_directus${1:+_$1}_redis directus${1:+_$1}_directus${1:+_$1}_app


cd dados_vps

cat > dados_directus${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ DIRECTUS ]

Dominio do directus: https://$url_directus

Usuario: $email_directus

Senha: $senha_directus

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
echo -e "\e[32m[ DIRECTUS ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_directus\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $email_directus\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $senha_directus\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###   ### ###### ###   ######  ############    ### ###### ####### ####### ############   ###
## a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-'  a-a-a-a-a-a-"a-a-a-a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'
## a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-' a-a-- a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a--  a-a-a-"a-a-a-- a-a-a-'
## a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'
##  a-a-a-a-a-a-"a- a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'   a-a-a-a-a-"a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'
##   a-a-a-a-a-  a-a-a-  a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-    a-a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-                                                                                    

