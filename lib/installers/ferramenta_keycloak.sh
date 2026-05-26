#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_keycloak() {

## Verifica os recursos
recursos 2 2 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_keycloak

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o Keycloak (ex: keycloak.example.com): \e[0m" && read -r url_keycloak
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite um usuario para o Keycloak (ex: admin): \e[0m" && read -r user_keycloak
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite uma senha para o usuario (ex: @Senha123_): \e[0m" && read -r senha_keycloak
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_keycloak
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do keycloak
    echo -e "\e[33mDominio do Keycloak:\e[97m $url_keycloak\e[0m"
    echo ""

    ## Informacao sobre URL do keycloak
    echo -e "\e[33mUsuario:\e[97m $user_keycloak\e[0m"
    echo ""

    ## Informacao sobre URL do keycloak
    echo -e "\e[33mSenha:\e[97m $senha_keycloak\e[0m"
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
        nome_keycloak

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO KEYCLOAK \e[33m[1/4]\e[0m"
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
    criar_banco_postgres_da_stack "keycloak${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "keycloak${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO keycloak \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack keycloak.yaml
cat > keycloak${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- KEYCLOAK --------------------------- ##

  keycloak${1:+_$1}:

    image: quay.io/keycloak/keycloak:latest
    command: start
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Dados de acesso
      - KEYCLOAK_ADMIN=$user_keycloak
      - KEYCLOAK_ADMIN_PASSWORD=$senha_keycloak

    ##  Configuracoes Gerais
      - TZ=America/Sao_Paulo

    ##  Configuracoes de Rede e Proxy
      ## $url_keycloak deve ser apenas o hostname (ex: keycloak.exemplo.com)
      ## O scheme (https) e porta serao resolvidos dinamicamente dos headers X-Forwarded-*
      - KC_HOSTNAME=$url_keycloak
      - KC_HOSTNAME_STRICT=false
      - KC_HOSTNAME_STRICT_HTTPS=false
      - KC_HOSTNAME_STRICT_BACKCHANNEL=false
      - KC_HTTP_ENABLED=true
      ## KC_PROXY=edge esta deprecated na v2, removido para evitar warnings
      ## KC_PROXY_HEADERS e obrigatorio quando usando proxy reverso
      - KC_PROXY_HEADERS=xforwarded
      - KC_HTTP_RELATIVE_PATH=/
      
    ##  Banco de Dados PostgreSQL (VARIAVEIS)
      - KC_DB=postgres
      - KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak${1:+_$1}
      - KC_DB_USERNAME=postgres
      - KC_DB_PASSWORD=$senha_postgres
      
    ##  Health & Metrics (fixos)
      - KC_HEALTH_ENABLED=true
      - KC_METRICS_ENABLED=true
      
    ## Performance (fixos)
      - JAVA_OPTS_APPEND=-Dkeycloak.profile.feature.upload_scripts=enabled
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 2048M
      labels:
        - traefik.enable=true
        
        ## Router principal
        - traefik.http.routers.keycloak${1:+_$1}.rule=Host(\`$url_keycloak\`)
        - traefik.http.routers.keycloak${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.keycloak${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.keycloak${1:+_$1}.tls=true
        - traefik.http.routers.keycloak${1:+_$1}.service=keycloak${1:+_$1}
        - traefik.http.services.keycloak${1:+_$1}.loadbalancer.server.port=8080
        - traefik.http.middlewares.keycloak${1:+_$1}-headers.headers.customrequestheaders.X-Forwarded-Proto=https
        - traefik.http.middlewares.keycloak${1:+_$1}-headers.headers.customrequestheaders.X-Forwarded-For=
        - traefik.http.middlewares.keycloak${1:+_$1}-headers.headers.customrequestheaders.X-Real-IP=
        - traefik.http.middlewares.keycloak${1:+_$1}-headers.headers.customrequestheaders.X-Forwarded-Host=$url_keycloak
        - traefik.http.middlewares.keycloak${1:+_$1}-headers.headers.customrequestheaders.X-Forwarded-Port=443
        - traefik.http.routers.keycloak${1:+_$1}.middlewares=keycloak${1:+_$1}-headers

## --------------------------- NETWORKS --------------------------- ##

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna


__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do keycloak"
fi
STACK_NAME="keycloak${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c keycloak.yaml keycloak > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do keycloak"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull quay.io/keycloak/keycloak:latest

## Usa o servico wait_keycloak para verificar se o servico esta online
wait_stack keycloak${1:+_$1}_keycloak${1:+_$1}


cd dados_vps

cat > dados_keycloak${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ KEYCLOAK ]

Dominio do Keycloak: https://$url_keycloak/auth

Usuario: $user_keycloak

Senha: $senha_keycloak

__FELSEN_MANAGED_FILE__
cd
cd

## Espera 30 segundos
wait_30_sec
wait_30_sec

## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ KEYCLOAK ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_keycloak\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_keycloak\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $senha_keycloak\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  ###### #######################  ####### ###  #########
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-'  a-a-a-a-a-a-"a-a-a-
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   
## a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   
## a-a-a-'     a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'   
## a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-   

