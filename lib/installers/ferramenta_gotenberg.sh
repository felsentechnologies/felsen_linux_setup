#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_gotenberg() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_gotenberg

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o Gotenberg (ex: gotenberg.example.com): \e[0m" && read -r url_gotenberg
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o usuario para o Gotenberg (ex: Felsen): \e[0m" && read -r gotenberg_user
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite a senha para o Gotenberg (ex: @Senha123_): \e[0m" && read -r gotenberg_pass
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_gotenberg
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do gotenberg
    echo -e "\e[33mDominio do Gotenberg:\e[97m $url_gotenberg\e[0m"
    echo ""

    ## Informacao sobre URL do gotenberg
    echo -e "\e[33mUsuario para a autenticacao basica:\e[97m $gotenberg_user\e[0m"
    echo ""

    ## Informacao sobre URL do gotenberg
    echo -e "\e[33mSenha para a autenticacao basica:\e[97m $gotenberg_pass\e[0m"
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
        nome_gotenberg

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO GOTENBERG \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO GOTENBERG \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack gotenberg.yaml
cat > gotenberg${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  gotenberg${1:+_$1}:
    image: gotenberg/gotenberg:latest
    command:
      - "gotenberg"

    volumes:
      - gotenberg${1:+_$1}_data:/gotenberg

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " AutenticaAAo BAsica
      - API_ENABLE_BASIC_AUTH=true
      - GOTENBERG_API_BASIC_AUTH_USERNAME=$gotenberg_user
      - GOTENBERG_API_BASIC_AUTH_PASSWORD=$gotenberg_pass

    ## " Logging
      - LOG_LEVEL=info
      - LOG_FORMAT=auto

    ##  Configuracao da API
      - API_PORT=3000
      - API_TIMEOUT=30s
      - API_START_TIMEOUT=30s
      - API_BODY_LIMIT=
      - API_ROOT_PATH=/

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.gotenberg${1:+_$1}.rule=Host(\`$url_gotenberg\`)
        - traefik.http.services.gotenberg${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.gotenberg${1:+_$1}.service=gotenberg${1:+_$1}
        - traefik.http.routers.gotenberg${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.gotenberg${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.gotenberg${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  gotenberg${1:+_$1}_data:
    external: true
    name: gotenberg${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Gotenberg"
fi
STACK_NAME="gotenberg${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c gotenberg.yaml gotenberg > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do gotenberg"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull gotenberg/gotenberg:latest

## Usa o servico wait_gotenberg para verificar se o servico esta online
wait_stack gotenberg${1:+_$1}_gotenberg${1:+_$1}


cd dados_vps

cat > dados_gotenberg${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ GOTENBERG ]

Dominio do gotenberg: https://$url_gotenberg

Usuario: $gotenberg_user

Senha: $gotenberg_pass

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
echo -e "\e[32m[ GOTENBERG ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_gotenberg\e[0m"

echo -e "\e[33mUsuario:\e[97m $gotenberg_user\e[0m"

echo -e "\e[33mSenha:\e[97m $gotenberg_pass\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###    #########  ######        ###########
## a-a-a-'    a-a-a-'a-a-a-'a-a-a-' a-a-a-"a-a-a-a-'        a-a-a-'a-a-a-"a-a-a-a-a-
## a-a-a-' a-a-- a-a-a-'a-a-a-'a-a-a-a-a-a-"a- a-a-a-'        a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-'a-a-a-"a-a-a-a-- a-a-a-'   a-a-   a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-a-a-"a-a-a-a-"a-a-a-a-'a-a-a-'  a-a-a--a-a-a-'a-a-a--a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'
##  a-a-a-a-a-a-a-a- a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a- a-a-a-a-a-a- a-a-a-a-a-a-a-a-

