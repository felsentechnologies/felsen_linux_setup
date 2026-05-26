#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_heyform() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados
pegar_senha_mongodb

## Mostra o nome da aplicacao
nome_heyform

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o HeyForm (ex: heyform.example.com): \e[0m" && read -r url_heyform
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_heyform
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do HeyForm:\e[97m $url_heyform\e[0m"
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
        nome_heyform

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO HEYFORM \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO HEYFORM \e[33m[2/3]\e[0m"
echo ""
sleep 1

sessionkey_heyform=$(openssl rand -hex 16)
encryptionkey_heyform=$(openssl rand -hex 16)

## Criando a stack heyform.yaml
cat > heyform${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: '3.8'
services:

## --------------------------- FELSEN --------------------------- ##

  heyform${1:+_$1}_app:
    image: heyform/community-edition:v0.1.0

    volumes:
      - heyform${1:+_$1}_uploads:/app/static/upload

    networks:
      - $nome_rede_interna

    environment:
    ## Configuracoes da Aplicacao
      - NODE_ENV=production
      - APP_LISTEN_PORT=9157
      - APP_LISTEN_HOSTNAME=0.0.0.0
      - APP_HOMEPAGE_URL=https://$url_heyform
      - APP_DISABLE_REGISTRATION=false ## false = Permite registro de novos usuarios
      
    ## a Cookies e SessAes
      - COOKIE_MAX_AGE=1y
      - COOKIE_DOMAIN=
      - SESSION_KEY=$sessionkey_heyform
      - SESSION_MAX_AGE=15d
      
    ## " Encryptation
      - FORM_ENCRYPTION_KEY=$encryptionkey_heyform
      
    ## -"i Configuracao do MongoDB
      - MONGO_URI=mongodb://mongodb:27017/heyform${1:+_$1}?authSource=admin
      - MONGO_USER=$user_mongo
      - MONGO_PASSWORD=$pass_mongo
      - MONGO_SSL_CA_PATH=
      
    ##  Configuracao do Redis
      - REDIS_HOST=heyform${1:+_$1}_redis
      - REDIS_PORT=6379
      - REDIS_PASSWORD=
      - REDIS_DB=0
      
    ##  Configuracoes de Upload de Arquivos
      - UPLOAD_FILE_SIZE=10485760
      - UPLOAD_FILE_TYPES=
      
    ##  Seguranca de Senhas (Bcrypt)
      - BCRYPT_SALT=10
      
    ##  Configuracao da Fila de Processamento (Bull)
      - BULL_JOB_ATTEMPTS=3
      - BULL_JOB_TIMEOUT=1m
      - BULL_JOB_BACKOFF_DELAY=3000
      - BULL_JOB_BACKOFF_TYPE=fixed
      
    ##  Outras Configuracoes da Aplicacao
      - INVITE_CODE_EXPIRE_DAYS=7
      - FORM_REPORT_RATE=5s
      - VERIFICATION_CODE_EXPIRE=10m
      - VERIFICATION_CODE_LIMIT=5
      - ACCOUNT_DELETION_SCHEDULE_INTERVAL=2d
    
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
        - traefik.http.routers.heyform${1:+_$1}_app.rule=Host(\`$url_heyform\`)
        - traefik.http.services.heyform${1:+_$1}_app.loadbalancer.server.port=9157
        - traefik.http.routers.heyform${1:+_$1}_app.service=heyform${1:+_$1}_app
        - traefik.http.routers.heyform${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.heyform${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.heyform${1:+_$1}_app.tls=true

## --------------------------- FELSEN --------------------------- ##

  heyform${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - heyform${1:+_$1}_redis:/data

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
  heyform${1:+_$1}_uploads:
    external: true
    name: heyform${1:+_$1}_uploads
  heyform${1:+_$1}_redis:
    external: true
    name: heyform${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna


__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do heyform"
fi

STACK_NAME="heyform${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c heyform.yaml heyform > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do heyform"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest heyform/community-edition:v0.1.0

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack heyform${1:+_$1}_heyform${1:+_$1}_redis heyform${1:+_$1}_heyform${1:+_$1}_app


cd dados_vps

cat > dados_heyform${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ HEYFORM ]

Dominio do Heyform: https://$url_heyform
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
echo -e "\e[32m[ HEYFORM ]\e[0m"
echo ""

echo -e "\e[33mDominio do Heyform:\e[97m https://$url_heyform\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no Heyform\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no Heyform\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###    ##############  ### ###### ####   ###
## a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-' a-a-a-"a-a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'
## a-a-a-' a-a-- a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-- a-a-a-'
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-- a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'  a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a-a-a-a-'
##  a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-

