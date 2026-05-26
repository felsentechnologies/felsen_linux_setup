#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_transcrevezap() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_transcrevezap

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/4\e[0m"
    echo -en "\e[33mDigite o dominio para a API do TranscreveZap (ex: apitranscreve.example.com): \e[0m" && read -r api_transcrevezap
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/4\e[0m"
    echo -en "\e[33mDigite o dominio para o Manager do TranscreveZap (ex: transcrevezap.example.com): \e[0m" && read -r url_transcrevezap
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/4\e[0m"
    echo -en "\e[33mDigite um usuario para o TranscreveZap (ex: Felsen): \e[0m" && read -r user_transcrevezap
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/4\e[0m"
    echo -en "\e[33mDigite uma senha para o TranscreveZap (ex: @Senha123_): \e[0m" && read -r pass_transcrevezap
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_transcrevezap
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do transcrevezap
    echo -e "\e[33mDominio da API TranscreveZap:\e[97m $api_transcrevezap\e[0m"
    echo ""

    ## Informacao sobre URL do transcrevezap
    echo -e "\e[33mDominio do Manager do TranscreveZap:\e[97m $url_transcrevezap\e[0m"
    echo ""

    ## Informacao sobre URL do transcrevezap
    echo -e "\e[33mUsuario do TranscreveZap:\e[97m $user_transcrevezap\e[0m"
    echo ""

    ## Informacao sobre URL do transcrevezap
    echo -e "\e[33mSenha do TranscreveZap:\e[97m $pass_transcrevezap\e[0m"
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
        nome_transcrevezap

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO TRANSCREVEZAP \e[33m[1/3]\e[0m"
echo ""
sleep 1




## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO TRANSCREVEZAP \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack transcrevezap.yaml
cat > transcrevezap${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__

version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  transcrevezap${1:+_$1}:
    image: impacteai/transcrevezap:latest
    command: ./start.sh

    networks:
      - $nome_rede_interna

    environment:
    ## " Configuracoes de Acesso
      - MANAGER_USER=$user_transcrevezap
      - MANAGER_PASSWORD=$pass_transcrevezap

    ## Configuracoes Globais
      - API_DOMAIN=$api_transcrevezap
      - UVICORN_PORT=8005
      - UVICORN_HOST=0.0.0.0
      - UVICORN_RELOAD=true
      - UVICORN_WORKERS=1

    ##  Configuracoes do Redis
      - REDIS_HOST=redis_transcrevezap${1:+_$1}
      - REDIS_PORT=6380

    ##  Configuracoes de Debug
      - DEBUG_MODE=false
      - LOG_LEVEL=INFO

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.transcrevezap${1:+_$1}.rule=Host(\`$api_transcrevezap\`) ## url do transcrevezap
        - traefik.http.routers.transcrevezap${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.transcrevezap${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.transcrevezap${1:+_$1}.loadbalancer.server.port=8005
        - traefik.http.services.transcrevezap${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.routers.transcrevezap${1:+_$1}.service=transcrevezap${1:+_$1}
        - traefik.http.middlewares.traefik-compress.compress=true
        - traefik.http.routers.transcrevezap${1:+_$1}.middlewares=traefik-compress
        - traefik.http.routers.transcrevezap${1:+_$1}_manager.rule=Host(\`$url_transcrevezap\`) ## url do manager do transcrevezap
        - traefik.http.routers.transcrevezap${1:+_$1}_manager.entrypoints=websecure
        - traefik.http.routers.transcrevezap${1:+_$1}_manager.tls.certresolver=letsencryptresolver
        - traefik.http.services.transcrevezap${1:+_$1}_manager.loadbalancer.server.port=8501
        - traefik.http.routers.transcrevezap${1:+_$1}_manager.service=transcrevezap${1:+_$1}_manager

## --------------------------- FELSEN --------------------------- ##

  redis_transcrevezap${1:+_$1}:
    image: redis:6
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6380"
      ]

    volumes:
      - redis_transcrevezap${1:+_$1}_data:/data

    networks:
      - $nome_rede_interna

## --------------------------- FELSEN --------------------------- ##

volumes:
  redis_transcrevezap${1:+_$1}_data:
    external: true
    name: redis_transcrevezap${1:+_$1}_data

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do TranscreveZap"
fi
STACK_NAME="transcrevezap${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c transcrevezap.yaml transcrevezap > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do transcrevezap"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull impacteai/transcrevezap:latest redis:6

## Usa o servico wait_transcrevezap para verificar se o servico esta online
wait_stack transcrevezap${1:+_$1}_transcrevezap${1:+_$1} transcrevezap${1:+_$1}_redis_transcrevezap${1:+_$1}


cd dados_vps

cat > dados_transcrevezap${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ TRANSCREVEZAP ]

Url API do TranscreveZap: https://$api_transcrevezap

Url Manager do TranscreveZap: https://$url_transcrevezap

Usuario: $user_transcrevezap

Senha: $pass_transcrevezap
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
echo -e "\e[32m[ TRANSCREVEZAP ]\e[0m"
echo ""

echo -e "\e[33mLink do Manager:\e[97m https://$url_transcrevezap\e[0m"
echo ""

echo -e "\e[33mLink da API:\e[97m https://$api_transcrevezap\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_transcrevezap\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_transcrevezap\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ####   ########   ############### #######  ####### ###     ########
## a-a-a-"a-a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-a-a-
## ##|   ##|##########|###### ##|##|   ##|   ##|   ##|##|   ##|##|     ########
## a-a-a-'   a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-a-a-a-a-a-'
## a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'
##  a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-  a-a-a-a-a-a-a-a-   a-a-a-    a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

