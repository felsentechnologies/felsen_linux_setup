#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_pgvector() {

## Ativa a funcao dados para pegar os dados da vps
dados


## Gerando uma senha aleatoria para o Postgres
senha_pgvector=$(openssl rand -hex 16)

## Criando a stack pgvector.yaml
cat > pgvector.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  pgvector:
    image: pgvector/pgvector:pg16 ## Versao do PgVector
    command: >
      postgres
      -c max_connections=500
      -c shared_buffers=512MB
      -c timezone=America/Sao_Paulo

    volumes:
      - pgvector:/var/lib/postgresql/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 5433:5432

    environment:
    ## AoaEURaEUR Senha do Postgres 
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
  pgvector:
    external: true
    name: pgvector

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
STACK_NAME="pgvector"
stack_editavel #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do PgVector."
#fi
#docker stack deploy --prune --resolve-image always -c pgvector.yaml pgvector > /dev/null 2>&1

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_pgvector <<__FELSEN_MANAGED_FILE__
[ PGVECTOR ]

Host: pgvector

Port: 5432

Usuario: postgres

Senha: $senha_pgvector

__FELSEN_MANAGED_FILE__
cd
cd

## Espera 30 segundos
wait_stack "pgvector_pgvector"
sleep 20

echo ""
}

## #######  #######     ###   ########### ################ ####### ####### 
##
## ############################   ########## 

