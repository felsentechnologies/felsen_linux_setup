#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_focalboard() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_focalboard

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o FocalBoard (ex: focalboard.example.com): \e[0m" && read -r url_focalboard
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_focalboard
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do focalboard
    echo -e "\e[33mDominio do FocalBoard:\e[97m $url_focalboard\e[0m"
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
        nome_focalboard

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO FOCALBOARD \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO FOCALBOARD \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack focalboard.yaml
cat > focalboard${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.8"
services:

## --------------------------- FELSEN --------------------------- ##

  focalboard${1:+_$1}:
    image: mattermost/focalboard:latest

    volumes:
      - focalboard${1:+_$1}_data:/opt/focalboard/data
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ## " Dados de acesso
      - VIRTUAL_HOST=$url_focalboard ## Url da Aplicacao
      - VIRTUAL_PORT=8000
    
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
        - traefik.http.routers.focalboard${1:+_$1}.rule=Host(\`$url_focalboard\`) ## Url da Aplicacao
        - traefik.http.services.focalboard${1:+_$1}.loadBalancer.server.port=8000
        - traefik.http.routers.focalboard${1:+_$1}.service=focalboard${1:+_$1}
        - traefik.http.routers.focalboard${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.focalboard${1:+_$1}.tls.certresolver=letsencryptresolver

## --------------------------- FELSEN --------------------------- ##

volumes:
  focalboard${1:+_$1}_data:
    external: true
    name: focalboard${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do focalboard"
fi
STACK_NAME="focalboard${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c focalboard.yaml focalboard > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do focalboard"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull mattermost/focalboard:latest

## Usa o servico wait_focalboard para verificar se o servico esta online
wait_stack focalboard${1:+_$1}_focalboard${1:+_$1}


cd dados_vps

cat > dados_focalboard${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ FOCALBOARD ]

Dominio do FocalBoard: https://$url_focalboard

Usuario: Precisa criar no primeiro acesso do FocalBoard

Senha: Precisa criar no primeiro acesso do FocalBoard
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
echo -e "\e[32m[ FOCALBOARD ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_focalboard\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do FocalBoard\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do FocalBoard\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ###     ####### ###
## a-a-a-"a-a-a-a-a- a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-'
## a-a-a-'  a-a-a-a--a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-'
## a-a-a-'   a-a-a-'a-a-a-'     a-a-a-"a-a-a-a- a-a-a-'
## a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'     a-a-a-'
##  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-     a-a-a-

