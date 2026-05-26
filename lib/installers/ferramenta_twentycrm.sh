#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_twentycrm() {

## Verifica os recursos
recursos 1 4 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_twentycrm

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o dominio para o TwentyCRM (ex: twentycrm.example.com): \e[0m" && read -r url_twentycrm
    echo ""

    ## Pergunta o email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_twentycrm
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_smtp_twentycrm
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r pass_smtp_twentycrm
    echo ""
    
    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_twentycrm
    echo ""
    
    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_twentycrm
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_twentycrm
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do twentycrm
    echo -e "\e[33mDominio do TwentyCRM:\e[97m $url_twentycrm\e[0m"
    echo ""

    ## Informacao sobre URL do twentycrm
    echo -e "\e[33mEmail SMTP:\e[97m $email_smtp_twentycrm\e[0m"
    echo ""
    
    ## Informacao sobre URL do twentycrm
    echo -e "\e[33mUsuario do SMTP:\e[97m $user_smtp_twentycrm\e[0m"
    echo ""

    ## Informacao sobre URL do twentycrm
    echo -e "\e[33mSenha do Email SMTP:\e[97m $pass_smtp_twentycrm\e[0m"
    echo ""

    ## Informacao sobre URL do twentycrm
    echo -e "\e[33mHost SMTP:\e[97m $host_smtp_twentycrm\e[0m"
    echo ""

    ## Informacao sobre URL do twentycrm
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_twentycrm\e[0m"
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
        nome_twentycrm

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO TWENTYCRM \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO TWENTYCRM \e[33m[2/3]\e[0m"
echo ""
sleep 1

senha_postgres_twentycrm=$(openssl rand -hex 16)
Key_aleatoria_twentycrm_1=$(openssl rand -hex 16)
Key_aleatoria_twentycrm_2=$(openssl rand -hex 16)
Key_aleatoria_twentycrm_3=$(openssl rand -hex 16)
Key_aleatoria_twentycrm_4=$(openssl rand -hex 16)

## Criando a stack
cat > twentycrm${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  twentycrm${1:+_$1}_server:
    image: twentycrm/twenty:latest

    volumes:
      - twentycrm${1:+_$1}_data:/app/packages/twenty-server/.local-storage
      - twentycrm${1:+_$1}_docker:/app/docker-data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Dados de acesso
      - PORT=3000
      - SERVER_URL=https://$url_twentycrm

    ##  Dados do Redis
      - REDIS_URL=redis://twentycrm${1:+_$1}_redis:6379

    ##  Dados do Postgres
      - PG_DATABASE_URL=postgres://postgres:$senha_postgres_twentycrm@twentycrm${1:+_$1}_db:5432/twentycrm${1:+_$1}

    ## -'i Dados da Storage/s3
      - STORAGE_TYPE=local

    ##  Secret Keys
      - APP_SECRET=$Key_aleatoria_twentycrm_1
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 4192M
      labels:
        - traefik.enable=true
        - traefik.http.routers.twentycrm${1:+_$1}.rule=Host(\`$url_twentycrm\`) ## Url da aplicacao
        - traefik.http.services.twentycrm${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.twentycrm${1:+_$1}.service=twentycrm${1:+_$1}
        - traefik.http.routers.twentycrm${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.twentycrm${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.twentycrm${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  twentycrm${1:+_$1}_worker:
    image: twentycrm/twenty:latest
    command: ["yarn", "worker:prod"]

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Dados de acesso
      - PORT=3000
      - SERVER_URL=https://$url_twentycrm

    ##  Dados do Redis
      - REDIS_URL=redis://twentycrm${1:+_$1}_redis:6379

    ##  Dados do Postgres
      - PG_DATABASE_URL=postgres://postgres:$senha_postgres_twentycrm@twentycrm${1:+_$1}_db:5432/twentycrm${1:+_$1}
      - DISABLE_DB_MIGRATIONS=true

    ## -'i Dados da Storage/s3
      - STORAGE_TYPE=local

    ##  Secret Keys
      - APP_SECRET=$Key_aleatoria_twentycrm_1

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

  twentycrm${1:+_$1}_db:
    image: twentycrm/twenty-postgres-spilo:latest

    volumes:
      - twentycrm${1:+_$1}_db:/home/postgres/pgdata

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - PGUSER_SUPERUSER=postgres
      - POSTGRES_DB=twentycrm${1:+_$1}
      - POSTGRESQL_PASSWORD=$senha_postgres_twentycrm
      - PGPASSWORD_SUPERUSER=$senha_postgres_twentycrm
      - ALLOW_NOSSL=true
      - SPILO_PROVIDER=local
    
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

  twentycrm${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - twentycrm${1:+_$1}_redis:/data

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
  twentycrm${1:+_$1}_data:
    external: true
    name: twentycrm${1:+_$1}_data
  twentycrm${1:+_$1}_docker:
    external: true
    name: twentycrm${1:+_$1}_docker
  twentycrm${1:+_$1}_db:
    external: true
    name: twentycrm${1:+_$1}_db
  twentycrm${1:+_$1}_redis:
    external: true
    name: twentycrm${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da sua rede interna
    name: $nome_rede_interna ## Nome da sua rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do twentycrm"
fi
STACK_NAME="twentycrm${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c twentycrm.yaml twentycrm > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do twentycrm"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull twentycrm/twenty:latest twentycrm/twenty-postgres-spilo:latest

##sleep 5

##docker exec -t "$(docker ps -q --filter "name=twentycrm${1:+_$1}_twentycrm${1:+_$1}_db")" psql -U postgres -c "CREATE DATABASE twentycrm${1:+_$1};"

## Usa o servico wait_stack "twentycrm" para verificar se o servico esta online
wait_stack twentycrm${1:+_$1}_twentycrm${1:+_$1}_server twentycrm${1:+_$1}_twentycrm${1:+_$1}_worker twentycrm${1:+_$1}_twentycrm${1:+_$1}_db
wait_30_sec
sudo chmod -R 755 /var/lib/docker/volumes/twentycrm${1:+_$1}_docker
sudo chown -R 1000:1000 /var/lib/docker/volumes/twentycrm${1:+_$1}_docker

sudo chmod -R 755 /var/lib/docker/volumes/twentycrm${1:+_$1}_data
sudo chown -R 1000:1000 /var/lib/docker/volumes/twentycrm${1:+_$1}_data

wait_30_sec


cd dados_vps

cat > dados_twentycrm${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ TWENTYCRM ]

Dominio do TwentyCRM: https://$url_twentycrm

Usuario: Precisa criar no primeiro acesso do TwentyCRM

Senha: Precisa criar no primeiro acesso do TwentyCRM
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
echo -e "\e[32m[ TWENTYCRM ]\e[0m"
echo ""

echo -e "\e[33mDominio do TwentyCRM:\e[97m https://$url_twentycrm\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do TwentyCRM\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do TwentyCRM\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   #### ###### ################################# ####   #### ####### #################
## a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-
## a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'      a-a-a-'   a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   
## a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a-a-'   a-a-a-'      a-a-a-'   a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'   
## a-a-a-' a-a-a- a-a-a-'a-a-a-'  a-a-a-'   a-a-a-'      a-a-a-'   a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'   a-a-a-'   
## a-a-a-     a-a-a-a-a-a-  a-a-a-   a-a-a-      a-a-a-   a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-   a-a-a-   
                                                                                          

