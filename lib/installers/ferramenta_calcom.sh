#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_calcom() {

## Verifica os recursos
recursos 1 1 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_calcom

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o dominio para o Cal (ex: calcom.example.com): \e[0m" && read -r url_calcom
    echo ""
    
    ## Pergunta o email SMTP
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite o Email para SMTP (ex: contato@example.com): \e[0m" && read -r email_calcom
    echo ""

    ## Pergunta o Ususario SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_calcom
    echo ""
    
    ## Pergunta a senha do SMTP
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do Email (ex: @Senha123_): \e[0m" && read -r senha_email_calcom
    echo ""
    
    ## Pergunta o Host SMTP do email
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP do Email (ex: smtp.hostinger.com): \e[0m" && read -r smtp_email_calcom
    echo ""
    
    ## Pergunta a porta SMTP do email
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a porta SMTP do Email (ex: 465): \e[0m" && read -r porta_smtp_calcom
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_calcom
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Cal.com\e[97m $url_calcom\e[0m"
    echo ""
    
    ## Informacao sobre Email SMTP
    echo -e "\e[33mEmail SMTP:\e[97m $email_calcom\e[0m"
    echo ""

    ## Informacao sobre Email SMTP
    echo -e "\e[33mUser SMTP:\e[97m $user_calcom\e[0m"
    echo ""    
    
    ## Informacao sobre Senha SMTP
    echo -e "\e[33mSenha SMTP:\e[97m $senha_email_calcom\e[0m"
    echo ""
    
    ## Informacao sobre Host SMTP
    echo -e "\e[33mHost SMTP:\e[97m $smtp_email_calcom\e[0m"
    echo ""
    
    ## Informacao sobre Porta SMTP
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_calcom\e[0m"
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
        nome_calcom

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO CALCOM \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "calcom${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "calcom${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO CAL.COM \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando key aleatoria
secret=$(openssl rand -hex 16)
secret2=$(openssl rand -hex 16)

## Criando a stack calcom.yaml
cat > calcom${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  calcom${1:+_$1}_app:
    image: calcom/cal.com:latest

    networks:
      - $nome_rede_interna

    environment:
    ##  Configuracao da aplicacao
      - NODE_ENV=production
      - NEXT_PUBLIC_DISABLE_SIGNUP=false ## false = novas inscricoes permitidas | true = novas incricoes fechadas
      - NEXT_PUBLIC_APP_NAME=Cal.com
      - NEXT_PUBLIC_COMPANY_NAME=Cal.com, Inc.
      - NEXT_PUBLIC_SINGLE_ORG_SLUG=Calcom TEST
      - CALCOM_TELEMETRY_DISABLED=1
      - TASKER_ENABLE_WEBHOOKS=0
      - TASKER_ENABLE_EMAILS=0
      - TZ=America/Sao_Paulo

    ##  Configuracao de URLs
      - NEXT_PUBLIC_WEBAPP_URL=https://$url_calcom
      - NEXTAUTH_URL=https://$url_calcom
      - NEXT_PUBLIC_CONSOLE_URL=https://$url_calcom
      - NEXT_PUBLIC_WEBSITE_URL=https://$url_calcom

    ## -"i Configuracao do Postgres
      - DATABASE_HOST=postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/calcom${1:+_$1}
      - DATABASE_DIRECT_URL=postgresql://postgres:$senha_postgres@postgres:5432/calcom${1:+_$1}

    ##  Configuracoes de Email e SMTP
      - NEXT_PUBLIC_SUPPORT_MAIL_ADDRESS=$email_calcom
      - EMAIL_FROM=$email_calcom
      - EMAIL_SERVER_HOST=$smtp_email_calcom
      - EMAIL_SERVER_PORT=$porta_smtp_calcom
      - EMAIL_SERVER_USER=$user_calcom
      - EMAIL_SERVER_PASSWORD=$senha_email_calcom

    ## " Encrypition
      - NEXTAUTH_SECRET=$secret 
      - CALENDSO_ENCRYPTION_KEY=$secret2
  
    ##  Integracao com Google (Calendario & Meet)
      #-GOOGLE_LOGIN_ENABLED=false
      #-GOOGLE_API_CREDENTIALS=

    ##  Integracao com FromBricks
      #-NEXT_PUBLIC_FORMBRICKS_HOST_URL=https://app.formbricks.com
      #-NEXT_PUBLIC_FORMBRICKS_ENVIRONMENT_ID=
      #-FORMBRICKS_FEEDBACK_SURVEY_ID=

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
        - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.calcom${1:+_$1}_app.rule=Host(\`$url_calcom\`) && PathPrefix(\`/\`)
        - traefik.http.routers.calcom${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.calcom${1:+_$1}_app.priority=1
        - traefik.http.routers.calcom${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.calcom${1:+_$1}_app.service=calcom${1:+_$1}_app
        - traefik.http.services.calcom${1:+_$1}_app.loadbalancer.server.port=3000
        - traefik.http.services.calcom${1:+_$1}_app.loadbalancer.passHostHeader=1

## --------------------------- FELSEN --------------------------- ##

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do CalCom"
fi
STACK_NAME="calcom${1:+_$1}"
stack_editavel # > /dev/null 2>&1

#docker stack deploy --prune --resolve-image always -c calcom.yaml calcom  > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do CalCom"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull calcom/cal.com:v4.7.8

## Usa o servico wait_stack "calcom" para verificar se o servico esta online
wait_stack calcom${1:+_$1}_calcom${1:+_$1}

cd dados_vps

cat > dados_calcom${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ CAL.COM ]

Dominio do CalCom: $url_calcom

Usuario: Precisa criar dentro do Calcom

Senha: Precisa criar dentro do Calcom

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
echo -e "\e[32m[ CAL.COM ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_calcom\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar dentro do Calcom\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar dentro do Calcom\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   #### ###### ###   ############### #######
## a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-
## ##########|#######|##|   ##|   ##|   ##|##|     
## a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a-a-'a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'     
## a-a-a-' a-a-a- a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-     a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a-    a-a-a-   a-a-a- a-a-a-a-a-a-a-
                                                
