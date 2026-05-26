#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_mautic() {

## Verifica os recursos
recursos 2 2 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_mautic

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o Mautic (ex: mautic.example.com): \e[0m" && read -r url_mautic
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_mautic
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Mautic:\e[97m $url_mautic\e[0m"
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
        nome_mautic

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO MAUTIC \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO MYSQL \e[33m[2/4]\e[0m"
echo ""
sleep 1

dados

## Cria banco de dados do site no mysql
verificar_container_mysql
    if [ $? -eq 0 ]; then
        echo "1/3 - [ OK ] - MySQL ja instalado"
        pegar_senha_mysql > /dev/null 2>&1
        echo "2/3 - [ OK ] - Copiando senha do MySQL"
        criar_banco_mysql_da_stack "mautic${1:+_$1}"
        echo "3/3 - [ OK ] - Criando banco de dados"
        echo ""
    else
        ferramenta_mysql
        pegar_senha_mysql > /dev/null 2>&1
        criar_banco_mysql_da_stack "mautic${1:+_$1}"
    fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO MAUTIC \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack mautic.yaml
cat > mautic${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  mautic_web${1:+_$1}:
    image: mautic/mautic:5.2.8-apache ## Versao do Mautic

    volumes:
      - mautic${1:+_$1}_config:/var/www/html/config
      - mautic${1:+_$1}_docroot:/var/www/html/docroot
      - mautic${1:+_$1}_media:/var/www/html/docroot/media
      - mautic${1:+_$1}_logs:/var/www/html/var/logs
      - mautic${1:+_$1}_cron:/opt/mautic/cron

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Url de acesso
      - MAUTIC_URL=https://$url_mautic

    ## -"i Dados MySQL
      - MAUTIC_DB_NAME=mautic${1:+_$1}
      - MAUTIC_DB_HOST=mysql
      - MAUTIC_DB_PORT=3306
      - MAUTIC_DB_USER=root
      - MAUTIC_DB_PASSWORD=$senha_mysql

    ##  Configuracoes
      - MAUTIC_TRUSTED_PROXIES=["0.0.0.0/0"]
      - DOCKER_MAUTIC_ROLE=mautic_web
      - DOCKER_MAUTIC_WORKERS_CONSUME_EMAIL=2
      - DOCKER_MAUTIC_WORKERS_CONSUME_HIT=2
      - DOCKER_MAUTIC_WORKERS_CONSUME_FAILED=2

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 2048M
      labels:
        - traefik.enable=true
        - traefik.http.routers.mautic${1:+_$1}.rule=Host(\`$url_mautic\`) # substitua SeuDominio.com.br pelo seu dominio
        - traefik.http.services.mautic${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.mautic${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.mautic${1:+_$1}.service=mautic${1:+_$1}
        - traefik.http.routers.mautic${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.mautic${1:+_$1}.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  mautic_worker${1:+_$1}:
    image: mautic/mautic:5.2.8-apache ## Versao do Mautic

    volumes:
      - mautic${1:+_$1}_config:/var/www/html/config
      - mautic${1:+_$1}_docroot:/var/www/html/docroot
      - mautic${1:+_$1}_media:/var/www/html/docroot/media
      - mautic${1:+_$1}_logs:/var/www/html/var/logs
      - mautic${1:+_$1}_cron:/opt/mautic/cron

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Url de acesso
      - MAUTIC_URL=https://$url_mautic

    ## -"i Dados MySQL
      - MAUTIC_DB_NAME=mautic${1:+_$1}
      - MAUTIC_DB_HOST=mysql
      - MAUTIC_DB_PORT=3306
      - MAUTIC_DB_USER=root
      - MAUTIC_DB_PASSWORD=$senha_mysql

    ##  Configuracoes
      - MAUTIC_TRUSTED_PROXIES=["0.0.0.0/0"]
      - DOCKER_MAUTIC_ROLE=mautic_web
      - DOCKER_MAUTIC_WORKERS_CONSUME_EMAIL=2
      - DOCKER_MAUTIC_WORKERS_CONSUME_HIT=2
      - DOCKER_MAUTIC_WORKERS_CONSUME_FAILED=2

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 2048M

## --------------------------- FELSEN --------------------------- ##

  mautic_cron${1:+_$1}:
    image: mautic/mautic:5.2.8-apache ## Versao do Mautic

    volumes:
      - mautic${1:+_$1}_config:/var/www/html/config
      - mautic${1:+_$1}_docroot:/var/www/html/docroot
      - mautic${1:+_$1}_media:/var/www/html/docroot/media
      - mautic${1:+_$1}_logs:/var/www/html/var/logs
      - mautic${1:+_$1}_cron:/opt/mautic/cron

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Url de acesso
      - MAUTIC_URL=https://$url_mautic

    ## -"i Dados MySQL
      - MAUTIC_DB_NAME=mautic${1:+_$1}
      - MAUTIC_DB_HOST=mysql
      - MAUTIC_DB_PORT=3306
      - MAUTIC_DB_USER=root
      - MAUTIC_DB_PASSWORD=$senha_mysql

    ##  Configuracoes
      - MAUTIC_TRUSTED_PROXIES=["0.0.0.0/0"]
      - DOCKER_MAUTIC_ROLE=mautic_web
      - DOCKER_MAUTIC_WORKERS_CONSUME_EMAIL=2
      - DOCKER_MAUTIC_WORKERS_CONSUME_HIT=2
      - DOCKER_MAUTIC_WORKERS_CONSUME_FAILED=2

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 512M

## --------------------------- FELSEN --------------------------- ##

volumes:
  mautic${1:+_$1}_config:
    external: true
    name: mautic${1:+_$1}_config
  mautic${1:+_$1}_docroot:
    external: true
    name: mautic${1:+_$1}_docroot
  mautic${1:+_$1}_media:
    external: true
    name: mautic${1:+_$1}_media
  mautic${1:+_$1}_logs:
    external: true
    name: mautic${1:+_$1}_logs
  mautic${1:+_$1}_cron:
    external: true
    name: mautic${1:+_$1}_cron

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Mautic"
fi
STACK_NAME="mautic${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c mautic.yaml mautic > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Mautic"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull mautic/mautic:5.2.8-apache

## Usa o servico wait_stack "mautic" para verificar se o servico esta online
wait_stack mautic${1:+_$1}_mautic_web${1:+_$1} mautic${1:+_$1}_mautic_worker${1:+_$1} mautic${1:+_$1}_mautic_cron${1:+_$1}


cd dados_vps

cat > dados_mautic${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ MAUTIC 5 ]

Dominio do Mautic: $url_mautic

Email: Precisa de criar no primeiro acesso do Mautic

Senha: Precisa de criar no primeiro acesso do Mautic

Database Name: mautic${1:+_$1}

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
echo -e "\e[32m[ MAUTIC 5 ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_mautic\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Precisa de criar no primeiro acesso do Mautic\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar no primeiro acesso do Mautic\e[0m"
echo ""

echo -e "\e[33mDatabase Name:\e[97m mautic${1:+_$1}\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ###### ####### ####### ############   ###################  ###
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-- a-a-a-a-a-'a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'  a-a-a-'
## a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-'
## a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a- a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'   a-a-a-'   a-a-a-"a-a-a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-'     a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-' a-a-a- a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'  a-a-a-'
## a-a-a-  a-a-a-a-a-a-     a-a-a-     a-a-a-a-a-a-a-a-a-a-a-     a-a-a-a-a-a-   a-a-a-   a-a-a-  a-a-a-
                                                               
