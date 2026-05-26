#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_openwebui() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_openwebui

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o OpenWebUI (ex: openwebui.example.com): \e[0m" && read -r url_openwebui
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_openwebui
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o OpenWebUI:\e[97m $url_openwebui\e[0m"
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
        nome_openwebui

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO OPENWEBUI \e[33m[1/4]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO OPENWEBUI \e[33m[3/4]\e[0m"
echo ""
sleep 1

WEBUI_SECRET_KEY=$(openssl rand -hex 16)

## Criando a stack openwebui.yaml
cat > openwebui${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  openwebui${1:+_$1}_app:
    image: ghcr.io/open-webui/open-webui:main

    volumes:
      - openwebui${1:+_$1}_data:/app/backend/data

    networks:
      - $nome_rede_interna

    #ports:
    #  - 8085:8080

    environment:
    ##  Base URL API
      #- OLLAMA_BASE_URL=https://

    ## " Secret Key
      - WEBUI_SECRET_KEY=$WEBUI_SECRET_KEY

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.openwebui${1:+_$1}_app.rule=Host(\`$url_openwebui\`)
        - traefik.http.routers.openwebui${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.openwebui${1:+_$1}_app.priority=1
        - traefik.http.routers.openwebui${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.openwebui${1:+_$1}_app.service=openwebui${1:+_$1}_app
        - traefik.http.services.openwebui${1:+_$1}_app.loadbalancer.server.port=8080
        - traefik.http.services.openwebui${1:+_$1}_app.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  openwebui${1:+_$1}_data:
    external: true
    name: openwebui${1:+_$1}_data
  
networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do openwebui"
fi
STACK_NAME="openwebui${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c openwebui.yaml openwebui > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do openwebui"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/open-webui/open-webui:main

## Usa o servico wait_nocodb para verificar se o servico esta online
wait_stack openwebui${1:+_$1}_openwebui${1:+_$1}_app


cd dados_vps

cat > dados_openwebui${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ OPENWEBUI ]

Dominio do Open WebUI: https://$url_openwebui

Usuario: Precisa de criar ao fazer o primeiro login

Senha: Precisa de criar ao fazer o primeiro login

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
echo -e "\e[32m[ OPENWEBUI ]\e[0m"
echo ""

echo -e "\e[33mOpen OpenWebUI:\e[97m https://$url_openwebui\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa de criar ao fazer o primeiro login\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar ao fazer o primeiro login\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## Ignore esta parte, so para facilitar minha identificacao com esta parte "XXOOXX"

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Comandos extras

