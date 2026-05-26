#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_redis_setup() {

## Verifica os recursos
recursos 1 2 || return
## Ativa a funcao dados para pegar os dados da vps
dados

## Limpar o terminal
clear
## Mostrar mensagem de Instalando
instalando_msg

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO REDIS \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO REDIS \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack do redis.yaml
cat > redis${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  redis${1:+_$1}:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - redis${1:+_$1}_data:/data

    ## Descomente as linhas abaixo para uso externo
    networks:
      - $nome_rede_interna ## Nome da rede interna
      
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
  redis${1:+_$1}_data:
    external: true
    name: redis${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Ops, nao foi criar a stack do Redis."
fi
sleep 1
STACK_NAME="redis${1:+_$1}"
stack_editavel

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

wait_stack "redis${1:+_$1}_redis${1:+_$1}"


#stack_editavel > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c redis.yaml redis
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Ops, nao foi possivel subir a stack do Redis."
#fi

## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

cat > dados_redis${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ REDIS ]

Host: redis${1:+_$1}

Porta: 6379

Senha: Nao tem

Usuario: Nao tem
__FELSEN_MANAGED_FILE__
cd
cd

## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ REDIS ]\e[0m"
echo ""

echo -e "\e[97mHost:\e[33m redis${1:+_$1}\e[0m"
echo ""

echo -e "\e[97mPorta:\e[33m 6379\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m Nao tem\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

cd
cd

}

## ####   #######   ########### ####### ###     
## a-a-a-a-a-- a-a-a-a-a-'a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-'     
## a-a-a-"a-a-a-a-a-"a-a-a-' a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-'     
## a-a-a-'a-a-a-a-"a-a-a-a-'  a-a-a-a-"a-  a-a-a-a-a-a-a-a-'a-a-a-'a-"a-" a-a-a-'a-a-a-'     
## a-a-a-' a-a-a- a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--
## a-a-a-     a-a-a-   a-a-a-   a-a-a-a-a-a-a-a- a-a-a-a-EURa-EURa-a- a-a-a-a-a-a-a-a-

