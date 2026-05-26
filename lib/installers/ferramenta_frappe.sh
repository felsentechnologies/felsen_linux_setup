#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_frappe() {

## Verifica os recursos
recursos 2 4 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_frappe

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o Frappe ERPNext (ex: crm.example.com): \e[0m" && read -r url_frappe
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -en "\e[33mDigite a Senha do usuario Administrador (ex: @Senha123_): \e[0m" && read -r senha_frappe
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_frappe
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do frappe
    echo -e "\e[33mDominio do Frappe ERPNext:\e[97m $url_frappe\e[0m"
    echo ""

    ## Informacao sobre URL do frappe
    echo -e "\e[33mSenha do Administrador:\e[97m $senha_frappe\e[0m"
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
        nome_frappe

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO FRAPPE ERPNEXT \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO ERPNEXT \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
DB_PASSWORD=$(openssl rand -hex 16)

## Criando a stack frappe.yaml
cat > erpnext${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  erpnext${1:+_$1}_frontend:
    image: frappe/erpnext:v15.49.3
    command: ["nginx-entrypoint.sh"]

    volumes:
      - erpnext${1:+_$1}_sites:/home/frappe/frappe-bench/sites
      - erpnext${1:+_$1}_logs:/home/frappe/frappe-bench/logs

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracoes de ConexAo
      - BACKEND=erpnext${1:+_$1}_backend:8000
      - SOCKETIO=erpnext${1:+_$1}_websocket:9000

    ## i Configuracoes do Site
      - FRAPPE_SITE_NAME_HEADER=$url_frappe
      - FRAPPE_SITE=$url_frappe

    ##  Configuracoes de Proxy
      - UPSTREAM_REAL_IP_ADDRESS=127.0.0.1
      - UPSTREAM_REAL_IP_HEADER=X-Forwarded-For
      - UPSTREAM_REAL_IP_RECURSIVE=off
      - PROXY_READ_TIMEOUT=120
      - CLIENT_MAX_BODY_SIZE=50m
      
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
        - traefik.http.routers.erpnext${1:+_$1}_frontend.rule=Host(\`$url_frappe\`)
        - traefik.http.services.erpnext${1:+_$1}_frontend.loadbalancer.server.port=8080
        - traefik.http.routers.erpnext${1:+_$1}_frontend.service=erpnext${1:+_$1}_frontend
        - traefik.http.routers.erpnext${1:+_$1}_frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.erpnext${1:+_$1}_frontend.entrypoints=websecure
        - traefik.http.routers.erpnext${1:+_$1}_frontend.tls=true

## --------------------------- FELSEN --------------------------- ##

  erpnext${1:+_$1}_backend:
    image: frappe/erpnext:v15.49.3

    volumes:
      - erpnext${1:+_$1}_sites:/home/frappe/frappe-bench/sites
      - erpnext${1:+_$1}_logs:/home/frappe/frappe-bench/logs

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Dados do MySQL
      - DB_HOST=erpnext${1:+_$1}_db
      - DB_PORT=3306
      - DB_USER=frappe
      - DB_PASSWORD=$DB_PASSWORD
      - MYSQL_ROOT_PASSWORD=$DB_PASSWORD
      - MARIADB_ROOT_PASSWORD=$DB_PASSWORD
    
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

## --------------------------- FELSEN --------------------------- ##

  erpnext${1:+_$1}_configurator:
    image: frappe/erpnext:v15.49.3

    volumes:
      - erpnext${1:+_$1}_sites:/home/frappe/frappe-bench/sites
      - erpnext${1:+_$1}_logs:/home/frappe/frappe-bench/logs

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Dados do MySQL
      - DB_HOST=erpnext${1:+_$1}_db
      - DB_PORT=3306

    ##  Dados do Redis
      - REDIS_CACHE=erpnext${1:+_$1}_cache:6379
      - REDIS_QUEUE=erpnext${1:+_$1}_queue:6379
      - REDIS_SOCKETIO=erpnext${1:+_$1}_socketio:6379

    ##  Dados Websocket
      - SOCKETIO_PORT=9000

    ##  Host
      - HOST_URL=$url_frappe
    
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

## --------------------------- FELSEN --------------------------- ##
      
  erpnext${1:+_$1}_websocket:
    image: frappe/erpnext:v15.49.3
    command: ["node", "/home/frappe/frappe-bench/apps/frappe/socketio.js"]

    volumes:
      - erpnext${1:+_$1}_sites:/home/frappe/frappe-bench/sites
      - erpnext${1:+_$1}_logs:/home/frappe/frappe-bench/logs

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
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
            
## --------------------------- FELSEN --------------------------- ##

  erpnext${1:+_$1}_db:
    image: mariadb:10.6
    command: ["--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--skip-character-set-client-handshake", "--skip-innodb-read-only-compressed"]

    volumes:
      - erpnext${1:+_$1}_db:/var/lib/mysql

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Dados do MySQL
      - MYSQL_ROOT_PASSWORD=$DB_PASSWORD
      - MARIADB_ROOT_PASSWORD=$DB_PASSWORD
    
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

  erpnext${1:+_$1}_cache:
    image: redis:latest
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - erpnext${1:+_$1}_cache:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  erpnext${1:+_$1}_queue:
    image: redis:latest
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - erpnext${1:+_$1}_queue:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  erpnext${1:+_$1}_socketio:
    image: redis:latest
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - erpnext${1:+_$1}_socketio:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

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
  erpnext${1:+_$1}_sites:
    external: true
    name: erpnext${1:+_$1}_sites
  erpnext${1:+_$1}_logs:
    external: true
    name: erpnext${1:+_$1}_logs
  erpnext${1:+_$1}_db:
    external: true
    name: erpnext${1:+_$1}_db
  erpnext${1:+_$1}_cache:
    external: true
    name: erpnext${1:+_$1}_cache
  erpnext${1:+_$1}_queue:
    external: true
    name: erpnext${1:+_$1}_queue
  erpnext${1:+_$1}_socketio:
    external: true
    name: erpnext${1:+_$1}_socketio

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do frappe"
fi
STACK_NAME="erpnext${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c frappe.yaml frappe > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do frappe"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull frappe/erpnext:v15.49.3 mariadb:10.6 redis:latest

sleep 45

echo "{
  \"db_host\": \"erpnext${1:+_$1}_db\",
  \"db_port\": \"3306\",
  \"redis_cache\": \"redis://erpnext${1:+_$1}_cache:6379\",
  \"redis_queue\": \"redis://erpnext${1:+_$1}_queue:6379\",
  \"redis_socketio\": \"redis://erpnext${1:+_$1}_socketio:6379\",
  \"auto_update\": false,
  \"disable_website_cache\": true,
  \"domains\": [\"$url_frappe\"]
}" > /var/lib/docker/volumes/erpnext${1:+_$1}_sites/_data/common_site_config.json

## Usa o servico wait_frappe para verificar se o servico esta online
wait_stack erpnext${1:+_$1}_erpnext${1:+_$1}_frontend erpnext${1:+_$1}_erpnext${1:+_$1}_backend erpnext${1:+_$1}_erpnext${1:+_$1}_configurator erpnext${1:+_$1}_erpnext${1:+_$1}_websocket erpnext${1:+_$1}_erpnext${1:+_$1}_db erpnext${1:+_$1}_erpnext${1:+_$1}_cache erpnext${1:+_$1}_erpnext${1:+_$1}_queue erpnext${1:+_$1}_erpnext${1:+_$1}_socketio

sleep 30

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO APLICATIVO \e[33m[4/4]\e[0m"
echo ""
sleep 1

docker exec -it $(docker ps -qf "name=erpnext${1:+_$1}_backend") bash -c "bench new-site \"$url_frappe\" --mariadb-root-password=\"$DB_PASSWORD\" --admin-password=\"$senha_frappe\" --install-app erpnext"


cd dados_vps

cat > dados_erpnext${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ ERPNEXT ]

Dominio do ERPNext: https://$url_frappe

Usuario: administrator

Senha: $senha_frappe
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
echo -e "\e[32m[ ERPNEXT ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_frappe\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m administrator\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $senha_frappe\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  ####### ###  #########
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-'  a-a-a-a-a-a-"a-a-a-
## a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   
## a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'   
## a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-   

