#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_postgres_setup() {

## Verifica os recursos
recursos 1 1 || return

## Ativa a funcao dados para pegar os dados da vps
dados

## Limpar o terminal
clear
## Mostrar mensagem de Instalando
instalando_msg

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO POSTGRES \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO POSTGRES \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Gerando uma senha aleatoria para o Postgres
senha_postgres=$(openssl rand -hex 16)

## Criando a stack postgres.yaml
cat > postgres${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  postgres${1:+_$1}:
    image: postgres:14 ## Versao do postgres
    command: >
      postgres
      -c max_connections=500
      -c shared_buffers=512MB
      -c timezone=America/Sao_Paulo

    volumes:
      - postgres${1:+_$1}_data:/var/lib/postgresql/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 5432:5432

    environment:
    ##  Senha do Postgres 
      - POSTGRES_PASSWORD=$senha_postgres

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

volumes:
  postgres${1:+_$1}_data:
    external: true
    name: postgres${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Postgres"
fi
STACK_NAME="postgres${1:+_$1}"
stack_editavel #> /dev/null 2>&1

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

wait_stack "postgres${1:+_$1}_postgres${1:+_$1}"


#docker stack deploy --prune --resolve-image always -c postgres.yaml postgres > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do Postgres."
#fi

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_postgres${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ POSTGRES ]

Host: postgres${1:+_$1}

Port: 5432

Usuario: postgres

Senha: $senha_postgres
__FELSEN_MANAGED_FILE__
cd
cd

## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ POSTGRES ]\e[0m"
echo ""

echo -e "\e[97mHost:\e[33m postgres${1:+_$1}\e[0m"
echo ""

echo -e "\e[97mPorta:\e[33m 5432\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m postgres\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m $senha_postgres\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  #######     ###   ########### ################ ####### ####### 
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-     a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-a--    a-a-a-'   a-a-a-'a-a-a-a-a-a--  a-a-a-'        a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-
## a-a-a-"a-a-a-a- a-a-a-'   a-a-a-'    a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-  a-a-a-'        a-a-a-'   a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-'     a-a-a-a-a-a-a-a-"a-     a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'
## a-a-a-      a-a-a-a-a-a-a-       a-a-a-a-a-  a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-   a-a-a-    a-a-a-a-a-a-a- a-a-a-  a-a-a-
                                                                        

