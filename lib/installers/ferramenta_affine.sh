#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_affine() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_affine

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o Affine (ex: affine.example.com): \e[0m" && read -r url_affine
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o Email de Admin (ex: contato@example.com): \e[0m" && read -r email_affine
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$"
    echo -en "\e[33mDigite a Senha de Admin (ex: @Senha123_): \e[0m" && read -r senha_affine
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_affine
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do affine
    echo -e "\e[33mDominio do Affine:\e[97m $url_affine\e[0m"
    echo ""

    ## Informacao sobre URL do affine
    echo -e "\e[33mEmail de Admin:\e[97m $email_affine\e[0m"
    echo ""

    ## Informacao sobre URL do affine
    echo -e "\e[33mSenha de Admin:\e[97m $senha_affine\e[0m"
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
        nome_affine

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO AFFINE \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO PGVECTOR \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe PgVector e redis instalado
## Se tiver ele vai criar um banco de dados no PgVector ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container PgVector e cria banco no PgVector
verificar_container_pgvector
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - PgVector ja instalado"
    pegar_senha_pgvector > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do PgVector"
    criar_banco_pgvector_da_stack "affine${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_pgvector
    pegar_senha_pgvector > /dev/null 2>&1
    criar_banco_pgvector_da_stack "affine${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO AFFINE \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack affine.yaml
cat > affine${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  affine${1:+_$1}_app:
    image: ghcr.io/toeverything/affine:stable
    
    volumes:
      - affine${1:+_$1}_storage:/root/.affine/storage
      - affine${1:+_$1}_config:/root/.affine/config
    
    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  URL Externa (ajuste conforme seu dominio)
      - AFFINE_SERVER_EXTERNAL_URL=https://$url_affine
      - AFFINE_SERVER_HTTPS=true

    ## -"i Banco do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_pgvector@pgvector:5432/affine${1:+_$1}?sslmode=disable
      
    ##  Configuracao do Redis
      - REDIS_SERVER_HOST=affine${1:+_$1}_redis
      - REDIS_SERVER_PORT=6379
      - REDIS_SERVER_PASSWORD=
      
    # Configuracoes do Servico
      - AFFINE_SERVER_HOST=0.0.0.0
      - AFFINE_SERVER_PORT=3010
      - NODE_ENV=production
      
    ##  Armazenamento
      - STORAGE_PROVIDER=fs
      - STORAGE_PATH=/root/.affine/storage
      
    ##  Funcionalidades
      - AFFINE_INDEXER_ENABLED=true
      - AFFINE_ENABLE_OAUTH=false
      
    ## Configuracoes de E-mail (SMTP)
      #- MAILER_FROM=
      #- MAILER_HOST=
      #- MAILER_PORT=
      #- MAILER_USER=
      #- MAILER_PASSWORD=
      #- MAILER_SECURE=false
      
    ##  Copilot
      - COPILOT_ENABLED=false
      
    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.affine${1:+_$1}_app.rule=Host(\`$url_affine\`)
        - traefik.http.services.affine${1:+_$1}_app.loadbalancer.server.port=3010
        - traefik.http.routers.affine${1:+_$1}_app.service=affine${1:+_$1}_app
        - traefik.http.routers.affine${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.affine${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.affine${1:+_$1}_app.tls=true
        - traefik.frontend.headers.STSPreload=true
        - traefik.frontend.headers.STSSeconds=31536000

## --------------------------- FELSEN --------------------------- ##

  affine${1:+_$1}_migration:
    image: ghcr.io/toeverything/affine:stable
    command: ['sh', '-c', 'node ./scripts/self-host-predeploy.js']
    
    volumes:
      - affine${1:+_$1}_storage:/root/.affine/storage
      - affine${1:+_$1}_config:/root/.affine/config
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  URL Externa (ajuste conforme seu dominio)
      - AFFINE_SERVER_EXTERNAL_URL=https://$url_affine
      - AFFINE_SERVER_HTTPS=true

    ## -"i Banco do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_pgvector@pgvector:5432/affine${1:+_$1}?sslmode=disable
      
    ##  Configuracao do Redis
      - REDIS_SERVER_HOST=affine${1:+_$1}_redis
      - REDIS_SERVER_PORT=6379
      - REDIS_SERVER_PASSWORD=
      
    # Configuracoes do Servico
      - AFFINE_SERVER_HOST=0.0.0.0
      - AFFINE_SERVER_PORT=3010
      - NODE_ENV=production
      
    ##  Armazenamento
      - STORAGE_PROVIDER=fs
      - STORAGE_PATH=/root/.affine/storage
      
    ##  Funcionalidades
      - AFFINE_INDEXER_ENABLED=true
      - AFFINE_ENABLE_OAUTH=false
      
    ## Configuracoes de E-mail (SMTP)
      #- MAILER_FROM=
      #- MAILER_HOST=
      #- MAILER_PORT=
      #- MAILER_USER=
      #- MAILER_PASSWORD=
      #- MAILER_SECURE=false
      
    ##  Copilot
      - COPILOT_ENABLED=false
    
    deploy:
      restart_policy:
        condition: none
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

  affine${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - affine${1:+_$1}_redis:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 6379:6379

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

volumes:
  affine${1:+_$1}_storage:
    external: true
    name: affine${1:+_$1}_storage
  affine${1:+_$1}_config:
    external: true
    name: affine${1:+_$1}_config
  affine${1:+_$1}_redis:
    external: true
    name: affine${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Affine"
fi
STACK_NAME="affine${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c affine.yaml affine > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Affine"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/toeverything/affine:stable

## Usa o servico wait_stack "affine" para verificar se o servico esta online
wait_stack affine${1:+_$1}_affine${1:+_$1}_redis affine${1:+_$1}_affine${1:+_$1}_app


cd dados_vps

cat > dados_affine${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ AFFINE ]

Dominio do Affine: https://$url_affine

Usuario: $email_affine

Senha: $senha_affine

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
echo -e "\e[32m[ AFFINE ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_affine\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $email_affine\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $senha_affine\e[0m"
echo ""

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####### ########## ######## ###################   ###########
## a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-
## a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-'        a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-'  a-a-a-'a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-'        a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'
## a-a-a-a-a-a-a- a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-   a-a-a-    a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-
                                                                  
