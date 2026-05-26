#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_strapi() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_strapi

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Strapi (ex: strapi.example.com): \e[0m" && read -r url_strapi
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_strapi
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o strapi:\e[97m $url_strapi\e[0m"
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
        nome_strapi

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO STRAPI \e[33m[1/4]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres Instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "strapi${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "strapi${1:+_$1}"
fi

pegar_senha_postgres > /dev/null 2>&1

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO STRAPI \e[33m[3/4]\e[0m"
echo ""
sleep 1

jwt_secret=$(openssl rand -hex 16)

admin_jwt=$(openssl rand -hex 16)

app_key=$(openssl rand -hex 16)

senha_mysql=$(openssl rand -hex 16)

## Criando a stack strapi.yaml
cat > strapi${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  strapi${1:+_$1}:
    image: strapi/strapi:latest

    volumes:
      - strapi${1:+_$1}_data:/srv/app

    networks:
      - $nome_rede_interna

    environment:
    ##  Dados Postgres
      - DATABASE_CLIENT=pg
      - DATABASE_HOST=postgres
      - DATABASE_NAME=strapi${1:+_$1}
      - DATABASE_PORT=5432
      - DATABASE_USERNAME=postgres
      - DATABASE_PASSWORD=$senha_postgres

    ## " Secret Keys
      - JWT_SECRET=$jwt_secret
      - ADMIN_JWT_SECRET=$admin_jwt
      - APP_KEYS=$app_key

    ##  Outros dados
      - NODE_ENV=production
      - STRAPI_TELEMETRY_DISABLED=true

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.strapi${1:+_$1}.rule=Host(\`$url_strapi\`)
        - traefik.http.routers.strapi${1:+_$1}.entrypoints=web,websecure
        - traefik.http.routers.strapi${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.strapi${1:+_$1}.service=strapi${1:+_$1}
        - traefik.http.services.strapi${1:+_$1}.loadbalancer.server.port=1337
        - traefik.http.services.strapi${1:+_$1}.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  strapi${1:+_$1}_data:
    external: true
    name: strapi${1:+_$1}_data

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Strapi"
fi
STACK_NAME="strapi${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c strapi.yaml strapi #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Strapi"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull strapi/strapi:latest

## Usa o servico wait_stack "strapi" para verificar se o servico esta online
wait_stack strapi${1:+_$1}_strapi${1:+_$1}

wait_30_sec
wait_30_sec


cd dados_vps

cat > dados_strapi${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ STRAPI ]

Dominio do Strapi: https://$url_strapi

Usuario: Precisa criar no primeiro acesso do Strapi

Senha: Precisa criar no primeiro acesso do Strapi
__FELSEN_MANAGED_FILE__
cd
cd

## Espera 30 segundos
wait_30_sec
wait_30_sec

## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ STRAPI ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_strapi\e[0m"
echo ""

echo -e "\e[33mSetup Inicial:\e[97m https://$url_strapi/admin\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do strapi\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do strapi\e[0m"
echo ""

echo "> Aguarde aproximadamente 5 minutos antes de acessar devido a migracao em andamento."

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####### ###  ##########     ####   #######   ###     ###### ####### ####   ###########   ###
## a-a-a-"a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a--    a-a-a-a-a-- a-a-a-a-a-'a-a-a-a-- a-a-a-"a-    a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'a-a-a-'a-a-a-a-a--  a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-    a-a-a-"a-a-a-a-a-"a-a-a-' a-a-a-a-a-a-"a-     a-a-a-a-a-a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-'a-a-a-"a-a-a-- a-a-a-'
## a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-     a-a-a-'a-a-a-a-"a-a-a-a-'  a-a-a-a-"a-      a-a-a-"a-a-a-a-a-'a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-'     a-a-a-'  a-a-a-'a-a-a-'         a-a-a-' a-a-a- a-a-a-'   a-a-a-'       a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'a-a-a-'a-a-a-' a-a-a-a-a-a-'
## a-a-a-     a-a-a-  a-a-a-a-a-a-         a-a-a-     a-a-a-   a-a-a-       a-a-a-  a-a-a-a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a-a-  a-a-a-a-a-
                                                                                                                                               
