#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_qdrant() {

## Verifica os recursos
recursos 1 1 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_qdrant

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio da ferramenta
    read -r ip _ <<<$(hostname -I)
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite dominio para o Qdrant (ex: qdrant.example.com): \e[0m" && read -r url_qdrant
    echo ""
    
    ## Pergunta quandos nodes deseja
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -en "\e[33mDigite quantos Nodes voce deseja (recomendado: 5, minimo: 1): \e[0m" && read -r nodes_qdrant
    echo ""

    key_qdrant=$(openssl rand -hex 16)
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_qdrant
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Qdrant:\e[97m $url_qdrant\e[0m"
    echo ""
    
    ## Informacao sobre quantidade de nodes
    echo -e "\e[33mQuantidade de Nodes:\e[97m $nodes_qdrant\e[0m"
    echo ""

    ## Informacao sobre Apikey
    echo -e "\e[33mApikey:\e[97m $key_qdrant\e[0m"
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
        nome_qdrant

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO QDRANT \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO QDRANT \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando o arquivo qdrant.yaml
suffix="${1:+_$1}"
filename="qdrant${suffix}.yaml"
stack_name="${stack_name:-${filename%.yaml}}"

cat <<__FELSEN_MANAGED_FILE__ > $filename
version: "3.7"
services:

__FELSEN_MANAGED_FILE__
containers_qdrant=""

for ((i=0; i< $nodes_qdrant; i++)); do
  node_name="qdrant${suffix}_node_$i"
  volume_name="qdrant${suffix}_data_$i"
  uri_node="qdrant${suffix}_node_$i"
  uri_node_0="qdrant${suffix}_node_0"
  
  # Nome completo do servico no Docker Swarm (stack_name + node_name)
  service_full_name="${stack_name}_${node_name}"
  
  # Acumula os nomes dos containers com o nome da stack
  if [ -z "$containers_qdrant" ]; then
    containers_qdrant="$service_full_name"
  else
    containers_qdrant="$containers_qdrant $service_full_name"
  fi

  # Adiciona comentario antes do servico (apenas no primeiro ou antes de cada servico subsequente)
  if ((i == 0)); then
    cat <<__FELSEN_MANAGED_FILE__ >> $filename
## --------------------------- FELSEN --------------------------- ##

  $node_name:
    image: qdrant/qdrant:latest ## Versao do Qdrant
__FELSEN_MANAGED_FILE__
  else
    cat <<__FELSEN_MANAGED_FILE__ >> $filename
  $node_name:
    image: qdrant/qdrant:latest ## Versao do Qdrant
__FELSEN_MANAGED_FILE__
  fi

  ## Command - diferente para node 0 e outros
  if ((i == 0)); then
    echo "    command: ./qdrant --uri 'http://$uri_node_0:6335'" >> $filename
  else
    sleep_time=$((10 + i * 3))
    echo "    command: bash -c \"sleep $sleep_time && ./qdrant --bootstrap 'http://$uri_node_0:6335' --uri 'http://$uri_node:6335'\"" >> $filename
  fi

  cat <<__FELSEN_MANAGED_FILE__ >> $filename

    volumes:
      - $volume_name:/qdrant/storage

    networks:
      - $nome_rede_interna
__FELSEN_MANAGED_FILE__
  ## Ports apenas no node 0 (comentados)
  if ((i == 0)); then
    cat <<__FELSEN_MANAGED_FILE__ >> $filename
    ## Descomente as linhas abaixo para usar via ip:porta
    # ports:
    #   - "6333:6333"  # HTTP REST API
    #   - "6334:6334"  # gRPC API
__FELSEN_MANAGED_FILE__
  fi

  cat <<__FELSEN_MANAGED_FILE__ >> $filename

    environment:
      - QDRANT__SERVICE__GRPC_PORT=6334
      - QDRANT__CLUSTER__ENABLED=true
      - QDRANT__CLUSTER__P2P__PORT=6335
      - QDRANT__CLUSTER__CONSENSUS__MAX_MESSAGE_QUEUE_SIZE=5000
      - QDRANT__LOG_LEVEL=INFO
      - QDRANT__SERVICE__API_KEY=$key_qdrant

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.3"
          memory: 1024M
__FELSEN_MANAGED_FILE__
  ## Labels do Traefik apenas no node 0
  if ((i == 0)); then
    cat <<__FELSEN_MANAGED_FILE__ >> $filename
      labels:
        - traefik.enable=true
        - traefik.http.routers.qdrant${suffix}.rule=Host(\`$url_qdrant\`)
        - traefik.http.services.qdrant${suffix}.loadbalancer.server.port=6333
        - traefik.http.routers.qdrant${suffix}.service=qdrant${suffix}
        - traefik.http.routers.qdrant${suffix}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.qdrant${suffix}.entrypoints=websecure
        - traefik.http.routers.qdrant${suffix}.tls=true
__FELSEN_MANAGED_FILE__
  fi

  # Adiciona comentario e linha em branco antes do proximo servico (exceto no ultimo)
  if ((i < $nodes_qdrant - 1)); then
    cat <<__FELSEN_MANAGED_FILE__ >> $filename

## --------------------------- FELSEN --------------------------- ##

__FELSEN_MANAGED_FILE__
  fi
done

cat <<__FELSEN_MANAGED_FILE__ >> $filename

## --------------------------- FELSEN --------------------------- ##

volumes:
__FELSEN_MANAGED_FILE__
for ((i=0; i< $nodes_qdrant; i++)); do
  volume_name="qdrant${suffix}_data_$i"
  cat <<__FELSEN_MANAGED_FILE__ >> $filename
  $volume_name:
    external: true
    name: $volume_name
__FELSEN_MANAGED_FILE__
done

cat <<__FELSEN_MANAGED_FILE__ >> $filename

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Qdrant"
fi

STACK_NAME="qdrant${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c qdrant.yaml qdrant  > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Qdrant"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Usa o servico wait_stack "qdrant" para verificar se o servico esta online
wait_stack $containers_qdrant


cd dados_vps

cat > dados_qdrant <<__FELSEN_MANAGED_FILE__
[ QDRANT ]

Dashboard do Qdrant: https://$url_qdrant/dashboard

Rest Url: https://$url_qdrant

Apikey: $key_qdrant
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
echo -e "\e[32m[ QDRANT ]\e[0m"
echo ""

echo -e "\e[33mDashboard:\e[97m https://$url_qdrant/dashboard\e[0m"
echo ""

echo -e "\e[33mRest Url:\e[97m https://$url_qdrant\e[0m"
echo ""

echo -e "\e[33mApikey:\e[97m $key_qdrant\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###    ### #######  ####### #######################      ############## ####   ####
## a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--    a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'
## a-a-a-' a-a-- a-a-a-'a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a--  a-a-a-'  a-a-a-'    a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-"a-a-a-'
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-  a-a-a-'  a-a-a-'    a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-"a-a-a-a-'
## a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-"a-    a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'
##  a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-      a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-
                                                                                   
