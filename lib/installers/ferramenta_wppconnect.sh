#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_wppconnect() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_wppconnect

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio do WPPConnect (ex: wppconnect.example.com): \e[0m" && read -r url_wppconnect
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_wppconnect
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do wppconnect
    echo -e "\e[33mDominio do WppConnect:\e[97m $url_wppconnect_front\e[0m"
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
        nome_wppconnect

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO WPPCONNECT \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO WPPCONNECT \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack wppconnect.yaml
cat > wppconnect${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  wppconnect${1:+_$1}_api:
    image: wppconnect/server-cli:latest

    volumes:
      - wppconnect${1:+_$1}_config:/usr/src/wpp-server
      
    networks:
      - $nome_rede_interna ## Nome da rede interna

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.wppconnect${1:+_$1}_api.rule=Host(\`$url_wppconnect\`) && PathPrefix(\`/\`) ## Url do wppconnect API
        - traefik.http.routers.wppconnect${1:+_$1}_api.entrypoints=websecure
        - traefik.http.routers.wppconnect${1:+_$1}_api.priority=1
        - traefik.http.routers.wppconnect${1:+_$1}_api.tls.certresolver=letsencryptresolver
        - traefik.http.routers.wppconnect${1:+_$1}_api.service=wppconnect${1:+_$1}_api
        - traefik.http.services.wppconnect${1:+_$1}_api.loadbalancer.server.port=21465
        - traefik.http.services.wppconnect${1:+_$1}_api.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  wppconnect${1:+_$1}_config:
    external: true
    name: wppconnect${1:+_$1}_config

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do wppconnect"
fi
STACK_NAME="wppconnect${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c wppconnect.yaml wppconnect > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do wppconnect"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull wppconnect/server-cli:latest

## Usa o servico wait_wppconnect para verificar se o servico esta online
wait_stack wppconnect${1:+_$1}_wppconnect${1:+_$1}_api


cd dados_vps

cat > dados_wppconnect${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ WPPCONNECT ]

Dominio Front: https://$url_wppconnect

Documentacao: https://$url_wppconnect/api-docs
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
echo -e "\e[32m[ WPPCONNECT ]\e[0m"
echo ""

echo -e "\e[33mDominio API:\e[97m https://$url_wppconnect\e[0m"
echo ""

echo -e "\e[33mDocumentacao: \e[97m https://$url_wppconnect/api-docs\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####### #######  ####### ###    ########################## ###     ########################
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-' a-a-- a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a--  a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-  a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-a-a-a-a- a-a-a-  a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

