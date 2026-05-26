#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_openproject() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_openproject

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o OpenProject (ex: openproject.example.com): \e[0m" && read -r url_openproject
    echo ""

    ## Limpa o terminal
    clear

    ## Mostra o nome da aplicacao
    nome_openproject

    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL do openproject
    echo -e "\e[33mDominio do OpenProject:\e[97m $url_openproject\e[0m"
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
        nome_minio

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO OPENPROJECT \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO OPENPROJECT \e[33m[2/3]\e[0m"
echo ""
sleep 1

key_openproject=$(openssl rand -hex 16)
senha_postgres_openproject=$(openssl rand -hex 16)

## Criando a stack
cat > openproject${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  openproject${1:+_$1}_app:
    image: openproject/openproject:16

    volumes:
      - openproject${1:+_$1}_pgdata:/var/openproject/pgdata
      - openproject${1:+_$1}_assets:/var/openproject/assets

    networks:
      - $nome_rede_interna

    environment:
    ##  Secret Key
      - OPENPROJECT_SECRET_KEY_BASE=$key_openproject

    ##  Dominio:
      - OPENPROJECT_HOST__NAME=$url_openproject
      - OPENPROJECT_HTTPS=true

    ##  Dados do Redis
      - OPENPROJECT_RAILS__CACHE__STORE=redis
      - OPENPROJECT_CACHE_REDIS_URL=redis://openproject${1:+_$1}_redis:6379

    ##  Dados do Postgres
      - OPENPROJECT_DATABASE_HOST=openproject${1:+_$1}_db
      - OPENPROJECT_DATABASE_PORT=5432
      - OPENPROJECT_DATABASE_NAME=openproject${1:+_$1}
      - OPENPROJECT_DATABASE_USERNAME=postgres
      - OPENPROJECT_DATABASE_PASSWORD=$senha_postgres_openproject

    ## Configuracoes
      - OPENPROJECT_DEFAULT__LANGUAGE=pt-BR

    ## Dados SMTP
    ## Deixei comentado pois a environment da senha nao esta funcionando como o esperado
      #- OPENPROJECT_EMAIL__DELIVERY__METHOD=smtp
      #- OPENPROJECT_MAIL__FROM=email@dominio.com
      #- OPENPROJECT_SMTP__USER__NAME=Usuario_do_Email
      #- OPENPROJECT_SMTP__DOMAIN=dominio.com
      #- OPENPROJECT_SMTP__PASSWORD=Senha_do_Email
      #- OPENPROJECT_SMTP__ADDRESS=smtp.dominio.com
      #- OPENPROJECT_SMTP__PORT=587
      #- OPENPROJECT_SMTP__ENABLE__STARTTLS__AUTO=true
      #- OPENPROJECT_SMTP__AUTHENTICATION=plain
      #- OPENPROJECT_SMTP__OPENSSL__VERIFY__MODE=peer 
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.openproject${1:+_$1}_app.rule=Host(\`$url_openproject\`)
        - traefik.http.routers.openproject${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.openproject${1:+_$1}_app.priority=1
        - traefik.http.routers.openproject${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.openproject${1:+_$1}_app.service=openproject${1:+_$1}_app
        - traefik.http.services.openproject${1:+_$1}_app.loadbalancer.server.port=8080
        - traefik.http.services.openproject${1:+_$1}_app.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  openproject${1:+_$1}_db:
    image: postgres:17 ## Versao do postgres
    command: >
      postgres
      -c max_connections=500
      -c shared_buffers=512MB
      -c timezone=America/Sao_Paulo

    volumes:
      - openproject${1:+_$1}_db:/var/lib/postgresql/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 5432:5432

    environment:
    ## -"i Nome da Database
      - POSTGRES_DB=openproject${1:+_$1}

    ##  Senha do Postgres 
      - POSTGRES_PASSWORD=$senha_postgres_openproject

    ##  Timezone
      - TZ=America/Sao_Paulo

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

  openproject${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - openproject${1:+_$1}_redis:/data

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
  openproject${1:+_$1}_pgdata:
    external: true
    name: openproject${1:+_$1}_pgdata
  openproject${1:+_$1}_assets:
    external: true
    name: openproject${1:+_$1}_assets
  openproject${1:+_$1}_db:
    external: true
    name: openproject${1:+_$1}_db
  openproject${1:+_$1}_redis:
    external: true
    name: openproject${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do OpenProject"
fi
STACK_NAME="openproject${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c openproject.yaml openproject > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do openproject"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull postgres:17 redis:latest openproject/openproject:16

## Usa o servico wait_stack "openproject" para verificar se o servico esta online
wait_stack openproject${1:+_$1}_openproject${1:+_$1}_db openproject${1:+_$1}_openproject${1:+_$1}_redis openproject${1:+_$1}_openproject${1:+_$1}_app

wait_30_sec
wait_30_sec


cd dados_vps

cat > dados_openproject${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ OPENPROJECT ]

Dominio do openproject: https://$url_openproject

Usuario: admin

Senha: admin
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
echo -e "\e[32m[ OPENPROJECT ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_openproject\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m admin\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m admin\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####################### 
##  a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--
##    a-a-a-a-"a- a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-
##   a-a-a-a-"a-  a-a-a-"a-a-a-  a-a-a-"a-a-a-a- 
##  ##################|     
##  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-                         

