#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_vaultwarden() {

## Verifica os recursos
recursos 1 1 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_vaultwarden

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para o VaultWarden (ex: vaultwarden.example.com): \e[0m" && read -r url_vaultwarden
    echo ""
    
    ## Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite um Email para o SMTP (ex: contato@example.com): \e[0m" && read -r email_vaultwarden
    echo ""

    ## Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_smtp_vaultwarden
    echo ""
    
    ## Pergunta a Senha SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do email (ex: @Senha123_): \e[0m" && read -r senha_vaultwarden
    echo ""
    
    ## Pergunta o Host SMTP
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do email (ex: smtp.hostinger.com): \e[0m" && read -r host_vaultwarden
    echo ""
    
    ## Pergunta a Porta SMTP 
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a Porta SMTP do email (ex: 465): \e[0m" && read -r porta_vaultwarden
    echo ""
    
    if [ "$porta_vaultwarden" -eq 465 ] || [ "$porta_vaultwarden" -eq 25 ]; then
        ssl_vaultwarden=force_tls
    else
        ssl_vaultwarden=starttls
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_vaultwarden
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio:\e[97m $url_vaultwarden\e[0m"
    echo ""
    
    ## Informacao sobre Email
    echo -e "\e[33mEmail SMTP:\e[97m $email_vaultwarden\e[0m"
    echo ""

    ## Informacao sobre Usuario do Email
    echo -e "\e[33mUsuario do Email:\e[97m $user_smtp_vaultwarden\e[0m"
    echo ""
    
    ## Informacao sobre Senha
    echo -e "\e[33mSenha SMTP:\e[97m $senha_vaultwarden\e[0m"
    echo ""
    
    ## Informacao sobre Host
    echo -e "\e[33mHost SMTP:\e[97m $host_vaultwarden\e[0m"
    echo ""
    
    ## Informacao sobre Porta
    echo -e "\e[33mPorta SMTP:\e[97m $porta_vaultwarden\e[0m"
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
        nome_vaultwarden

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO VAULTWARDEN \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nada nada nada.. so para aparecer a mensagem de passo.

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
    criar_banco_postgres_da_stack "vaultwarden${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "vaultwarden${1:+_$1}"
fi

pegar_senha_postgres > /dev/null 2>&1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO VAULTWARDEN \e[33m[3/4]\e[0m"
echo ""
sleep 1

token_admin=$(openssl rand -hex 16)

## Criando a stack vaultwarden.yaml
cat > vaultwarden${1:+_$1}.yaml <<-__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  vaultwarden${1:+_$1}:
    image: vaultwarden/server:latest

    volumes:
      - vaultwarden${1:+_$1}_data:/data

    networks:
      - $nome_rede_interna

    #ports:
    #  - 1973:80

    environment:
    ##  Dominio do Dashboard
      - WEB_VAULT_ENABLED=true
      - DOMAIN=https://$url_vaultwarden
    
    ## 'iaEUR-i Configuracoes de Administrador
      - ADMIN_TOKEN=$token_admin
      - ADMIN_SESSION_LIFETIME=5

    ## " Permitir novos registros
      - SIGNUPS_ALLOWED=true ## true = permitir novos registros | false = nao permitir novos registros

    ##  Dados do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/vaultwarden${1:+_$1}

    ##  Dados do SMTP
      - SMTP_FROM=$email_vaultwarden
      - SMTP_USERNAME=$user_smtp_vaultwarden
      - SMTP_PASSWORD=$senha_vaultwarden
      - SMTP_HOST=$host_vaultwarden
      - SMTP_PORT=$porta_vaultwarden
      - SMTP_SECURITY=$ssl_vaultwarden

    ##  Configuracao do Websocket
      - WEBSOCKET_ENABLED=true

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.vaultwarden${1:+_$1}.rule=Host(\`$url_vaultwarden\`)"
        - "traefik.http.routers.vaultwarden${1:+_$1}.service=vaultwarden${1:+_$1}"
        - "traefik.http.routers.vaultwarden${1:+_$1}.entrypoints=websecure"
        - "traefik.http.services.vaultwarden${1:+_$1}.loadbalancer.server.port=80"
        - "traefik.http.routers.vaultwarden${1:+_$1}.tls=true"
        - "traefik.http.routers.vaultwarden${1:+_$1}.tls.certresolver=letsencryptresolver"
        - "traefik.http.services.vaultwarden${1:+_$1}.loadbalancer.passHostHeader=true"
        - "traefik.http.routers.vaultwarden${1:+_$1}.middlewares=compresstraefik"
        - "traefik.http.middlewares.compresstraefik.compress=true"
        - "traefik.docker.network=$nome_rede_interna"

## --------------------------- FELSEN --------------------------- ##

volumes:
  vaultwarden${1:+_$1}_data:
    external: true
    name: vaultwarden${1:+_$1}_data

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do vaultwarden"
fi
STACK_NAME="vaultwarden${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c vaultwarden.yaml vaultwarden > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do vaultwarden"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull vaultwarden/server:latest

## Usa o servico wait_vaultwarden para verificar se o servico esta online
wait_stack vaultwarden${1:+_$1}_vaultwarden${1:+_$1}


cd dados_vps

cat > dados_vaultwarden${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ VAULTWARDEN ]

Dominio do vaultwarden: https://$url_vaultwarden

Token do /admin: $token_admin

Email: Precisa de criar dentro do vaultwarden

Senha: Precisa de criar dentro do vaultwarden
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
echo -e "\e[32m[ VAULTWARDEN ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_vaultwarden\e[0m"
echo ""

echo -e "\e[33mToken do /admin:\e[97m $token_admin\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Precisa de criar dentro do VaultWarden\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar dentro do VaultWarden\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   ##############  ############ ##########      ####### ###   ########## 
## a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a-a-a-'     a-a-a-"a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a--   a-a-a-a-a-"a-    a-a-a-'   a-a-a-'     a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-   a-a-a-"a-a-a--    a-a-a-'   a-a-a-'     a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'
## a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-"a- a-a-a--   a-a-a-'   a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-   a-a-a-    a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- 

