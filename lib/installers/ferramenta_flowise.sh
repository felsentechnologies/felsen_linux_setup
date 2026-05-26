#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_flowise() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_flowise

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Flowise (ex: flowise.example.com): \e[0m" && read -r url_flowise
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_flowise
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Flowise
    echo -e "\e[33mDominio do Flowise\e[97m $url_flowise\e[0m"
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
        nome_flowise

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO FLOWISE \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Ja sabe ne ksk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "flowise${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "flowise${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO FLOWISE \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando uma Encryption Key Aleatoria
encryption_key=$(openssl rand -hex 16)

## Criando a stack flowise.yaml
cat > flowise${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  flowise${1:+_$1}:
    image: flowiseai/flowise:latest ## Versao do Flowise

    volumes:
     - flowise${1:+_$1}_data:/root/.flowise

    networks:
     - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Dados do Postgres
      - DATABASE_TYPE=postgres
      - DATABASE_HOST=postgres
      - DATABASE_PORT=5432
      - DATABASE_USER=postgres
      - DATABASE_PASSWORD=$senha_postgres
      - DATABASE_NAME=flowise${1:+_$1}

    ##  Configuracao de Armazenamento
      - STORAGE_TYPE=local ## local ou s3
      #- S3_ENDPOINT_URL=
      #- S3_STORAGE_BUCKET_NAME=flowise${1:+-$1}
      #- S3_STORAGE_ACCESS_KEY_ID=
      #- S3_STORAGE_SECRET_ACCESS_KEY=
      #- S3_STORAGE_REGION=eu-south
      #- S3_FORCE_PATH_STYLE=true

     ##  Dados do SMTP
      #- SENDER_EMAIL=email@dominio.com
      #- SMTP_USER=email@dominio.com
      #- SMTP_PASSWORD=@Senha123_
      #- SMTP_HOST=smtp.dominio.com
      #- SMTP_PORT=587
      #- SMTP_SECURE=false
      #- ALLOW_UNAUTHORIZED_CERTS=false
      
    ## Configuracao da Aplicacao
      - NUMBER_OF_PROXIES=1
      - SHOW_COMMUNITY_NODES=true
      - DISABLE_FLOWISE_TELEMETRY=true
    
    ## " Encryption Key
      - FLOWISE_SECRETKEY_OVERWRITE=$encryption_key

    ## -i DiretArio das API Keys
      - APIKEY_PATH=/root/.flowise
      - SECRETKEY_PATH=/root/.flowise

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
        - traefik.http.routers.flowise${1:+_$1}.rule=Host(\`$url_flowise\`) ## Url da aplicacao
        - traefik.http.services.flowise${1:+_$1}.loadBalancer.server.port=3000
        - traefik.http.routers.flowise${1:+_$1}.service=flowise${1:+_$1}
        - traefik.http.routers.flowise${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.flowise${1:+_$1}.tls.certresolver=letsencryptresolver

## --------------------------- FELSEN --------------------------- ##

volumes:
  flowise${1:+_$1}_data:
    external: true

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Flowise"
fi
STACK_NAME="flowise${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c flowise.yaml flowise  > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Flowise"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull flowiseai/flowise:latest

## Usa o servico wait_flowise para verificar se o servico esta online
wait_stack flowise${1:+_$1}_flowise${1:+_$1}


cd dados_vps

cat > dados_flowise${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ FLOWISE ]

Dominio do Flowise: https://$url_flowise

Email: Precisa de criar no primeiro acesso do Flowise

Senha: Precisa de criar no primeiro acesso do Flowise
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
echo -e "\e[32m[ FLOWISE ]\e[0m"
echo ""
echo -e "\e[33mDominio:\e[97m https://$url_flowise\e[0m"
echo ""
echo -e "\e[33mUEmail:\e[97m Precisa de criar no primeiro acesso do Flowise\e[0m"
echo ""
echo -e "\e[33mSenha:\e[97m Precisa de criar no primeiro acesso do Flowise\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  #######      ###### ####### ####   ###########   ###    ###  ###
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-     a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'a-a-a-'a-a-a-a-a--  a-a-a-'    a-a-a-'  a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-a--    a-a-a-a-a-a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-'a-a-a-"a-a-a-- a-a-a-'    a-a-a-a-a-a-a-a-'
## a-a-a-"a-a-a-a- a-a-a-'   a-a-a-'    a-a-a-"a-a-a-a-a-'a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'a-a-a-'a-a-a-a--a-a-a-'    a-a-a-a-a-a-a-a-'
## a-a-a-'     a-a-a-a-a-a-a-a-"a-    a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'a-a-a-'a-a-a-' a-a-a-a-a-a-'         a-a-a-'
## a-a-a-      a-a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a-a-  a-a-a-a-a-         a-a-a-

