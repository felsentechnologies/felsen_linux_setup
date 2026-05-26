#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_redis() {

## Ativa a funcao dados para pegar os dados da vps
dados


## Criando a stack do redis.yaml
cat > redis.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - redis_data:/data

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
          memory: 2048M

## --------------------------- FELSEN --------------------------- ##

volumes:
  redis_data:
    external: true
    name: redis_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Redis"
fi
STACK_NAME="redis"
stack_editavel #> /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c redis.yaml redis
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do Redis."
#fi

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_redis <<__FELSEN_MANAGED_FILE__
[ REDIS ]

Dominio do Redis: redis://redis:6379

Usuario: redis

Senha: Nao tem
__FELSEN_MANAGED_FILE__
cd
cd

## Espera 30 segundos
wait_stack "redis_redis"

echo ""
}

## ####### ############### ###########
##
## ############################   ########## 

