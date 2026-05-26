#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_appsmith() {

## Verifica os recursos
recursos 2 4 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_appsmith

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Appsmith (ex: appsmith.example.com): \e[0m" && read -r url_appsmith
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_appsmith
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Appsmith\e[97m $url_appsmith\e[0m"
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
        nome_appsmith

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO APPSMITH \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO APPSMITH \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando uma Encryption Key Aleatoria
secret=$(openssl rand -hex 16)

## Criando a stack appsmith.yaml
cat > appsmith${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  appsmith${1:+_$1}:
    image: appsmith/appsmith-ee:latest

    volumes:
      - appsmith${1:+_$1}_data:/appsmith-stacks

    networks:
      - $nome_rede_interna

    environment:
    ##  Url Appsmith
      - APPSMITH_CUSTOM_DOMAIN=https://$url_appsmith

    ## " Ativar/Desativar Novas InscriAAes
      - APPSMITH_SIGNUP_DISABLED=false
      - APPSMITH_FORM_LOGIN_DISABLED=false
    
    ##  Desativar rastreamento
      - APPSMITH_DISABLE_TELEMETRY=true

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
        - traefik.http.routers.appsmith${1:+_$1}.rule=Host(\`$url_appsmith\`)
        - traefik.http.routers.appsmith${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.appsmith${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.appsmith${1:+_$1}.service=appsmith${1:+_$1}
        - traefik.http.services.appsmith${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.services.appsmith${1:+_$1}.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  appsmith${1:+_$1}_data:
    external: true
    name: appsmith${1:+_$1}_data

networks:
  $nome_rede_interna:
    name: $nome_rede_interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Appsmith"
fi
STACK_NAME="appsmith${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c appsmith.yaml appsmith  > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Appsmith"
#fi


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull appsmith/appsmith-ee:latest

## Usa o servico wait_stack "nocobase" para verificar se o servico esta online
wait_stack appsmith${1:+_$1}_appsmith${1:+_$1}


cd dados_vps

cat > dados_appsmith${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ APPSMITH ]

Dominio do Appsmith: https://$url_nocobase

Usuario: Precisa criar no primeiro acesso do Appsmith

Senha: Precisa criar no primeiro acesso do Appsmith
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
echo -e "\e[32m[ APPSMITH ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_appsmith\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Appsmith\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Appsmith\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ####### #######  ###### ####   ############
## a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-a-a-a-"a-a-a-
## a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-- a-a-a-'   a-a-a-'   
## a-a-a-'a-"a-" a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'   a-a-a-'   
## a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-' a-a-a-a-a-a-'   a-a-a-'   
##  a-a-a-a-EURa-EURa-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-   
                                                    
