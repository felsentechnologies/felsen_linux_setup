#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_baserow() {

## Verifica os recursos
recursos 2 4 || return

## Verifica os recursos
recursos 1 1 || return
## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_baserow

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o dominio para o Baserow (ex: baserow.example.com): \e[0m" && read -r url_baserow
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r mail_baserow
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_baserow
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r pass_baserow
    echo ""


    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r host_baserow
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a Porta SMTP do Email (ex: 465): \e[0m" && read -r porta_baserow
    echo ""


    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_baserow" -eq 465 ]; then
    ssl_baserow_environment="- EMAIL_SMTP_USE_SSL=true"
    else
    ssl_baserow_environment="- EMAIL_SMTP_USE_TLS=true"
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_baserow
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o Baserow:\e[97m $url_baserow\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mEmail do SMTP:\e[97m $mail_baserow\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mUsuario do SMTP:\e[97m $user_baserow\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mSenha do SMTP:\e[97m $pass_baserow\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mHost do SMTP:\e[97m $host_baserow\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mPorta do SMTP:\e[97m $porta_baserow\e[0m"
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
        nome_baserow

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO BASEROW \e[33m[1/3]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO BASEROW \e[33m[2/3]\e[0m"
echo ""
sleep 1

secret_key_baserow=$(openssl rand -hex 16)
jwt_key_baserow=$(openssl rand -hex 16)

## Criando a stack baserow.yaml
cat > baserow${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  baserow${1:+_$1}_app:
    image: baserow/baserow:latest

    volumes:
      - baserow${1:+_$1}_data:/baserow/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  URL do Baserow
      - BASEROW_PUBLIC_URL=https://$url_baserow
      
    ## i Configuracoes de SeguranAa
      - SECRET_KEY=$secret_key_baserow
      - BASEROW_JWT_SIGNING_KEY=$jwt_key_baserow
      
    ##  Configuracoes de Email SMTP
      - EMAIL_SMTP=true
      - FROM_EMAIL=$mail_baserow ## Email
      - EMAIL_SMTP=$mail_baserow ## Email
      - EMAIL_SMTP_USER=$user_baserow ## Email (ou usuario)
      - EMAIL_SMTP_PASSWORD=$pass_baserow ## Senha do SMTP
      - EMAIL_SMTP_HOST=$host_baserow ## Host SMTP
      - EMAIL_SMTP_PORT=$porta_baserow ## Porta SMTP
      $ssl_baserow_environment

    ##  Configuracoes de Migracao e Templates
      - MIGRATE_ON_STARTUP=true
      - SYNC_TEMPLATES_ON_STARTUP=false

    ##  Configuracoes do Redis
      - REDIS_HOST=baserow${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=
      - REDIS_URL=redis://baserow${1:+_$1}_redis:6379/1
      
    ##  Configuracoes do Banco de Dados
      #- DATABASE_HOST=pgvector
      #- DATABASE_PORT=5432
      #- DATABASE_USER=postgres
      #- DATABASE_NAME=baserow${1:+_$1}
      #- DATABASE_PASSWORD=SENHA_DO_PGVECTOR
      #- DATABASE_URL=postgresql://postgres:SENHA_DO_PGVECTOR@baserow_db:5432/baserow${1:+_$1}?sslmode=disable

    ## Configuracoes AWS S3 (descomente para usar)
      #- AWS_ACCESS_KEY_ID=
      #- AWS_SECRET_ACCESS_KEY=
      #- AWS_STORAGE_BUCKET_NAME=baserow${1:+-$1}
      #- AWS_S3_REGION_NAME=eu-south
      #- AWS_S3_ENDPOINT_URL=https://s3.dominio.com

    ## " Log Level
      #- BASEROW_BACKEND_LOG_LEVEL=INFO

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
        - traefik.http.routers.baserow${1:+_$1}.rule=Host(\`$url_baserow\`)
        - traefik.http.services.baserow${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.baserow${1:+_$1}.service=baserow${1:+_$1}
        - traefik.http.routers.baserow${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.baserow${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.baserow${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  baserow${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - baserow${1:+_$1}_redis:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
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
  baserow${1:+_$1}_data:
    external: true
    name: baserow${1:+_$1}_data
  baserow${1:+_$1}_redis:
    external: true
    name: baserow${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Baserow"
fi

STACK_NAME="baserow${1:+_$1}"
stack_editavel # > /dev/null 2>&1

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest baserow/baserow:latest

## Usa o servico wait_baserow para verificar se o servico esta online
wait_stack baserow${1:+_$1}_baserow${1:+_$1}_redis baserow${1:+_$1}_baserow${1:+_$1}_app


cd
cd dados_vps

cat > dados_baserow${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ BASEROW ]

Dominio do Baserow: https://$url_baserow

Usuario: Precisa criar no primeiro acesso do Baserow

Senha: Precisa criar no primeiro acesso do Baserow

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
echo -e "\e[32m[ BASEROW ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_baserow\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Baserow\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Baserow\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   #### ####### ####   ### #######  ####### ####### ####### 
## a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a- a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--
## a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-'  a-a-a-a--a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-
## a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-
## a-a-a-     a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- 
                                                                
