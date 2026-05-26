#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_excalidraw() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_excalidraw

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Excalidraw (ex: excalidraw.example.com): \e[0m" && read -r url_excalidraw
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_excalidraw
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do excalidraw
    echo -e "\e[33mDominio do Excalidraw:\e[97m $url_excalidraw\e[0m"
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
        nome_excalidraw

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO EXCALIDRAW \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO EXCALIDRAW \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack
cat > excalidraw${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  excalidraw${1:+_$1}:
    image: excalidraw/excalidraw:latest

    volumes:
      - excalidraw${1:+_$1}_data:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracoes gerais
      - EXCALIDRAW_PORT=80
      - NODE_ENV=development

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
        - traefik.http.routers.excalidraw${1:+_$1}.rule=Host(\`$url_excalidraw\`)
        - traefik.http.services.excalidraw${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.excalidraw${1:+_$1}.service=excalidraw${1:+_$1}
        - traefik.http.routers.excalidraw${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.excalidraw${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.excalidraw${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  excalidraw${1:+_$1}_data:
    external: true
    name: excalidraw${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do excalidraw"
fi
STACK_NAME="excalidraw${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c excalidraw.yaml excalidraw > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do excalidraw"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull excalidraw/excalidraw:latest

## Usa o servico wait_stack "excalidraw" para verificar se o servico esta online
wait_stack excalidraw${1:+_$1}_excalidraw${1:+_$1}


cd dados_vps

cat > dados_excalidraw${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ EXCALIDRAW ]

Dominio do Excalidraw: https://$url_excalidraw

Usuario: Precisa criar no primeiro acesso do Excalidraw

Senha: Precisa criar no primeiro acesso do Excalidraw
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
echo -e "\e[32m[ EXCALIDRAW ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_excalidraw\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Excalidraw\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Excalidraw\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ######## ###### ###########   ######                                                                 
## a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-- a-a-a-"a-a-a-a-'                                                                 
## a-a-a-a-a-a--  a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-'                                                                 
## a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'  a-a-a-a-"a-  a-a-a-                                                                 
## ##########|  ##|#######|   ##|   ###                                                                 
## a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-   a-a-a-   a-a-a-                                                                 
##                                                                                                      
##  ###### ####### #######  ####### #######   ################   ################   ####################
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-'a-a-a-"a-a-a-- a-a-a-'   a-a-a-'   a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a--  a-a-a-"a-a-a-- a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a--
## a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a- a-a-a-'   a-a-a-'a-a-a-'a-a-a-'a-a-a-a--a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-'     a-a-a-'     a-a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-' a-a-a-a-a-a-'   a-a-a-'   a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-'
## a-a-a-  a-a-a-a-a-a-     a-a-a-      a-a-a-a-a-a-a- a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-   a-a-a-     a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-   a-a-a-a-a-a-a-a-

