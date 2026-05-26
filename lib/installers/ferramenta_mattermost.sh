#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_mattermost() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_mattermost

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Mattermost (ex: mattermost.example.com): \e[0m" && read -r url_mattermost
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_mattermost
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do mattermost
    echo -e "\e[33mDominio do Mattermost:\e[97m $url_mattermost\e[0m"
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
        nome_mattermost

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO MATTERMOST \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Cansei ja de explicar o que isso faz kkkk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "mattermost${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "mattermost${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO MATTERMOST \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack mattermost.yaml
cat > mattermost${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  mattermost${1:+_$1}:
    image: mattermost/mattermost-team-edition:latest

    volumes:
      - mattermost${1:+_$1}_data:/mattermost/data
      - mattermost${1:+_$1}_config:/mattermost/config
      - mattermost${1:+_$1}_logs:/mattermost/logs
      - mattermost${1:+_$1}_plugins:/mattermost/plugins
      - mattermost${1:+_$1}_client_plugins:/mattermost/client/plugins

    networks:
      - $nome_rede_interna

    environment:
    ## " Dados de acesso
      - MM_SERVICESETTINGS_SITEURL=https://$url_mattermost

    ##  Dados do Postgres
      - MM_SQLSETTINGS_DRIVERNAME=postgres
      - MM_SQLSETTINGS_DATASOURCE=postgres://postgres:$senha_postgres@postgres:5432/mattermost${1:+_$1}?sslmode=disable&connect_timeout=10

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
        - traefik.http.routers.mattermost${1:+_$1}.rule=Host(\`$url_mattermost\`)
        - traefik.http.routers.mattermost${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.mattermost${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.mattermost${1:+_$1}.service=mattermost${1:+_$1}
        - traefik.http.services.mattermost${1:+_$1}.loadbalancer.server.port=8065
        - traefik.http.services.mattermost${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https
        - traefik.http.routers.mattermost${1:+_$1}.middlewares=sslheader

## --------------------------- FELSEN --------------------------- ##

volumes:
  mattermost${1:+_$1}_data:
    external: true
    name: mattermost${1:+_$1}_data
  mattermost${1:+_$1}_config:
    external: true
    name: mattermost${1:+_$1}_config
  mattermost${1:+_$1}_logs:
    external: true
    name: mattermost${1:+_$1}_logs
  mattermost${1:+_$1}_plugins:
    external: true
    name: mattermost${1:+_$1}_plugins
  mattermost${1:+_$1}_client_plugins:
    external: true
    name: mattermost${1:+_$1}_client_plugins

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do mattermost"
fi
STACK_NAME="mattermost${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c mattermost.yaml mattermost > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do mattermost"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull mattermost/mattermost-team-edition:latest

## Usa o servico wait_stack "mattermost" para verificar se o servico esta online
wait_stack mattermost${1:+_$1}_mattermost${1:+_$1}


cd dados_vps

cat > dados_mattermost${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ MATTERMOST ]

Dominio do Mattermost: https://$url_mattermost

Usuario: Precisa criar no primeiro acesso do Mattermost

Senha: Precisa criar no primeiro acesso do Mattermost
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
echo -e "\e[32m[ MATTERMOST ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_mattermost\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Mattermost\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Mattermost\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##   ####### ###   ###############     #######   ###########
##  a-a-a-"a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'     a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-
##  ##|   ##|##|   ##|   ##|   ##|     ##|###### ##|######  
##  a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'     a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-  
##  a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-a-a-a-a-a--a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a--
##   a-a-a-a-a-a-a-  a-a-a-a-a-a-a-    a-a-a-   a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-                                                                              

