#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_langflow() {

## Verifica os recursos
recursos 2 2 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_langflow

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do Builder
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para LangFlow (ex: langflow.example.com): \e[0m" && read -r url_langflow
    echo ""

    ##Pergunta o Usuario para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -e "$amarelo--> Minimo 5 caracteres. Evite os caracteres especiais: \!#$ e/ou espaco"
    echo -en "\e[33mDigite um usuario para o LangFlow (ex: admin): \e[0m" && read -r user_langflow
    echo ""
    
    ##Pergunta a Senha para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "$amarelo--> Evite os caracteres especiais: \!#$"
    echo -en "\e[33mDigite uma senha para o usuario do LangFlow (ex: @Senha123_): \e[0m" && read -r pass_langflow
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_langflow
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Builder
    echo -e "\e[33mDominio do Langflow:\e[97m $url_langflow\e[0m"
    echo ""

    ## Informacao sobre URL do Builder
    echo -e "\e[33mUsuario:\e[97m $user_langflow\e[0m"
    echo ""

    ## Informacao sobre URL do Builder
    echo -e "\e[33mSenha:\e[97m $pass_langflow\e[0m"
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
        nome_langflow

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done


## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO LANGFLOW \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nada nada nada.. so para aparecer a mensagem de passo..

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "langflow${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "langflow${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO LANGFLOW \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
key_langflow=$(python3 -c 'from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())')

## Criando a stack langflow.yaml
cat > langflow${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.8"
services:

## --------------------------- FELSEN --------------------------- ##

  langflow${1:+_$1}_app:
    image: langflowai/langflow:latest

    volumes:
      - langflow${1:+_$1}_data:/app/langflow

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Dados de acesso
      - LANGFLOW_SUPERUSER=$user_langflow
      - LANGFLOW_SUPERUSER_PASSWORD=$pass_langflow
      - LANGFLOW_AUTO_LOGIN=false
      - BACKEND_URL=https://$url_langflow
      - LANGFLOW_HOST=0.0.0.0
      - LANGFLOW_PORT=7860

    ## " Configuracao do diretorio de dados
      - LANGFLOW_CONFIG_DIR=/app/langflow

    ##  Secret Key
    ## Gere em: https://www.uuidgenerator.net/api/version1
      - LANGFLOW_SECRET_KEY=$key_langflow

    ## 'aEUR' Permitir novas incriAAes
      - LANGFLOW_NEW_USER_IS_ACTIVE=false ## false = Precisa autorizar novas inscricoes

    ##  Logging
      - LANGFLOW_LOG_LEVEL=INFO

    ## -"i Dados do Postgres
      - LANGFLOW_DATABASE_URL=postgresql://postgres:$senha_postgres@postgres:5432/langflow${1:+_$1}
    
    ##  Dados do Redis
      - LANGFLOW_CACHE_TYPE=redis
      - LANGFLOW_REDIS_HOST=langflow${1:+_$1}_redis
      - LANGFLOW_REDIS_PORT=6379
      - LANGFLOW_REDIS_DB=0
      - LANGFLOW_REDIS_CACHE_EXPIRE=3600

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 2048M
      labels:
        - traefik.enable=true
        - traefik.http.routers.langflow${1:+_$1}_app.rule=Host(\`$url_langflow\`) ## Url da aplicacao
        - traefik.http.services.langflow${1:+_$1}_app.loadBalancer.server.port=7860
        - traefik.http.routers.langflow${1:+_$1}_app.service=langflow${1:+_$1}_app
        - traefik.http.routers.langflow${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.langflow${1:+_$1}_app.tls.certresolver=letsencryptresolver

## --------------------------- FELSEN --------------------------- ##

  langflow${1:+_$1}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - langflow${1:+_$1}_redis:/data

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
  langflow${1:+_$1}_data:
    external: true
    name: langflow${1:+_$1}_data
  langflow${1:+_$1}_redis:
    external: true
    name: langflow${1:+_$1}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do langflow"
fi
STACK_NAME="langflow${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c langflow.yaml langflow > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do langflow"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest langflowai/langflow:latest

sleep 5

## Ajustar o "DONO" do diretorio
chown -R 1000:0 /var/lib/docker/volumes/langflow${1:+_$1}_data/_data

## Ajustar as "PERMISSOES" do diretorio
chmod -R 755 /var/lib/docker/volumes/langflow${1:+_$1}_data/_data

## Usa o servico wait_stack "langflow" para verificar se o servico esta online
wait_stack langflow${1:+_$1}_langflow${1:+_$1}_redis langflow${1:+_$1}_langflow${1:+_$1}


cd dados_vps

cat > dados_langflow${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ LANGFLOW ]

Dominio do langflow: https://$url_langflow

Usuario: $user_langflow

Senha: $pass_langflow
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
echo -e "\e[32m[ LANGFLOW ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_langflow\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_langflow\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_langflow\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ####### ############   ###    ####### #######  #######      ########### ################
## a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'    a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--     a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-
## a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-"a-a-a-- a-a-a-'    a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'     a-a-a-'a-a-a-a-a-a--  a-a-a-'        a-a-a-'   
## a-a-a-'   a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'    a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-   a-a-a-'a-a-a-"a-a-a-  a-a-a-'        a-a-a-'   
## a-a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'    a-a-a-'     a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--   a-a-a-'   
##  a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-    a-a-a-     a-a-a-  a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a- a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-   a-a-a-   

