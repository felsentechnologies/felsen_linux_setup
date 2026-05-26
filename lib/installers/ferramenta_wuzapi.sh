#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_wuzapi() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_wuzapi

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Wuzapi (ex: wuzapi.example.com): \e[0m" && read -r url_wuzapi
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_wuzapi
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do wuzapi
    echo -e "\e[33mDominio do wuzapi:\e[97m $url_wuzapi\e[0m"
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
        nome_wuzapi

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO WUZAPI \e[33m[1/4]\e[0m"
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
    criar_banco_postgres_da_stack "wuzapi${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "wuzapi${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO WUZAPI \e[33m[3/4]\e[0m"
echo ""
sleep 1

apikey_wuzapi=$(openssl rand -hex 16)
encryption_key=$(openssl rand -hex 16)
## Criando a stack wuzapi.yaml
cat > wuzapi${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

 wuzapi${1:+_$1}:
  image: asternic/wuzapi:latest

  volumes:
    - wuzapi${1:+_$1}_dbdata:/app/dbdata
    - wuzapi${1:+_$1}_files:/app/files

  networks:
    - $nome_rede_interna ## Nome da rede interna

  environment:
  ##  Credencial
    - WUZAPI_ADMIN_TOKEN=$apikey_wuzapi
    - SECRET_KEY=$encryption_key

  ##  Dados do postgres
    - DB_HOST=postgres
    - DB_USER=postgres
    - DB_PASSWORD=$senha_postgres
    - DB_NAME=wuzapi${1:+_$1}
    - DB_PORT=5432
    - DB_DRIVER=postgres

  ##  Timezone
    - TZ=America/Sao_Paulo

  ## a Formato do webhook
    - WEBHOOK_FORMAT=json

  ##  Nome do dispositivo
    - SESSION_DEVICE_NAME=Felsen

  ## o Configuracoes do RabbitMQ
    #- RABBITMQ_URL=amqp://wuzapi:wuzapi@rabbitmq:5672/
    #- RABBITMQ_QUEUE=whatsapp_events

  deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      #resources:
      #  limits:
      #    cpus: "1"
      #    memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.wuzapi${1:+_$1}.rule=Host(\`$url_wuzapi\`)
        - traefik.http.services.wuzapi${1:+_$1}.loadbalancer.server.port=8080
        - traefik.http.routers.wuzapi${1:+_$1}.service=wuzapi${1:+_$1}
        - traefik.http.routers.wuzapi${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.wuzapi${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.wuzapi${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  wuzapi${1:+_$1}_dbdata:
    external: true
    name: wuzapi${1:+_$1}_dbdata
  wuzapi${1:+_$1}_files:
    external: true
    name: wuzapi${1:+_$1}_files

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do wuzapi"
fi
STACK_NAME="wuzapi${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c wuzapi.yaml wuzapi > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do wuzapi"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull asternic/wuzapi:latest

## Usa o servico wait_wuzapi para verificar se o servico esta online
wait_stack wuzapi${1:+_$1}_wuzapi${1:+_$1}


cd dados_vps

cat > dados_wuzapi${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ WUZAPI ]

Dominio do wuzapi: https://$url_wuzapi

Apikey: $apikey_wuzapi
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
echo -e "\e[32m[ WUZAPI ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_wuzapi\e[0m"
echo ""

echo -e "\e[33mDashboard:\e[97m https://$url_wuzapi/dashboard\e[0m"
echo ""

echo -e "\e[33mDocumentacao:\e[97m https://$url_wuzapi/api\e[0m"
echo ""

echo -e "\e[33mAPI Key:\e[97m $apikey_wuzapi\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ###  ##########  ###### ###   ##########   ###     ############## ####   ####
## a-a-a-' a-a-a-"a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-- a-a-a-"a-a-a-a-'a-a-a-a-a--  a-a-a-'    a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'
## a-a-a-a-a-a-"a- a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-' a-a-a-a-a-a-"a- a-a-a-'a-a-a-"a-a-a-- a-a-a-'    a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-"a-a-a-'
## a-a-a-"a-a-a-a-- a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'  a-a-a-a-"a-  a-a-a-'a-a-a-'a-a-a-a--a-a-a-'    a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-"a-a-a-a-'
## a-a-a-'  a-a-a--a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'   a-a-a-'   a-a-a-'a-a-a-' a-a-a-a-a-a-'    a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'
## a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-   a-a-a-   a-a-a-a-a-a-  a-a-a-a-a-     a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-
                                                                                      
