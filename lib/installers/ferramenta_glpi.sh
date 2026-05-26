#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_glpi() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_glpi

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o GLPI (ex: glpi.example.com): \e[0m" && read -r url_glpi
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_glpi
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do glpi
    echo -e "\e[33mDominio do GLPI:\e[97m $url_glpi\e[0m"
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
        nome_glpi

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO GLPI \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO MYSQL \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Cria banco de dados do site no mysql
verificar_container_mysql
    if [ $? -eq 0 ]; then
        echo "1/3 - [ OK ] - MySQL ja instalado"
        pegar_senha_mysql > /dev/null 2>&1
        echo "2/3 - [ OK ] - Copiando senha do MySQL"
        criar_banco_mysql_da_stack "glpi${1:+_$1}"
        echo "3/3 - [ OK ] - Criando banco de dados"
        echo ""
    else
        ferramenta_mysql
        pegar_senha_mysql > /dev/null 2>&1
        criar_banco_mysql_da_stack "glpi${1:+_$1}"
    fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO GLPI \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack glpi.yaml
cat > glpi${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  glpi${1:+_$1}:
    image: diouxx/glpi:latest

    volumes:
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - glpi${1:+_$1}_glpi:/var/www/html/glpi

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Timezone
      - TIMEZONE=America/Sao_Paulo

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
        - traefik.http.routers.glpi${1:+_$1}.rule=Host(\`$url_glpi\`)
        - traefik.http.services.glpi${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.glpi${1:+_$1}.service=glpi${1:+_$1}
        - traefik.http.routers.glpi${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.glpi${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.glpi${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  glpi${1:+_$1}_glpi:
    external: true
    name: glpi${1:+_$1}_glpi

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do GLPI"
fi
STACK_NAME="glpi${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c glpi.yaml glpi > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do glpi"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull diouxx/glpi:latest

## Usa o servico wait_stack "glpi" para verificar se o servico esta online
wait_stack glpi${1:+_$1}_glpi${1:+_$1}


cd dados_vps

cat > dados_glpi${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ GLPI ]

Dominio do GLPI: https://$url_glpi

Usuario: glpi

Senha: glpi
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
echo -e "\e[32m[ GLPI ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_glpi\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m glpi\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m glpi\e[0m"
echo ""

echo -e "\e[33mEndereco do servidor SQL:\e[97m mysql\e[0m"
echo ""

echo -e "\e[33mUsuario SQL:\e[97m root\e[0m"
echo ""

echo -e "\e[33mSenha SQL:\e[97m $senha_mysql\e[0m"
echo ""

echo -e "\e[33mBanco de dados:\e[97m glpi${1:+_$1}\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ###### ####   ######   ###############  ##########   ### #######     ###     ###     ####   ####
## a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-a-- a-a-a-"a-a-a-a-a-a-a-"a-a-a-a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-     a-a-a-'     a-a-a-'     a-a-a-a-a-- a-a-a-a-a-'
## a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-- a-a-a-' a-a-a-a-a-a-"a-    a-a-a-'   a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-'  a-a-a-a--    a-a-a-'     a-a-a-'     a-a-a-"a-a-a-a-a-"a-a-a-'
## a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'  a-a-a-a-"a-     a-a-a-'   a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'    a-a-a-'     a-a-a-'     a-a-a-'a-a-a-a-"a-a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-' a-a-a-a-a-a-'   a-a-a-'      a-a-a-'   a-a-a-'  a-a-a-'a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-    a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-' a-a-a- a-a-a-'
## a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-      a-a-a-   a-a-a-  a-a-a-a-a-a-a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a-     a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-     a-a-a-

