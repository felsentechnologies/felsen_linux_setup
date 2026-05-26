#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_papra() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_papra

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o Papra (ex: papra.example.com): \e[0m" && read -r url_papra
    echo ""

    ## Limpa o terminal
    clear

    ## Mostra o nome da aplicacao
    nome_papra

    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do Papra:\e[97m $url_papra\e[0m"
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
        nome_papra

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Criando key Aleatoria
auth_secret_papra=$(openssl rand -hex 48)

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO PAPRA \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO PAPRA \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack papra.yaml
cat > papra${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  papra${1:+_$1}:
    image: ghcr.io/papra-hq/papra:latest

    volumes:
      - papra${1:+_$1}_db:/app/app-data/db
      - papra${1:+_$1}_documents:/app/app-data/documents
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracoes da Aplicacao
      - APP_BASE_URL=https://$url_papra
      - PORT=1221
      - SERVER_HOSTNAME=0.0.0.0
      - SERVER_SERVE_PUBLIC_DIR=true
      - NODE_ENV=production
    
    ## -"i Configuracao do Banco de Dados
      - DATABASE_URL=file:./app-data/db/db.sqlite
    
    ## " Armazenamento de Documentos
      - DOCUMENT_STORAGE_DRIVER=filesystem
      - DOCUMENT_STORAGE_FILESYSTEM_ROOT=./app-data/documents
    
    ## " Configuracoes de AutenticaAAo e SeguranAa
      - AUTH_SECRET=$auth_secret_papra 
      - AUTH_IS_REGISTRATION_ENABLED=true
      - AUTH_IS_PASSWORD_RESET_ENABLED=true
      - AUTH_IS_EMAIL_VERIFICATION_REQUIRED=false
      - SERVER_CORS_ORIGINS=https://$url_papra
    
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
        - traefik.http.routers.papra${1:+_$1}.rule=Host(\`$url_papra\`)
        - traefik.http.services.papra${1:+_$1}.loadbalancer.server.port=1221
        - traefik.http.routers.papra${1:+_$1}.service=papra${1:+_$1}
        - traefik.http.routers.papra${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.papra${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.papra${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  papra${1:+_$1}_db:
    external: true
    name: papra${1:+_$1}_db
  papra${1:+_$1}_documents:
    external: true
    name: papra${1:+_$1}_documents

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do papra"
fi

STACK_NAME="papra${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c papra.yaml papra > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do papra"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/papra-hq/papra:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack papra${1:+_$1}_papra${1:+_$1}


cd dados_vps

cat > dados_papra${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ PAPRA ]

Dominio do papra: https://$url_papra

Usuario: Precisa de criar no primeiro acesso do Papra

Senha: Precisa de criar no primeiro acesso do Papra
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
echo -e "\e[32m[ PAPRA ]\e[0m"
echo ""

echo -e "\e[33mDominio do papra:\e[97m https://$url_papra\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa de criar no primeiro acesso do Papra\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar no primeiro acesso do Papra\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######################  ####### ####### ###   ####################
## a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-- a-a-a-"a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-
##   a-a-a-a-"a- a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a- a-a-a-a-a-a-"a-    a-a-a-'   a-a-a-a-a-a--  
##  a-a-a-a-"a-  a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--  a-a-a-a-"a-     a-a-a-'   a-a-a-"a-a-a-  
## a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-   a-a-a-'      a-a-a-'   a-a-a-a-a-a-a-a--
## a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-    a-a-a-      a-a-a-   a-a-a-a-a-a-a-a-

