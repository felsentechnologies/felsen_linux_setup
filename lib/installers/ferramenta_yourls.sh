#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_yourls() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_yourls

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o Yourls (ex: yourls.example.com): \e[0m" && read -r url_yourls
    echo ""
    
    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o Usuario (ex: Felsen): \e[0m" && read -r user_yourls
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite a Senha do usuario (ex: @Senha123_): \e[0m" && read -r pass_yourls
    echo ""
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_yourls
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do yourls
    echo -e "\e[33mDominio do Yourls:\e[97m $url_yourls\e[0m"
    echo ""

    ## Informacao sobre URL do yourls
    echo -e "\e[33mUsuario:\e[97m $user_yourls\e[0m"
    echo ""

    ## Informacao sobre URL do yourls
    echo -e "\e[33mSenha:\e[97m $pass_yourls\e[0m"
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
        nome_yourls

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO YOURLS \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO MYSQL \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Cria banco de dados do site no mysql
verificar_container_mysql
    if [ $? -eq 0 ]; then
        echo "1/3 - [ OK ] - MySQL ja instalado"
        pegar_senha_mysql > /dev/null 2>&1
        echo "2/3 - [ OK ] - Copiando senha do MySQL"
        criar_banco_mysql_da_stack "yourls${1:+_$1}"
        echo "3/3 - [ OK ] - Criando banco de dados"
        echo ""
    else
        ferramenta_mysql
        pegar_senha_mysql > /dev/null 2>&1
        criar_banco_mysql_da_stack "yourls${1:+_$1}"
    fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO YOURLS \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack yourls.yaml
cat > yourls${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  yourls${1:+_$1}:
    image: yourls:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Dados de acesso
      - YOURLS_SITE=https://$url_yourls ## Url da Aplicacao
      - YOURLS_USER=$user_yourls
      - YOURLS_PASS=$pass_yourls
      
    ##  Dados do Mysql
      - YOURLS_DB_HOST=mysql
      - YOURLS_DB_NAME=yourls${1:+_$1}
      - YOURLS_DB_USER=root
      - YOURLS_DB_PASS=$senha_mysql

    deploy:
      mode: replicated
      replicas: 1
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.yourls${1:+_$1}.rule=Host(\`$url_yourls\`) ## Url da aplicacao
        - traefik.http.routers.yourls${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.yourls${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.yourls${1:+_$1}.service=yourls${1:+_$1}
        - traefik.http.services.yourls${1:+_$1}.loadbalancer.server.port=8080
        - traefik.http.routers.yourls.tls=true

## --------------------------- FELSEN --------------------------- ##

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Yourls"
fi
STACK_NAME="yourls${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c yourls.yaml yourls > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do yourls"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull yourls:latest

## Usa o servico wait_stack "yourls" para verificar se o servico esta online
wait_stack yourls${1:+_$1}_yourls${1:+_$1}


cd dados_vps

cat > dados_yourls${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ YOURLS ]

Dominio do Yourls: https://$url_yourls/admin

Usuario: $user_yourls

Senha: $pass_yourls

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
echo -e "\e[32m[ YOURLS ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_yourls/admin\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_yourls\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_yourls\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ############    ###############   ###############   ### ############## ####   ####
## a-a-a-a-a-a-"a-a-a-a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'
##    a-a-a-'   a-a-a-' a-a-- a-a-a-'a-a-a-a-a-a--  a-a-a-"a-a-a-- a-a-a-'   a-a-a-'    a-a-a-a-a-a-"a- a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-"a-a-a-'
##    a-a-a-'   a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'   a-a-a-'     a-a-a-a-"a-  a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-"a-a-a-a-'
##    a-a-a-'   a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'   a-a-a-'      a-a-a-'   a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'
##    a-a-a-    a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-      a-a-a-    a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-
                                                                                  

