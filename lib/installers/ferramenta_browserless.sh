#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_browserless() {

## Verifica os recursos
recursos 2 4 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_browserless

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Browserless (ex: browserless.example.com): \e[0m" && read -r url_browserless
    echo ""
  
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_browserless
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do browserless
    echo -e "\e[33mDominio do Browserless:\e[97m $url_browserless\e[0m"
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
        nome_browserless

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO BROWSERLESS \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO BROWSERLESS \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack browserless.yaml
cat > browserless${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  browserless${1:+_$1}:
    image: browserless/chrome:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracoes de Performance
      - MAX_CONCURRENT_SESSIONS=20
      - MAX_QUEUE_LENGTH=40
      - CONNECTION_TIMEOUT=60000

    ## -'i Configuracoes de Workspaces
      - WORKSPACE_DELETE_EXPIRED=1
      - WORKSPACE_EXPIRE_DAYS=1
      - PREBOOT_CHROME=1
      - KEEP_ALIVE=1

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M
      labels:
        - traefik.enable=true
        - traefik.http.routers.browserless${1:+_$1}.rule=Host(\`$url_browserless\`)
        - traefik.http.services.browserless${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.browserless${1:+_$1}.service=browserless${1:+_$1}
        - traefik.http.routers.browserless${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.browserless${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.browserless${1:+_$1}.tls=true

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
    echo "Nao foi possivel criar a stack do browserless"
fi
STACK_NAME="browserless${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c browserless.yaml browserless > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do browserless"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull browserless/chrome:latest

## Usa o servico wait_browserless para verificar se o servico esta online
wait_stack browserless${1:+_$1}_browserless${1:+_$1}


cd dados_vps

cat > dados_browserless${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ BROWSERLESS ]

Dominio do browserless: https://$url_browserless

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
echo -e "\e[32m[ BROWSERLESS ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_browserless\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ############## ####### ####   ##############  ############
## a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-"a-a-a-
## a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a--   a-a-a-a-a-"a-    a-a-a-'   
## a-a-"a-a-a-  a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a- a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-   a-a-a-"a-a-a--    a-a-a-'   
## a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-'     a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-"a- a-a-a--   a-a-a-'   
## a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-   a-a-a-   

