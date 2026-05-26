#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_metabase() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_metabase

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Metabase (ex: metabase.example.com): \e[0m" && read -r url_metabase
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_metabase
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o metabase:\e[97m $url_metabase\e[0m"
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
        nome_metabase

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO METABASE \e[33m[1/4]\e[0m"
echo ""
sleep 1

## NADA

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Ja sabe ne ksk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "metabase${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "metabase${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO METABASE \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria 64caracteres
key_secret=$(openssl rand -hex 32)

## Criando key Aleatoria 32caracteres
key_salt=$(openssl rand -hex 16)

## Criando a stack metabase.yaml
cat > metabase${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  metabase${1:+_$1}:
    image: metabase/metabase:latest

    volumes:
      - metabase${1:+_$1}_data:/metabase3-data

    networks:
      - $nome_rede_interna

    environment:
    ##  Url MetaBase
      - MB_SITE_URL=https://$url_metabase
      - MB_REDIRECT_ALL_REQUESTS_TO_HTTPS=true
      - MB_JETTY_PORT=3000
      - MB_JETTY_HOST=0.0.0.0

    ## -"i Dados postgres
      - MB_DB_TYPE=postgres
      - MB_DB_HOST=postgres
      - MB_DB_PORT=5432
      - MB_DB_DBNAME=metabase${1:+_$1}
      - MB_DB_USER=postgres
      - MB_DB_PASS=$senha_postgres
      - MB_DB_MIGRATION_LOCATION=none
      - MB_AUTOMIGRATE=false

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.metabase${1:+_$1}.rule=Host(\`$url_metabase\`)
        - traefik.http.services.metabase${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.metabase${1:+_$1}.service=metabase${1:+_$1}
        - traefik.http.routers.metabase${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.metabase${1:+_$1}.tls=true
        - traefik.http.routers.metabase${1:+_$1}.tls.certresolver=letsencryptresolver

## --------------------------- FELSEN --------------------------- ##

volumes:
  metabase${1:+_$1}_data:
    external: true
    name: metabase${1:+_$1}_data

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do metabase"
fi
STACK_NAME="metabase${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c metabase.yaml metabase > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do metabase"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull metabase/metabase:latest

## Usa o servico wait_stack "metabase" para verificar se o servico esta online
wait_stack metabase${1:+_$1}_metabase${1:+_$1}


cd dados_vps

cat > dados_metabase${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ METABASE ]

Dominio do metabase: https://$url_metabase

Usuario: Precisa criar no primeiro acesso do metabase

Senha: Precisa criar no primeiro acesso do metabase
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
echo -e "\e[32m[ METABASE ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_metabase\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do metabase\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do metabase\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### #######  #######  ####### 
## a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a--
## ##|   ##|##|  ##|##|   ##|##|   ##|
## ##|   ##|##|  ##|##|   ##|##|   ##|
## a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-
##  a-a-a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a-  a-a-a-a-a-a-a- 
                                   
