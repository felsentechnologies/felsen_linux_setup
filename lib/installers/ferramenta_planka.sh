#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_planka() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_planka

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/10\e[0m"
    echo -en "\e[33mDigite o dominio para o Planka (ex: planka.example.com): \e[0m" && read -r url_planka
    echo ""
  
    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/10\e[0m"
    echo -en "\e[33mDigite o nome do usuario administrador (ex: Willian): \e[0m" && read -r nome_adm_planka
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/10\e[0m"
    echo -en "\e[33mDigite o email do administrador (ex: contato@example.com): \e[0m" && read -r email_adm_planka
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/10\e[0m"
    echo -en "\e[33mDigite o usuario do administrador (ex: admin): \e[0m" && read -r user_adm_planka
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 5/10\e[0m"
    echo -en "\e[33mDigite a senha do administrador (ex: @Senha123_): \e[0m" && read -r senha_adm_planka
    echo ""

    ##Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 6/10\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_planka
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 7/10\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r usuario_email_planka
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 8/10\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_planka
    echo ""

    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 9/10\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_planka
    echo ""

    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 10/10\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_planka
    echo ""

    ## Verifica se a porta e 465, se sim deixa o ssl true, se nao, deixa false 
    if [ "$porta_smtp_planka" -eq 465 ]; then
    smtp_secure_planka=true
    tls_reject=false
    else
    smtp_secure_planka=false
    tls_reject=true
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_planka
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do planka
    echo -e "\e[33mDominio do Planka:\e[97m $url_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mNome do usuario:\e[97m $nome_adm_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mEmail do Usuario:\e[97m $email_adm_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mUsuario do Admin:\e[97m $user_adm_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mSenha do Admin:\e[97m $senha_adm_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mEmail SMTP:\e[97m $email_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mUsuario SMTP:\e[97m $usuario_email_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mSenha SMTP:\e[97m $senha_email_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mHost SMTP:\e[97m $smtp_email_planka\e[0m"
    echo ""

    ## Informacao sobre URL do planka
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_planka\e[0m"
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
        nome_planka

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO PLANKA \e[33m[1/4]\e[0m"
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
    criar_banco_postgres_da_stack "planka${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "planka${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO PLANKA \e[33m[3/4]\e[0m"
echo ""
sleep 1

secret_key=$(openssl rand -hex 16)

## Criando a stack planka.yaml
cat > planka${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  planka${1:+_$1}_app:
    image: ghcr.io/plankanban/planka:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna

    volumes:
      - planka${1:+_$1}_avatars:/app/public/user-avatars
      - planka${1:+_$1}_backgrounds:/app/public/project-background-images
      - planka${1:+_$1}_attachments:/app/private/attachments

    environment:
    ## " Dados de acesso
      - BASE_URL=https://$url_planka
      - DEFAULT_ADMIN_NAME=$nome_adm_planka
      - DEFAULT_ADMIN_USERNAME=$user_adm_planka
      - DEFAULT_ADMIN_PASSWORD=$senha_adm_planka
      - DEFAULT_ADMIN_EMAIL=$email_adm_planka

    ##  Dados do SMTP
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/planka${1:+_$1}
      
    ##  Secret Keys
      - SECRET_KEY=$secret_key

    ## Configuracoes do Planaka
      - ALLOW_ALL_TO_CREATE_PROJECTS=true ## true = Permite que qualquer usuario crie projetos

    ##  Dados SMTP
      - SMTP_NAME=Planka
      - SMTP_FROM=Planka <$email_planka>
      - SMTP_USER=$usuario_email_planka
      - SMTP_PASSWORD=$senha_email_planka
      - SMTP_HOST=$smtp_email_planka
      - SMTP_PORT=$porta_smtp_planka
      - SMTP_SECURE=$smtp_secure_planka
      - SMTP_TLS_REJECT_UNAUTHORIZED=$tls_reject

    ##  Configurar Webhook Global
      #- WEBHOOKS=[{
      #-   "url": "https://webhook.dominio.com",
      #-   "accessToken": "token_se_tiver",
      #-   "events": ["cardCreate", "cardUpdate", "cardDelete"],
      #-   "excludedEvents": ["notificationCreate", "notificationUpdate"]
      #- }]
    
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
        - traefik.http.routers.planka${1:+_$1}.rule=Host(\`$url_planka\`)
        - traefik.http.services.planka${1:+_$1}.loadbalancer.server.port=1337
        - traefik.http.routers.planka${1:+_$1}.service=planka${1:+_$1}
        - traefik.http.routers.planka${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.planka${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.planka${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  planka${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - planka${1:+_$1}_redis:/data

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
  planka${1:+_$1}_avatars:
    external: true
    name: planka${1:+_$1}_avatars
  planka${1:+_$1}_backgrounds:
    external: true
    name: planka${1:+_$1}_backgrounds
  planka${1:+_$1}_attachments:
    external: true
    name: planka${1:+_$1}_attachments
  planka${1:+_$1}_redis:
    external: true
    name: planka${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do planka"
fi
STACK_NAME="planka${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c planka.yaml planka > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do planka"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest ghcr.io/plankanban/planka:latest

## Usa o servico wait_planka para verificar se o servico esta online
wait_stack planka${1:+_$1}_planka${1:+_$1}_redis planka${1:+_$1}_planka${1:+_$1}_app


cd dados_vps

cat > dados_planka${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ PLANKA ]

Dominio do Planka: https://$url_planka

Usuario: $user_adm_planka

Email: $email_adm_planka

Senha: $senha_adm_planka

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
echo -e "\e[32m[ PLANKA ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_planka\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_adm_planka\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m $email_adm_planka\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $senha_adm_planka\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###    ########## #######      ####### ####### ####   #######   ########### ################
## a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--    a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-
## a-a-a-' a-a-- a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-    a-a-a-'     a-a-a-'   a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a--  a-a-a-'        a-a-a-'   
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-     a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-  a-a-a-'        a-a-a-'   
## a-a-a-a-a-"a-a-a-a-"a-a-a-a-'     a-a-a-'         a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--   a-a-a-'   
##  a-a-a-a-a-a-a-a- a-a-a-     a-a-a-          a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-   a-a-a-   

