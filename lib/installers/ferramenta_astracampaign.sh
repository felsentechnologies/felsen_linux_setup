#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_astracampaign() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_astracampaign

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o AstraCampaign (ex: astracampaign.example.com): \e[0m" && read -r url_astracampaign
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_astracampaign
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do AstraCampaign:\e[97m $url_astracampaign\e[0m"
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
        nome_astracampaign

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO ASTRACAMPAIGN \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres Instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "astracampaign${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "astracampaign${1:+_$1}"
fi

pegar_senha_postgres > /dev/null 2>&1

echo -e "\e[97m- INSTALANDO ASTRACAMPAIGN \e[33m[3/4]\e[0m"
echo ""
sleep 1

jwtsecret_astracampaign=$(openssl rand -hex 16)

## Criando a stack astracampaign.yaml
cat > astracampaign${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  astracampaign${1:+_$1}_backend:
    image: astraonline/astracampaignbackend:latest

    volumes:
      - astracampaign${1:+_$1}_contacts:/app/data
      - astracampaign${1:+_$1}_uploads:/app/uploads
      - astracampaign${1:+_$1}_backup:/app/backups

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## -"i Configuracao do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/astracampaign${1:+_$1}
    
    ## " Configuracao do Redis
      - REDIS_URL=redis://astracampaign${1:+_$1}_redis:6379
      - REDIS_PREFIX=work_app

    ##  Configuracao do Servidor
      - PORT=3001
      - NODE_ENV=production
    
    ## " Configuracao de AutenticaAAo (JWT)
      - JWT_SECRET=$jwtsecret_astracampaign
      - JWT_EXPIRES_IN=24h
    
    ##  Configuracao da Aplicacao
      - DEFAULT_COMPANY_NAME=Felsen Linux Setup
      - DEFAULT_PAGE_TITLE=Sistema de Gestao de Contatos - By AstraOnline

    ##  Configuracao de CORS
      - ALLOWED_ORIGINS=https://$url_astracampaign,http://$url_astracampaign,http://astracampaign${1:+_$1}_frontend,http://astracampaign${1:+_$1}_frontend:80

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
        - traefik.http.routers.work-backend.rule=Host(\`$url_astracampaign\`) && PathPrefix(\`/api\`)
        - traefik.http.services.work-backend.loadbalancer.server.port=3001
        - traefik.http.routers.work-backend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.work-backend.entrypoints=websecure
        - traefik.http.routers.work-backend.tls=true
        - traefik.docker.network=$nome_rede_interna

## --------------------------- FELSEN --------------------------- ##

  astracampaign${1:+_$1}_frontend:
    image: astraonline/astracampaignfrontend:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna

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
        - traefik.http.routers.work-frontend.rule=Host(\`$url_astracampaign\`)
        - traefik.http.services.work-frontend.loadbalancer.server.port=80
        - traefik.http.routers.work-frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.work-frontend.entrypoints=websecure
        - traefik.http.routers.work-frontend.tls=true
        - traefik.docker.network=$nome_rede_interna

## --------------------------- FELSEN --------------------------- ##

  astracampaign${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - astracampaign${1:+_$1}_redis:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 6379:6379

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

## --------------------------- FELSEN --------------------------- ##

volumes:
  astracampaign${1:+_$1}_contacts:
    external: true
    name: astracampaign${1:+_$1}_contacts
  astracampaign${1:+_$1}_uploads:
    external: true
    name: astracampaign${1:+_$1}_uploads
  astracampaign${1:+_$1}_backup:
    external: true
    name: astracampaign${1:+_$1}_backup
  astracampaign${1:+_$1}_redis:
    external: true
    name: astracampaign${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do AstraCampaign"
fi

STACK_NAME="astracampaign${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c astracampaign.yaml astracampaign > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do astracampaign"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest astraonline/astracampaignbackend:latest astraonline/astracampaignfrontend:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack astracampaign${1:+_$1}_astracampaign${1:+_$1}_redis astracampaign${1:+_$1}_astracampaign${1:+_$1}_backend astracampaign${1:+_$1}_astracampaign${1:+_$1}_frontend


cd dados_vps

cat > dados_astracampaign${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ ASTRACAMPAIGN ]

Dominio do AstraCampaign: https://$url_astracampaign

Email: superadmin@astraonline.com.br

Senha: Admin123
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
echo -e "\e[32m[ ASTRACAMPAIGN ]\e[0m"
echo ""

echo -e "\e[33mDominio do astracampaign:\e[97m https://$url_astracampaign\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m superadmin@astraonline.com.br\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Admin123\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####### ###   ########## ###     ### ####### ###### ############
## a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-'a-a-a-'     a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a- a-a-a-'     a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-a-'   a-a-a-'   a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a--a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'   a-a-a-'   a-a-a-'
## a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-   a-a-a-   a-a-a-

