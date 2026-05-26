#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_humhub() {

## Verifica os recursos
recursos 1 1 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_humhub

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/10\e[0m"
    echo -en "\e[33mDigite o Dominio para o HumHub (ex: humhub.example.com): \e[0m" && read -r url_humhub
    echo ""

    ## Pergunta o usuario da ferramenta
    echo -e "\e[97mPasso$amarelo 2/10\e[0m"
    echo -e "$amarelo--> AutoConfig e uma funcao que pula as etapas de configuracoes pos instalacao"
    echo -en "\e[33mUsar o AutoConfig do HumHub (exemplo: 0 para nao ou 1 para sim): \e[0m" && read -r autoconfig_humhub_valor
    echo ""

    if [ "$autoconfig_humhub_valor" -eq 1 ]; then
      autoconfig_humhub="- HUMHUB_AUTO_INSTALL=1"
    elif [ "$autoconfig_humhub_valor" -eq 0 ]; then
      autoconfig_humhub="#- HUMHUB_AUTO_INSTALL=0"
    else
      echo "Erro ao receber resposta do AutoConfig. Resposta precisa ser 0 ou 1"
      echo "Definindo para 0"
      autoconfig_humhub_valor="0"
      autoconfig_humhub="#- HUMHUB_AUTO_INSTALL=0"
    fi

    ## Pergunta o usuario da ferramenta
    echo -e "\e[97mPasso$amarelo 3/10\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ e/ou espacos"
    echo -en "\e[33mDigite um Usuario Admin (ex: Felsen): \e[0m" && read -r user_humhub
    echo ""

    ## Pergunta o email da ferramenta
    echo -e "\e[97mPasso$amarelo 4/10\e[0m"
    echo -en "\e[33mDigite o Email do Admin: (ex: contato@example.com): \e[0m" && read -r email_humhub
    echo ""
    
    ## Pergunta o senha da ferramenta
    echo -e "\e[97mPasso$amarelo 5/10\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$"
    echo -en "\e[33mDigite uma Senha para o Admin (ex: @Senha123_): \e[0m" && read -r pass_humhub
    echo ""

    ## Pergunta o Email SMTP
    echo -e "\e[97mPasso$amarelo 6/10\e[0m"
    echo -en "\e[33mDigite um Email para o SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_humhub
    echo ""

    ## Pergunta o User SMTP
    echo -e "\e[97mPasso$amarelo 7/10\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario do SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_smtp_humhub
    echo ""
    
    ## Pergunta a Senha SMTP
    echo -e "\e[97mPasso$amarelo 8/10\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP do email (ex: @Senha123_): \e[0m" && read -r senha_smtp_humhub
    echo ""
    
    ## Pergunta o Host SMTP
    echo -e "\e[97mPasso$amarelo 9/10\e[0m"
    echo -en "\e[33mDigite o Host SMTP do email (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_humhub
    echo ""
    
    ## Pergunta a Porta SMTP 
    echo -e "\e[97mPasso$amarelo 10/10\e[0m"
    echo -en "\e[33mDigite a Porta SMTP do email (ex: 465): \e[0m" && read -r porta_smtp_humhub
    echo ""

    if [ "$porta_smtp_humhub" -eq 465 ] || [ "$porta_smtp_humhub" -eq 25 ]; then
        porta_smtp_humhub_conv=1
    else
        porta_smtp_humhub_conv=0
    fi
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_humhub
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do HumHub:\e[97m $url_humhub\e[0m"
    echo ""

    echo -e "\e[33mUsar AutoConfig:\e[97m $autoconfig_humhub\e[0m"
    echo ""

    ## Informacao sobre Usuario Admin
    echo -e "\e[33mUsuario Admin:\e[97m $user_humhub\e[0m"
    echo ""

    ## Informacao sobre Email Admin
    echo -e "\e[33mEmail do Admin:\e[97m $email_humhub\e[0m"
    echo ""    

    ## Informacao sobre Senha Admin
    echo -e "\e[33mSenha do Admin:\e[97m $pass_humhub\e[0m"
    echo ""

    ## Informacao sobre Senha Admin
    echo -e "\e[33mEmail SMTP:\e[97m $email_smtp_humhub\e[0m"
    echo ""

    ## Informacao sobre Senha Admin
    echo -e "\e[33mUsuario SMTP:\e[97m $user_smtp_humhub\e[0m"
    echo ""

    ## Informacao sobre Senha Admin
    echo -e "\e[33mSenha SMTP:\e[97m $senha_smtp_humhub\e[0m"
    echo ""

    ## Informacao sobre Senha Admin
    echo -e "\e[33mHost SMTP:\e[97m $host_smtp_humhub\e[0m"
    echo ""

    ## Informacao sobre Senha Admin
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_humhub\e[0m"
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
        nome_humhub

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO HUMHUB \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO MYSQL \e[33m[2/4]\e[0m"
echo ""
sleep 1

dados

## Cria banco de dados do site no mysql
verificar_container_mysql
    if [ $? -eq 0 ]; then
        echo "1/3 - [ OK ] - MySQL ja instalado"
        pegar_senha_mysql > /dev/null 2>&1
        echo "2/3 - [ OK ] - Copiando senha do MySQL"
        criar_banco_mysql_da_stack "humhub${1:+_$1}"
        echo "3/3 - [ OK ] - Criando banco de dados"
        echo ""
    else
        ferramenta_mysql
        pegar_senha_mysql > /dev/null 2>&1
        criar_banco_mysql_da_stack "humhub${1:+_$1}"
    fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO HUMHUB \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack
cat > humhub${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  humhub${1:+_$1}_app:
    image: mriedmann/humhub:latest

    volumes:
      - humhub${1:+_$1}_data:/var/www/localhost/htdocs/protected/modules
      - humhub${1:+_$1}_uploads:/var/www/localhost/htdocs/uploads
      - humhub${1:+_$1}_assets:/var/www/localhost/htdocs/assets
      - humhub${1:+_$1}_themes:/var/www/localhost/htdocs/themes
      
    networks:
      - $nome_rede_interna
      
    environment:
    ## " Dados de acesso
      - HUMHUB_ADMIN_USERNAME=$user_humhub
      - HUMHUB_ADMIN_PASSWORD=$pass_humhub
      - HUMHUB_EMAIL=$email_humhub
      - HUMHUB_EMAIL_NAME=$user_humhub
      - HUMHUB_ADMIN_EMAIL=$email_humhub

    ## Dados SMTP
      - HUMHUB_MAILER_TRANSPORT_TYPE=smtp
      - HUMHUB_MAILER_SYSTEM_EMAIL_ADDRESS=$email_smtp_humhub
      - HUMHUB_MAILER_USERNAME=$user_smtp_humhub
      - HUMHUB_MAILER_PASSWORD=$senha_smtp_humhub
      - HUMHUB_MAILER_SYSTEM_EMAIL_NAME=Suporte
      - HUMHUB_MAILER_HOSTNAME=$host_smtp_humhub
      - HUMHUB_MAILER_PORT=$porta_smtp_humhub
      - HUMHUB_MAILER_ALLOW_SELF_SIGNED_CERTS=$porta_smtp_humhub_conv ## 0 = TLS | 1 = SSL
      
    ##  Dados do MySQL
      - HUMHUB_DB_HOST=mysql
      - HUMHUB_DB_USER=root
      - HUMHUB_DB_PASSWORD=$senha_mysql
      - HUMHUB_DB_NAME=humhub${1:+_$1}
      $autoconfig_humhub

    ##  Dados Redis
      - HUMHUB_REDIS_HOSTNAME=redis
      - HUMHUB_REDIS_PORT=6379
      - HUMHUB_CACHE_EXPIRE_TIME=3600
      - HUMHUB_CACHE_CLASS=yii\redis\Cache
      - HUMHUB_QUEUE_CLASS=humhub\modules\queue\driver\Redis
  
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
        - traefik.http.routers.humhub${1:+_$1}.rule=Host(\`$url_humhub\`)
        - traefik.http.routers.humhub${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.humhub${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.humhub${1:+_$1}.service=humhub${1:+_$1}
        - traefik.http.services.humhub${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.services.humhub${1:+_$1}.loadbalancer.passHostHeader=true


## --------------------------- FELSEN --------------------------- ##

  humhub${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - humhub${1:+_$1}_redis:/data

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
  humhub${1:+_$1}_data:
    external: true
    name: humhub${1:+_$1}_data
  humhub${1:+_$1}_uploads:
    external: true
    name: humhub${1:+_$1}_uploads
  humhub${1:+_$1}_themes:
    external: true
    name: humhub${1:+_$1}_themes
  humhub${1:+_$1}_assets:
    external: true
    name: humhub${1:+_$1}_assets
  humhub${1:+_$1}_redis:
    external: true
    name: humhub${1:+_$1}_redis

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do HumHub"
fi
STACK_NAME="humhub${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c humhub.yaml humhub > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do humhub"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest mriedmann/humhub:latest

## Usa o servico wait_calcom para verificar se o servico esta online
wait_stack humhub${1:+_$1}_humhub${1:+_$1}_redis humhub${1:+_$1}_humhub${1:+_$1}_app


cd dados_vps

cat > dados_humhub${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ HUMHUB ]

Dominio do humhub: $url_humhub

Usuario: $user_humhub

Email: $email_humhub

Senha: $pass_humhub

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
echo -e "\e[32m[ HUMHUB ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_humhub\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_humhub\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_humhub\e[0m"
echo ""

echo -e "\e[33mHost MySQL:\e[97m mysql\e[0m"
echo ""

echo -e "\e[33mUsuario MySQL:\e[97m root\e[0m"
echo ""

echo -e "\e[33mSenha MySQL:\e[97m $senha_mysql\e[0m"
echo ""

echo -e "\e[33mBase de dados MySQL:\e[97m humhub\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###   ### ####### ###   ########## ###     ########
## a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-a-a-
##  a-a-a-a-a-a-"a- a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a--
##   a-a-a-a-"a-  a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-a-a-a-a-a-'
##    a-a-a-'   a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'
##    a-a-a-    a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

