#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_docuseal() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_docuseal

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o dominio para o Docuseal (ex: docuseal.example.com): \e[0m" && read -r url_docuseal
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite a Email SMTP (ex: contato@example.com): \e[0m" && read -r email_smtp_docuseal
    echo ""

    ##Pergunta o usuario do Email SMTP
    echo -e "\e[97mPasso$amarelo 3/6\e[0m"
    echo -e "$amarelo--> Caso nao tiver um usuario do email, use o proprio email abaixo"
    echo -en "\e[33mDigite o Usuario para SMTP (ex: Felsen ou contato@example.com): \e[0m" && read -r user_smtp_docuseal
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ | Se estiver usando gmail use a senha de app"
    echo -en "\e[33mDigite a Senha SMTP (ex: @Senha123_): \e[0m" && read -r senha_smtp_docuseal
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -en "\e[33mDigite o Host SMTP (ex: smtp.hostinger.com): \e[0m" && read -r host_smtp_docuseal
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite a Porta SMTP (ex: 465): \e[0m" && read -r porta_smtp_docuseal
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_docuseal
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do docuseal
    echo -e "\e[33mDominio do docuseal:\e[97m $url_docuseal\e[0m"
    echo ""

    ## Informacao sobre URL do docuseal
    echo -e "\e[33mEmail SMTP:\e[97m $email_smtp_docuseal\e[0m"
    echo ""

    ## Informacao sobre URL do docuseal
    echo -e "\e[33mUser SMTP:\e[97m $user_smtp_docuseal\e[0m"
    echo ""    

    ## Informacao sobre URL do docuseal
    echo -e "\e[33mSenha SMTP:\e[97m $senha_smtp_docuseal\e[0m"
    echo ""

    ## Informacao sobre URL do docuseal
    echo -e "\e[33mHost SMTP:\e[97m $host_smtp_docuseal\e[0m"
    echo ""

    ## Informacao sobre URL do docuseal
    echo -e "\e[33mPorta SMTP:\e[97m $porta_smtp_docuseal\e[0m"
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
        nome_docuseal

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO DOCUSEAL \e[33m[1/4]\e[0m"
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
    criar_banco_postgres_da_stack "docuseal${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "docuseal${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO DOCUSEAL \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Pegar o dominio do email
dominio_smtp_docuseal="${email_smtp_docuseal}"

key_docuseal=$(openssl rand -hex 16)
key_docuseal2=$(openssl rand -hex 16)


## Criando a stack docuseal.yaml
cat > docuseal${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  docuseal${1:+_$1}:
    image: docuseal/docuseal:latest

    volumes:
      - docuseal${1:+_$1}_data:/data

    networks:
      - $nome_rede_interna

    environment:
    ##  Dados de Acesso
      - HOST=$url_docuseal
      - FORCE_SSL=true

    ## " Secret Key
      - SECRET_KEY_BASE=$key_docuseal

    ## -"i Dados do Postgres
      - DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/docuseal${1:+_$1}

    ##  Dados SMTP
      - SMTP_USERNAME=$user_smtp_docuseal
      - SMTP_PASSWORD=$senha_smtp_docuseal
      - SMTP_ADDRESS=$host_smtp_docuseal
      - SMTP_PORT=$porta_smtp_docuseal
      - SMTP_FROM=$email_smtp_docuseal
      - SMTP_DOMAIN=$dominio_smtp_docuseal
      - SMTP_AUTHENTICATION=login

    ##  Dados do S3
      ##- AWS_ACCESS_KEY_ID=
      ##- AWS_SECRET_ACCESS_KEY=
      ##- S3_ATTACHMENTS_BUCKET=
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.docuseal${1:+_$1}.rule=Host(\`$url_docuseal\`)
        - traefik.http.services.docuseal${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.docuseal${1:+_$1}.service=docuseal${1:+_$1}
        - traefik.http.routers.docuseal${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.docuseal${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.docuseal${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  docuseal${1:+_$1}_data:
    external: true
    name: docuseal${1:+_$1}_data

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do docuseal"
fi
STACK_NAME="docuseal${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c docuseal.yaml docuseal > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do docuseal"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull docuseal/docuseal:latest

## Usa o servico wait_docuseal para verificar se o servico esta online
wait_stack docuseal${1:+_$1}_docuseal${1:+_$1}


cd dados_vps

cat > dados_docuseal${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ DOCUSEAL ]

Dominio do docuseal: https://$url_docuseal

Usuario: Precisa de criar ao fazer o primeiro login

Senha: Precisa de criar ao fazer o primeiro login

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
echo -e "\e[32m[ DOCUSEAL ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_docuseal\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa de criar ao fazer o primeiro login\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar ao fazer o primeiro login\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### #######  ###### ######## ###### ####   ### ###### 
## a-a-a-"a-a-a-a-a- a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-'  a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a-'
## a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-'     a-a-a-'  a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-'  a-a-a-'
##  a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-a-a-  a-a-a-

