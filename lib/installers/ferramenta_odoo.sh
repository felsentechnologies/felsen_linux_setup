#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_odoo() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_odoo

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o Odoo (ex: odoo.example.com): \e[0m" && read -r url_odoo
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -e "$amarelo--> 1 = 19.0"
    echo -e "$amarelo--> 2 = 18.0"
    echo -e "$amarelo--> 3 = 17.0"
    echo -e "$amarelo--> 4 = 16.0"
    echo -en "\e[33mDigite a versao desejada para o Odoo (ex: 1): \e[0m" && read -r versao_odoo
    echo ""+
    if [ "$versao_odoo" = "1" ]; then
        odoo_version_selected="19.0"
    elif [ "$versao_odoo" = "2" ]; then
        odoo_version_selected="18.0"
    elif [ "$versao_odoo" = "4" ]; then
        odoo_version_selected="17.0"
    elif [ "$versao_odoo" = "5" ]; then
        odoo_version_selected="16.0"
    else
        echo -e "\e[31mOpcao invalida. Usando versao '19.0' por padrao.\e[0m"
        odoo_version_selected="19.0"
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_odoo
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o Odoo:\e[97m $url_odoo\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mVersao do Odoo:\e[97m $odoo_version_selected\e[0m"
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
        nome_odoo

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO ODOO \e[33m[1/3]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO ODOO \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando senha do postgres
senha_postgres_odoo=$(openssl rand -hex 16)

## Criando a stack odoo.yaml
cat > odoo${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  odoo${1:+_$1}_app:
    image: odoo:$odoo_version_selected

    volumes:
      - odoo${1:+_$1}_app_data:/var/lib/odoo
      - odoo${1:+_$1}_app_config:/etc/odoo
      - odoo${1:+_$1}_app_addons:/mnt/extra-addons

    networks:
      - $nome_rede_interna

    environment:
    ## -"i Dados postgres do Odoo
      - HOST=odoo${1:+_$1}_db
      - USER=odoo
      - PASSWORD=$senha_postgres_odoo

    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.odoo${1:+_$1}_app.rule=Host(\`$url_odoo\`)
        - traefik.http.routers.odoo${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.odoo${1:+_$1}_app.tls=true
        - traefik.http.routers.odoo${1:+_$1}_app.service=odoo${1:+_$1}_app
        - traefik.http.routers.odoo${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.services.odoo${1:+_$1}_app.loadbalancer.server.port=8069

## --------------------------- FELSEN --------------------------- ##

  odoo${1:+_$1}_db:
    image: postgres:15

    volumes:
      - odoo${1:+_$1}_db_data:/var/lib/postgresql/data/pgdata

    networks:
      - $nome_rede_interna
    #ports:
    #  - 5434:5432

    environment:
    ## -"i Dados Postgres
      - POSTGRES_DB=postgres
      - POSTGRES_PASSWORD=$senha_postgres_odoo
      - POSTGRES_USER=odoo
      - PGDATA=/var/lib/postgresql/data/pgdata
    deploy:
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

volumes:
  odoo${1:+_$1}_app_data:
    external: true
    name: odoo${1:+_$1}_app_data
  odoo${1:+_$1}_app_config:
    external: true
    name: odoo${1:+_$1}_app_config
  odoo${1:+_$1}_app_addons:
    external: true
    name: odoo${1:+_$1}_app_addons
  odoo${1:+_$1}_db_data:
    external: true
    name: odoo${1:+_$1}_db_data

networks:
  $nome_rede_interna:
    external: true
    attachable: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do odoo"
fi
STACK_NAME="odoo${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c odoo.yaml odoo > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Odoo"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull postgres:15 odoo:$odoo_version_selected

## Usa o servico wait_odoo para verificar se o servico esta online
wait_stack odoo${1:+_$1}_odoo${1:+_$1}_app odoo${1:+_$1}_odoo${1:+_$1}_db


cd dados_vps

cat > dados_odoo${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ ODOO ]

Dominio do odoo: https://$url_odoo

Usuario: Precisa criar no primeiro acesso do Odoo

Senha: Precisa criar no primeiro acesso do Odoo

Database Name: odoo

Database Password: $senha_postgres_odoo
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
echo -e "\e[32m[ ODOO ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_odoo\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Odoo\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Odoo\e[0m"
echo ""

echo -e "\e[33mDatabase Name:\e[97m odoo\e[0m"
echo ""

echo -e "\e[33mDatabase Password:\e[97m $senha_postgres_odoo\e[0m"

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
##
##         ####   ############################ ####### ####### 
##         a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--
##         a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-
##         a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-  a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--
##         a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'
##         a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-   a-a-a-    a-a-a-a-a-a-a- a-a-a-  a-a-a-
                                                    
                                                               
