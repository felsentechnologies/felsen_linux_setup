#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_pgvector_setup() {

## Verifica os recursos
recursos 1 1 || return

## Ativa a funcao dados para pegar os dados da vps
dados

## Limpar o terminal
clear
## Mostrar mensagem de Instalando
instalando_msg

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO PGVECTOR \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO PGVECTOR \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Gerando uma senha aleatoria para o Postgres
senha_pgvector=$(openssl rand -hex 16)

## Criando a stack do pgvector.yaml
cat > pgvector${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  pgvector${1:+_$1}:
    image: pgvector/pgvector:pg16 ## Versao do PgVector
    command: >
      postgres
      -c max_connections=500
      -c shared_buffers=512MB
      -c timezone=America/Sao_Paulo

    volumes:
      - pgvector${1:+_$1}:/var/lib/postgresql/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 5433:5432

    environment:
    ##  Senha do Postgres 
      - POSTGRES_PASSWORD=$senha_pgvector

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
  pgvector${1:+_$1}:
    external: true
    name: pgvector${1:+_$1}

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do PgVector"
fi
STACK_NAME="pgvector${1:+_$1}"
stack_editavel #> /dev/null 2>&1

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

wait_stack "pgvector${1:+_$1}_pgvector${1:+_$1}"

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do PgVector."
#fi
#docker stack deploy --prune --resolve-image always -c pgvector.yaml pgvector > /dev/null 2>&1

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_pgvector${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ PGVECTOR ]

Host: pgvector${1:+_$1}

Port: 5432

Usuario: postgres

Senha: $senha_pgvector
__FELSEN_MANAGED_FILE__
cd
cd

## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ PGVECTOR ]\e[0m"
echo ""

echo -e "\e[97mHost:\e[33m pgvector${1:+_$1}\e[0m"
echo ""

echo -e "\e[97mPorta:\e[33m 5432\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m postgres\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m $senha_pgvector\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

cd
cd

}

## ####### ############### ###########
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-

