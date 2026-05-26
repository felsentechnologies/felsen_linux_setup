#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_nextcloud() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_nextcloud

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o NextCloud (ex: nextcloud.example.com): \e[0m" && read -r url_nextcloud
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o Usuario para o NextCloud (ex: FELSEN): \e[0m" && read -r user_nextcloud
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "$amarelo--> Minimo 8 caracteres. Use Letras MAIUSCULAS e minusculas, numero e um caractere especial @ ou _"
    echo -en "\e[33mDigite o Senha o Usuario (ex: @Senha123_): \e[0m" && read -r pass_nextcloud
    echo ""


    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_nextcloud
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do nextcloud
    echo -e "\e[33mDominio do NextCloud:\e[97m $url_nextcloud\e[0m"
    echo ""

    ## Informacao sobre URL do nextcloud
    echo -e "\e[33mUsuario do NextCloud:\e[97m $user_nextcloud\e[0m"
    echo ""

    ## Informacao sobre URL do nextcloud
    echo -e "\e[33mSenha do NextCloud:\e[97m $pass_nextcloud\e[0m"
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
        nome_minio

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO NEXTCLOUD \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "nextcloud${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "nextcloud${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO NEXTCLOUD \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack nextcloud.yaml
cat > nextcloud${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  nextcloud${1:+_$1}_app:
    image: nextcloud:latest

    volumes:
      - nextcloud${1:+_$1}_data:/var/www/html

    networks:
      - $nome_rede_interna

    #ports:
    #  - 8282:80

    environment:
    ## " Dados de acesso:
      - NEXTCLOUD_ADMIN_USER=$user_nextcloud
      - NEXTCLOUD_ADMIN_PASSWORD=$pass_nextcloud

    ##  Dados do Postgres
      - POSTGRES_HOST=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_DB=nextcloud${1:+_$1}
      - POSTGRES_PASSWORD=$senha_postgres

    ##  Dados do Redis
      - REDIS_HOST=nextcloud${1:+_$1}_redis

    ##  Configuracoes para HTTPS
      - OVERWRITEPROTOCOL=https
      - TRUSTED_PROXIES=127.0.0.1

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.nextcloud${1:+_$1}_app.rule=Host(\`$url_nextcloud\`)
        - traefik.http.services.nextcloud${1:+_$1}_app.loadbalancer.server.port=80
        - traefik.http.routers.nextcloud${1:+_$1}_app.service=nextcloud${1:+_$1}_app
        - traefik.http.routers.nextcloud${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.nextcloud${1:+_$1}_app.entrypoints=web,websecure
        - traefik.http.routers.nextcloud${1:+_$1}_app.tls=true
        - traefik.http.routers.nextcloud${1:+_$1}_app.middlewares=nextcloud${1:+_$1}_app_redirectregex
        - traefik.http.middlewares.nextcloud${1:+_$1}_app_redirectregex.redirectregex.permanent=true
        - traefik.http.middlewares.nextcloud${1:+_$1}_app_redirectregex.redirectregex.regex=https://(.*)/.well-known/(?:card|cal)dav
        - traefik.http.middlewares.nextcloud${1:+_$1}_app_redirectregex.redirectregex.replacement=https://$$1/remote.php/dav

## --------------------------- FELSEN --------------------------- ##

  nextcloud${1:+_$1}_cron:
    image: nextcloud:latest
    entrypoint: /cron.sh

    volumes:
      - nextcloud${1:+_$1}_data:/var/www/html

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  nextcloud${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - nextcloud${1:+_$1}_redis:/data

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
  nextcloud${1:+_$1}_data:
    external: true
    name: nextcloud${1:+_$1}_data
  nextcloud${1:+_$1}_redis:
    external: true
    name: nextcloud${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do nextcloud"
fi
STACK_NAME="nextcloud${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c nextcloud.yaml nextcloud > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do nextcloud"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull nextcloud:latest


## Usa o servico wait_nextcloud para verificar se o servico esta online
wait_stack nextcloud${1:+_$1}_nextcloud${1:+_$1}_redis nextcloud${1:+_$1}_nextcloud${1:+_$1}_app nextcloud${1:+_$1}_nextcloud${1:+_$1}_cron


cd dados_vps

# Caminho do arquivo onde a substituicao sera feita
wait_30_sec
arquivo_next_cloud="/var/lib/docker/volumes/nextcloud${1:+_$1}_data/_data/config/config.php"

# Comando sed para substituir a linha, utilizando a variavel
sed -i "s/0 => 'localhost'/0 => '$url_nextcloud'/" "$arquivo_next_cloud"
sleep 5
## So por garantia
sed -i "s/0 => 'localhost'/0 => '$url_nextcloud'/" "$arquivo_next_cloud"
sleep 5
sed -i "/'maintenance' => false,/a \  'overwriteprotocol' => 'https',\n  'trusted_proxies' => ['127.0.0.1']," "$arquivo_next_cloud"
sleep 5

cat > dados_nextcloud${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ NEXTCLOUD ]

Dominio do NextCloud: https://$url_nextcloud

Usuario: $user_nextcloud

Senha: $pass_nextcloud
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
echo -e "\e[32m[ NEXTCLOUD ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_nextcloud\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_nextcloud\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_nextcloud\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ########################  ###### ####### ###
## a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'
## a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'
## a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-'
## #######|   ##|   ##|  ##|##|  ##|##|     ##|
## a-a-a-a-a-a-a-a-   a-a-a-   a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-
                                                           
