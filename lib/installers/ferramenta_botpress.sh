#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_botpress() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_botpress

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Botpress (ex: botpress.example.com): \e[0m" && read -r url_botpress
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_botpress
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Botpress
    echo -e "\e[33mDominio do Botpress:\e[97m $url_botpress\e[0m"
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
        nome_botpress

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO BOTPRESS \e[33m[1/5]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/5]\e[0m"
echo ""
sleep 1

## Cansei ja de explicar o que isso faz kkkk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "botpress${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "botpress${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO BOTPRESS \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Criando a stack botpress.yaml
cat > botpress${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  botpress${1:+_$1}_app:
    image: botpress/server:latest

    volumes:
      - botpress${1:+_$1}_data:/botpress/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Url Botpress
      - EXTERNAL_URL=https://$url_botpress

    ## Modo
      - BP_PRODUCTION=true

    ##  Dados Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/botpress${1:+_$1}

    ##  Dados Redis
      - REDIS_URL=redis://redis:6379

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
      labels:
        - traefik.enable=true
        - traefik.http.routers.botpress${1:+_$1}.rule=Host(\`$url_botpress\`)
        - traefik.http.services.botpress${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.botpress${1:+_$1}.service=botpress${1:+_$1}
        - traefik.http.routers.botpress${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.botpress${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.botpress${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  botpress${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - botpress${1:+_$1}_redis:/data

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
  botpress${1:+_$1}_data:
    external: true
    name: botpress${1:+_$1}_data
  botpress${1:+_$1}_redis:
    external: true
    name: botpress${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Botpress"
fi
STACK_NAME="botpress${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c botpress.yaml botpress > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Botpress"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest botpress/server:latest

## Usa o servico wait_botpress para verificar se o servico esta online
wait_stack botpress${1:+_$1}_botpress${1:+_$1}_redis botpress${1:+_$1}_botpress${1:+_$1}_app


cd dados_vps

cat > dados_botpress${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ BOTPRESS ]

Dominio do Botpress: https://$url_botpress

Usuario: Precisa criar no primeiro acesso do Botpress

Senha: Precisa criar no primeiro acesso do Botpress

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
echo -e "\e[32m[ BOTPRESS ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_botpress\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Botpress\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Botpress\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}


## ###    ### ####### ####### ####### ####### ####### ########################
## a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-' a-a-- a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'
##  a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-a-a-a-a- a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

