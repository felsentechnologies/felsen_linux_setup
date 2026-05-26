#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_anythingllm() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_anythingllm

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Anything LLM (ex: anythingllm.example.com): \e[0m" && read -r url_anythingllm
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_anythingllm
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do anythingllm
    echo -e "\e[33mDominio do Anything LLM:\e[97m $url_anythingllm\e[0m"
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
        nome_anythingllm

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO ANYTHING LLM \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO PGVECTOR \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres e redis instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres
verificar_container_pgvector
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Pgvector ja instalado"
    pegar_senha_pgvector > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do PgVector"
    criar_banco_pgvector_da_stack "anythingllm${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_pgvector
    pegar_senha_pgvector > /dev/null 2>&1
    criar_banco_pgvector_da_stack "anythingllm${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO ANYTHING LLM \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando a stack anythingllm.yaml
cat > anythingllm${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  anythingllm${1:+_$1}:
    image: mintplexlabs/anythingllm:latest

    volumes:
      - anythingllm${1:+_$1}_storage:/app/server/storage
      - anythingllm${1:+_$1}_hotdir:/app/collector/hotdir
      - anythingllm${1:+_$1}_outputs:/app/collector/outputs

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracoes gerais
      - SERVER_PORT=3001
      - STORAGE_DIR=/app/server/storage
      - UID=1000
      - GID=1000

    ##  Dados do PgVector
      - VECTOR_DB=pgvector
      - PGVECTOR_CONNECTION_STRING=postgresql://postgres:$senha_pgvector@pgvector:5432/anythingllm${1:+_$1}

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
        - traefik.http.routers.anythingllm${1:+_$1}.rule=Host(\`$url_anythingllm\`)
        - traefik.http.services.anythingllm${1:+_$1}.loadbalancer.server.port=3001
        - traefik.http.routers.anythingllm${1:+_$1}.service=anythingllm${1:+_$1}
        - traefik.http.routers.anythingllm${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.anythingllm${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.anythingllm${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  anythingllm${1:+_$1}_storage:
    external: true
    name: anythingllm${1:+_$1}_storage
  anythingllm${1:+_$1}_hotdir:
    external: true
    name: anythingllm${1:+_$1}_hotdir
  anythingllm${1:+_$1}_outputs:
    external: true
    name: anythingllm${1:+_$1}_outputs

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do anythingllm"
fi
STACK_NAME="anythingllm${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c anythingllm.yaml anythingllm > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do anythingllm"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull mintplexlabs/anythingllm:latest

## Usa o servico wait_stack "anythingllm" para verificar se o servico esta online
wait_stack anythingllm${1:+_$1}_anythingllm${1:+_$1}


cd dados_vps

cat > dados_anythingllm <<__FELSEN_MANAGED_FILE__
[ ANYTHING LLM ]

Dominio do Anything LLM: https://$url_anythingllm

Usuario: Precisa criar no primeiro acesso do Anything LLM

Senha: Precisa criar no primeiro acesso do Anything LLM

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
echo -e "\e[32m[ ANYTHING LLM ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_anythingllm\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Anything LLM\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Anything LLM\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########  ### ####### ###### ###     ########## #######  ###### ###    ###
## a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'    a-a-a-'
## a-a-a-a-a-a--   a-a-a-a-a-"a- a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-'     a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-' a-a-- a-a-a-'
## a-a-a-"a-a-a-   a-a-a-"a-a-a-- a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-'     a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-a-a-a-a-a--a-a-a-"a- a-a-a--a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-"a-a-a-a-"a-
## a-a-a-a-a-a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a-a- 

