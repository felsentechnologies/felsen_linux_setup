#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_bolt() {

## Verifica os recursos
recursos 2 4 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_bolt

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Bolt (ex: bolt.example.com): \e[0m" && read -r url_bolt
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_bolt
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do bolt
    echo -e "\e[33mDominio do Bolt:\e[97m $url_bolt\e[0m"
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
        nome_bolt

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO BOLT \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO BOLT \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack bolt.yaml
cat > bolt${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  bolt${1:+_$1}_app:
    image: ghcr.io/stackblitz-labs/bolt.diy:latest
    command: pnpm run dockerstart

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracoes da Aplicacao
      - NODE_ENV=production
      - COMPOSE_PROFILES=production
      - PORT=5173
      - VITE_LOG_LEVEL=debug
      - VITE_HMR_HOST=$url_bolt
      - DEFAULT_NUM_CTX=32768
      - RUNNING_IN_DOCKER=true

    ## " Chaves de APIs (IA)
      #- OPENAI_API_KEY=
      #- OPEN_ROUTER_API_KEY=
      #- GROQ_API_KEY=
      #- HuggingFace_API_KEY=
      #- ANTHROPIC_API_KEY=
      #- GOOGLE_GENERATIVE_AI_API_KEY=
      #- XAI_API_KEY=
      #- TOGETHER_API_KEY=

    ##  Configuracoes de Servicos Externos
      #- OLLAMA_API_BASE_URL=
      #- TOGETHER_API_BASE_URL=
      #- AWS_BEDROCK_CONFIG=

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 4096M
      labels:
        - traefik.enable=true
        - traefik.http.routers.bolt${1:+_$1}_app.rule=Host(\`$url_bolt\`)
        - traefik.http.services.bolt${1:+_$1}_app.loadbalancer.server.port=5173
        - traefik.http.routers.bolt${1:+_$1}_app.service=bolt${1:+_$1}_app
        - traefik.http.routers.bolt${1:+_$1}_app.tls.certresolver=letsencryptresolver
        - traefik.http.routers.bolt${1:+_$1}_app.entrypoints=websecure
        - traefik.http.routers.bolt${1:+_$1}_app.tls=true

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
    echo "Nao foi possivel criar a stack do bolt"
fi
STACK_NAME="bolt${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c bolt.yaml bolt > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do bolt"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/stackblitz-labs/bolt.diy:latest

## Usa o servico wait_bolt para verificar se o servico esta online
wait_stack bolt${1:+_$1}_bolt${1:+_$1}_app


cd dados_vps

cat > dados_bolt${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ BOLT ]

Dominio do bolt: https://$url_bolt
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
echo -e "\e[32m[ BOLT ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_bolt\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###    ##########################   #### ###### ####### ####### #######   ### ####### 
## a-a-a-'    a-a-a-'a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a- 
## a-a-a-' a-a-- a-a-a-'a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a--  a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-'  a-a-a-a--
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a- a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'
## a-a-a-a-a-"a-a-a-a-"a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-' a-a-a- a-a-a-'a-a-a-'  a-a-a-'a-a-a-'     a-a-a-'     a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-
##  a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-     a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-     a-a-a-a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a- 

