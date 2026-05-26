#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_wiki() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_wiki

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Wiki.JS (ex: wiki.example.com): \e[0m" && read -r url_wiki
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_wiki
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do wiki
    echo -e "\e[33mDominio do Wiki:\e[97m $url_wiki\e[0m"
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
        nome_wiki

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO WIKI \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO WIKI \e[33m[2/3]\e[0m"
echo ""
sleep 1

wiki_postgres_password=$(openssl rand -hex 16)

## Criando a stack wikijs.yaml
cat > wiki${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  wiki${1:+_$1}_app:
    image: requarks/wiki:latest ## Versao da aplicacao

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Dados do Postgres
      - DB_TYPE=postgres
      - DB_HOST=wiki${1:+_$1}_db
      - DB_PORT=5432
      - DB_USER=wikijs
      - DB_PASS=$wiki_postgres_password ## Senha para o Postgres
      - DB_NAME=wiki
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.wiki${1:+_$1}_app.rule=Host(\`$url_wiki\`) ## Dominio para aplicacao
        - traefik.http.routers.wiki${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.wiki${1:+_$1}_app.priority=1
        - traefik.http.routers.wiki${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.wiki${1:+_$1}_app.service=wiki${1:+_$1}_app
        - traefik.http.services.wiki${1:+_$1}_app.loadbalancer.server.port=3000
        - traefik.http.services.wiki${1:+_$1}_app.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  wiki${1:+_$1}_db:
    image: postgres:15-alpine ## Versao do Postgres

    volumes:
      - wiki${1:+_$1}_db:/var/lib/postgresql/data

    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
      - POSTGRES_DB=wiki
      - POSTGRES_PASSWORD=$wiki_postgres_password ## Senha para o Postgres
      - POSTGRES_USER=wikijs
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##
  
volumes:
  wiki${1:+_$1}_db:
    external: true
    name: wiki${1:+_$1}_db

networks:
  $nome_rede_interna: ## Sua Rede interna
    external: true
    name: $nome_rede_interna ## Sua Rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do wiki"
fi
STACK_NAME="wiki${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c wiki.yaml wiki > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do wiki"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull requarks/wiki:latest postgres:15-alpine

## Usa o servico wait_wiki para verificar se o servico esta online
wait_stack wiki${1:+_$1}_wiki${1:+_$1}_db wiki${1:+_$1}_wiki${1:+_$1}_app


cd dados_vps

cat > dados_wiki${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ WIKI ]

Dominio do wiki: https://$url_wiki

Usuario: Precisa criar no primeiro acesso do wiki

Senha: Precisa criar no primeiro acesso do wiki

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
echo -e "\e[32m[ WIKI ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_wiki\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do wiki\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do wiki\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ###### ###########   ##########  ######  ####### ###### #################
## a-a-a-"a-a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-
## a-a-a-a-a-a-a-a-'  a-a-a-a-"a- a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   
## a-a-a-"a-a-a-a-a-' a-a-a-a-"a-  a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'   
## a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'   
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-   a-a-a-                                                                         

