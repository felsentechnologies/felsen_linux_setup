#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_mysql() {

## Ativa a funcao dados para pegar os dados da vps
dados


## Gerando uma senha aleatoria para o Mysql
senha_mysql=$(openssl rand -hex 16)

## Criando a stack do mysql.yaml
cat > mysql.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  mysql:
    image: percona/percona-server:8.0 ## Versao do MySQL
    command:
      [
        "--character-set-server=utf8mb4",
        "--collation-server=utf8mb4_general_ci",
        "--sql-mode=",
        "--default-authentication-plugin=caching_sha2_password",
        "--max-allowed-packet=512MB",
      ]

    volumes:
      - mysql_data:/var/lib/mysql

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 3306:3306

    environment:
    ## AoaEURaEUR Senha do MYSQL
      - MYSQL_ROOT_PASSWORD=$senha_mysql

    ##  TimeZone
      - TZ=America/Sao_Paulo

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
  mysql_data:
    external: true
    name: mysql_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do MySQL"
fi

STACK_NAME="mysql"
stack_editavel #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do Postgres."
#fi

wait_stack "mysql${1:+_$1}_mysql${1:+_$1}"

#docker stack deploy --prune --resolve-image always -c mysql.yaml mysql #> /dev/null 2>&1

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_mysql <<__FELSEN_MANAGED_FILE__
[ MYSQL ]

Dominio do mysql: mysql

Usuario: root

Senha: $senha_mysql
__FELSEN_MANAGED_FILE__
cd
cd

## Espera 30 segundos
wait_30_sec

echo ""
}

## ####   #######   ########### ####### ###     
##
## ############################   ########## 
