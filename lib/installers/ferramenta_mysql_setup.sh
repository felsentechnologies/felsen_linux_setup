#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_mysql_setup() {

## Verifica os recursos
recursos 1 1 || return

## Ativa a funcao dados para pegar os dados da vps
dados

## Limpar o terminal
clear
## Mostrar mensagem de Instalando
instalando_msg

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO MYSQL \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO MYSQL \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Gerando uma senha aleatoria para o Mysql
senha_mysql=$(openssl rand -hex 16)

## Criando a stack do mysql.yaml
cat > mysql${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  mysql${1:+_$1}:
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
      - mysql${1:+_$1}_data:/var/lib/mysql

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 3306:3306

    environment:
    ##  Senha do MYSQL
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
  mysql${1:+_$1}_data:
    external: true
    name: mysql${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Ops, nao foi criar a stack do Mysql."
fi

STACK_NAME="mysql${1:+_$1}"

stack_editavel

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

wait_stack "mysql${1:+_$1}_mysql${1:+_$1}" > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do Postgres."
#fi

#docker stack deploy --prune --resolve-image always -c mysql.yaml mysql #> /dev/null 2>&1

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_mysql${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ MYSQL ]

Host: mysql${1:+_$1}

Porta: 3306

Usuario: root

Senha: $senha_mysql
__FELSEN_MANAGED_FILE__
## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ MYSQL ]\e[0m"
echo ""

echo -e "\e[97mHost:\e[33m mysql${1:+_$1}\e[0m"
echo ""

echo -e "\e[97mPorta:\e[33m 3306\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m root\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m $senha_mysql\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ##########  ### ###### ############    ### #######  ####### #########
## a-a-a-"a-a-a-a-a-a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-a-a-a-"a-a-a-
## ##|     #######|#######|   ##|   ##| ## ##|##|   ##|##|   ##|   ##|   
## a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'   
## a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'   a-a-a-'   a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-   a-a-a-'   
##  a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-   a-a-a-    a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-  a-a-a-a-a-a-a-    a-a-a-   

