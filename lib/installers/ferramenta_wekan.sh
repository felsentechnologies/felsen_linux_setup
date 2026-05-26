#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_wekan() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados
pegar_senha_mongodb

## Mostra o nome da aplicacao
nome_wekan

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o Wekan (ex: wekan.example.com): \e[0m" && read -r url_wekan
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_wekan
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Wekan:\e[97m $url_wekan\e[0m"
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
        nome_wekan

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO WEKAN \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO WEKAN \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack wekan.yaml
cat > wekan${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:   

## --------------------------- FELSEN --------------------------- ##

  wekan${1:+_$1}:
    image: ghcr.io/wekan/wekan:latest

    volumes:
      - wekan${1:+_$1}_files:/data:rw

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracao da URL da Aplicacao
      - ROOT_URL=https://$url_wekan

    ## " Caminhos e Armazenamento
      - WRITABLE_PATH=/data

    ##  Configuracao do MongoDB
      - MONGO_URL=mongodb://$user_mongo:$pass_mongo@mongodb:27017/wekan${1:+_$1}?authSource=admin
      
    ##  Configuracao do SMTP
      - MAIL_URL=smtp://email@dominio.com:@Senha123_@smtp.dominio.com:587
      - MAIL_FROM=Wekan Notifications <email@dominio.com>

    ##  Configuracao da API
      - WITH_API=true

    ## Comportamento e Recursos
      - RICHER_CARD_COMMENT_EDITOR=false
      - CARD_OPENED_WEBHOOK_ENABLED=false
      - BIGEVENTS_PATTERN=NONE
      - LDAP_BACKGROUND_SYNC_INTERVAL=''
      - BROWSER_POLICY_ENABLED=true

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
        - traefik.http.routers.wekan${1:+_$1}.rule=Host(\`$url_wekan\`)
        - traefik.http.services.wekan${1:+_$1}.loadbalancer.server.port=8080
        - traefik.http.routers.wekan${1:+_$1}.service=wekan${1:+_$1}
        - traefik.http.routers.wekan${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.wekan${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.wekan${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  wekan${1:+_$1}_files:
    external: true
    name: wekan${1:+_$1}_files

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna

__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Wekan"
fi

STACK_NAME="wekan${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c wekan.yaml wekan > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do wekan"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/wekan/wekan:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack wekan${1:+_$1}_wekan${1:+_$1}


cd dados_vps

cat > dados_wekan${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ WEKAN ]

Dominio do Wekan: https://$url_wekan
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
echo -e "\e[32m[ WEKAN ]\e[0m"
echo ""

echo -e "\e[33mDominio do Wekan:\e[97m https://$url_wekan\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no Wekan\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no Wekan\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ####### ############   ############## ####### ####   ###
## a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a- a-a-a-a-a--  a-a-a-'
## a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'a-a-a-'  a-a-a-a--a-a-a-"a-a-a-- a-a-a-'
## a-a-a-'   a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'
##  a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-

