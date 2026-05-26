#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_zep() {

## Verifica os recursos
recursos 1 1 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_zep

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos    
while true; do

    ## Pergunta o Dominio da ferramenta
    echo -e "\e[97mPasso$amarelo 1/4\e[0m"
    echo -en "\e[33mDigite o Dominio para o Zep (ex: zep.example.com): \e[0m" && read -r url_zep
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 2/4\e[0m"
    echo -en "\e[33mDigite um usuario (ex: Felsen): \e[0m" && read -r user_zep
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 3/4\e[0m"
    echo -en "\e[33mDigite a senha para o usuario (ex: @Senha123_): \e[0m" && read -r pass_zep
    echo ""

    ## Pergunta o nome do Usuario do Motor
    echo -e "\e[97mPasso$amarelo 4/4\e[0m"
    echo -en "\e[33mApiKey OpenAI: \e[0m" && read -r apikey_openai_zep
    echo ""

    ## Criando uma Encryption Key Aleatoria
    encryption_key_zep=$(openssl rand -hex 16)
    apikey_zep=$(openssl rand -hex 16)
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_zep
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre o dominio
    echo -e "\e[33mDominio do Zep:\e[97m $url_zep\e[0m"
    echo ""

    ## Informacao sobre o usuario
    echo -e "\e[33mUsuario do Zep:\e[97m $user_zep\e[0m"
    echo ""

    ## Informacao sobre a senha
    echo -e "\e[33mSenha do Zep:\e[97m $pass_zep\e[0m"
    echo ""

    ## Informacao sobre o usuario
    echo -e "\e[33mApiKey da OpenAI:\e[97m $apikey_openai_zep\e[0m"
    echo ""

    ## Informacao sobre a senha
    echo -e "\e[33mApiKey do Zep:\e[97m $apikey_zep\e[0m"
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
        nome_zep

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO ZEP \e[33m[1/4]\e[0m"
echo ""
sleep 1


cd
mkdir temp
cd temp

git clone --depth 1 https://github.com/felsen-labs/linux-setup > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/1 - [ OK ] - Baixando Repositorio do Zep"
else
    echo "1/1 - [ OFF ] - Baixando Repositorio do Zep"
    echo "Nao foi possivel Baixar."
fi

mv Felsen Linux Setup/Extras/Zep /root/zep${1:+_$1}

cd
cd
rm -r temp
cd
echo ""

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES VECTOR \e[33m[2/4]\e[0m"
echo ""
sleep 1

dados
verificar_container_pgvector
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - PgVector ja instalado"
    pegar_senha_pgvector > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do PgVector"
    criar_banco_pgvector_da_stack "zep${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_pgvector
    pegar_senha_pgvector > /dev/null 2>&1
    criar_banco_pgvector_da_stack "zep${1:+_$1}"
fi

sleep 5

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO ZEP \e[33m[3/4]\e[0m"
echo ""
sleep 1

hashed_senha_zep=$(htpasswd -nb $user_zep $pass_zep | sed -e s/\\$/\\$\\$/g)

## Criando a stack zep.yaml
cat > zep${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  zep${1:+_$1}_nlp:
    image: ghcr.io/getzep/zep-nlp-server:latest

    networks:
      - $nome_rede_interna

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager

## --------------------------- FELSEN --------------------------- ##

  zep${1:+_$1}_app:
    image: ghcr.io/getzep/zep:latest

    volumes:
      - /root/zep${1:+_$1}/config.yaml:/app/config.yaml

    networks:
      - $nome_rede_interna

    environment:
    ##  Dados Postgres
      - ZEP_STORE_TYPE=postgres
      - ZEP_STORE_POSTGRES_DSN=postgres://postgres:$senha_pgvector@pgvector:5432/zep${1:+_$1}?sslmode=disable

    ## " Dados de acesso:
      - ZEP_AUTH_SECRET=$apikey_zep

    ##  Dados OpenAI
      - ZEP_OPENAI_API_KEY=$apikey_openai_zep

    ##  Dados NLP
      - ZEP_NLP_SERVER_URL=http://zep${1:+_$1}_nlp:5557

    ##  Configuracoes de extracao
      - ZEP_EXTRACTORS_DOCUMENTS_EMBEDDINGS_SERVICE=openai
      - ZEP_EXTRACTORS_DOCUMENTS_EMBEDDINGS_DIMENSIONS=1536
      - ZEP_EXTRACTORS_MESSAGES_EMBEDDINGS_SERVICE=openai
      - ZEP_EXTRACTORS_MESSAGES_EMBEDDINGS_DIMENSIONS=1536
      - ZEP_EXTRACTORS_MESSAGES_SUMMARIZER_EMBEDDINGS_SERVICE=openai
      - ZEP_EXTRACTORS_MESSAGES_SUMMARIZER_EMBEDDINGS_DIMENSIONS=1536

    ## -i Configuracao Graphiti
      - ZEP_GRAPHITI_URL=http://zep${1:+_$1}_graphiti:8003

    ##  Degub:
      - ZEP_LOG_LEVEL=debug

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        ##  Dominio da API
        - traefik.http.routers.zep${1:+_$1}.rule=Host(\`$url_zep\`)
        - traefik.http.routers.zep${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.zep${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.zep${1:+_$1}.loadbalancer.server.port=8000
        - traefik.http.services.zep${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.routers.zep${1:+_$1}.service=zep${1:+_$1}

        ## " AutenticaAAo do /admin
        - traefik.http.routers.zep${1:+_$1}_api.rule=Host(\`$url_zep\`) && PathPrefix(\`/admin\`)
        - traefik.http.routers.zep${1:+_$1}_api.entrypoints=websecure
        - traefik.http.routers.zep${1:+_$1}_api.tls.certresolver=letsencryptresolver
        - traefik.http.services.zep${1:+_$1}_api.loadbalancer.server.port=8000
        - traefik.http.services.zep${1:+_$1}_api.loadbalancer.passHostHeader=true
        - traefik.http.routers.zep${1:+_$1}_api.service=zep${1:+_$1}_api
        - traefik.http.routers.zep${1:+_$1}_api.middlewares=authzep${1:+_$1}_api
        - traefik.http.middlewares.authzep${1:+_$1}_api.basicauth.users=$hashed_senha_zep

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
    echo "Nao foi possivel criar a stack do Zep"
fi
STACK_NAME="zep${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c zep.yaml zep #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do zep"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""

## Baixando imagens:
pull ghcr.io/getzep/zep-nlp-server:latest ghcr.io/getzep/zep:latest

## Usa o servico wait_zep para verificar se o servico esta online
wait_stack zep${1:+_$1}_zep${1:+_$1}_nlp zep${1:+_$1}_zep${1:+_$1}_app


wait_30_sec

cd dados_vps

cat > dados_zep${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ ZEP ]

Dominio do Zep: https://$url_zep/admin

Usuario do Zep: $user_zep

Senha do Zep: $pass_zep

ApiKey do Zep: $apikey_zep
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
echo -e "\e[32m[ ZEP ]\e[0m"
echo ""

echo -e "\e[97mDominio:\e[33m https://$url_zep/admin\e[0m"
echo ""

echo -e "\e[97mUsuario do Zep:\e[33m $user_zep\e[0m"
echo ""

echo -e "\e[97mSenha do Zep:\e[33m $pass_zep\e[0m"
echo ""

echo -e "\e[97mApiKey do Zep:\e[33m $apikey_zep\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###  ######   #######   #######  ######   ########## 
## a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-- a-a-a-a-a-'a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-
## a-a-a-"a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-
## a-a-a-  a-a-a- a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- 
                                                     
