#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_postgres() {

## Ativa a funcao dados para pegar os dados da vps
dados


## Gerando uma senha aleatoria para o Postgres
senha_postgres=$(openssl rand -hex 16)

## Criando a stack postgres.yaml
cat > postgres.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  postgres:
    image: postgres:14 ## Versao do postgres
    command: >
      postgres
      -c max_connections=500
      -c shared_buffers=512MB
      -c timezone=America/Sao_Paulo

    volumes:
      - postgres_data:/var/lib/postgresql/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 5432:5432

    environment:
    ## AoaEURaEUR Senha do Postgres 
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
  postgres_data:
    external: true
    name: postgres_data

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
STACK_NAME="postgres"
stack_editavel #> /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c postgres.yaml postgres > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do Postgres."
#fi

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_postgres <<__FELSEN_MANAGED_FILE__
[ POSTGRES ]

Host: postgres

Port: 5432

Usuario: postgres

Senha: $senha_postgres
__FELSEN_MANAGED_FILE__
cd
cd

## Espera 30 segundos
wait_stack "postgres_postgres"

echo ""
}

## #######  ####### ################# ####### ####### ################
##
## ############################   ########## 
                                          
