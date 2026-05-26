#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_kafka() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_kafka

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para o Kafka (ex: kafka.example.com): \e[0m" && read -r url_kafka
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o Usuario para o Kafka (ex: admin): \e[0m" && read -r user_ntfy
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite a Senha para o Kafka (ex: @Senha123_): \e[0m" && read -r pass_ntfy
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_kafka
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do Kafka:\e[97m $url_kafka\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mUsuario do Kafka:\e[97m $user_ntfy\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do Kafka:\e[97m $pass_ntfy\e[0m"
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
        nome_kafka

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO KAFKA \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO KAFKA \e[33m[2/3]\e[0m"
echo ""
sleep 1

cluster_kafka=$(openssl rand -base64 16 | tr -d "=+/" | head -c 22)

senha_kafka=$(htpasswd -nb $user_ntfy $pass_ntfy | sed -e s/\\$/\\$\\$/g)

## Criando a stack kafka.yaml
cat > kafka${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  kafka${1:+_$1}_broker:
    image: apache/kafka:latest

    volumes:
      - kafka${1:+_$1}_data:/var/lib/kafka/data
      - kafka${1:+_$1}_logs:/var/log/kafka

    networks:
      - $nome_rede_interna ## Nome da rede interna
    #ports:
    #  - "9092:9092"
    #  - "19092:19092"  # JMX para monitoramento

    environment:
    ## Configuracoes do Kafka
      - KAFKA_BROKER_ID=1
      - KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=PLAINTEXT:PLAINTEXT,CONTROLLER:PLAINTEXT
      - KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka${1:+_$1}_broker:9092
      - KAFKA_PROCESS_ROLES=broker,controller
      - KAFKA_NODE_ID=1
      - KAFKA_CONTROLLER_QUORUM_VOTERS=1@kafka${1:+_$1}_broker:9093
      - KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093
      - KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER
      - KAFKA_LOG_DIRS=/var/lib/kafka/data
      - KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1
      - CLUSTER_ID=$cluster_kafka

    ##  Otimizacoes de Performance
      - KAFKA_NUM_NETWORK_THREADS=8
      - KAFKA_NUM_IO_THREADS=16
      - KAFKA_NUM_REPLICA_FETCHERS=4

    ##  Buffers de Rede
      - KAFKA_SOCKET_SEND_BUFFER_BYTES=102400
      - KAFKA_SOCKET_RECEIVE_BUFFER_BYTES=102400
      - KAFKA_REPLICA_SOCKET_RECEIVE_BUFFER_BYTES=65536

    ##  Logs e Segmentacao
      - KAFKA_LOG_SEGMENT_BYTES=1073741824
      - KAFKA_LOG_RETENTION_HOURS=24
      - KAFKA_LOG_RETENTION_BYTES=1073741824

    ##  Compressao e Batching
      - KAFKA_COMPRESSION_TYPE=lz4
      - KAFKA_BATCH_SIZE=200000
      - KAFKA_LINGER_MS=100

    ##  Particoes e Paralelismo
      - KAFKA_NUM_PARTITIONS=12
      - KAFKA_DEFAULT_REPLICATION_FACTOR=1

    ##  JVM Otimizada
      - KAFKA_HEAP_OPTS=-Xms1G -Xmx1G
      - KAFKA_JVM_PERFORMANCE_OPTS=-server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -XX:MaxInlineLevel=15 -Djava.awt.headless=true

    ##  Monitoramento via JMX
      - KAFKA_JMX_PORT=19092
      - KAFKA_JMX_HOSTNAME=0.0.0.0

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

## --------------------------- FELSEN --------------------------- ##

  kafka${1:+_$1}_ui:
    image: provectuslabs/kafka-ui:latest

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracao do Cluster Kafka
      - KAFKA_CLUSTERS_0_NAME=Felsen Linux Setup
      - KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=kafka${1:+_$1}_broker:9092
      - KAFKA_CLUSTERS_0_JMXPORT=19092
      - KAFKA_CLUSTERS_0_JMXHOST=kafka${1:+_$1}_broker
    
    ## Configuracoes Dinamicas
      - DYNAMIC_CONFIG_ENABLED=true

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
        - traefik.http.routers.kafka${1:+_$1}_ui.rule=Host(\`$url_kafka\`)
        - traefik.http.routers.kafka${1:+_$1}_ui.entrypoints=websecure
        - traefik.http.routers.kafka${1:+_$1}_ui.tls=true
        - traefik.http.routers.kafka${1:+_$1}_ui.tls.certresolver=letsencryptresolver
        - traefik.http.routers.kafka${1:+_$1}_ui.service=kafka${1:+_$1}_ui
        - traefik.http.routers.kafka${1:+_$1}_ui.middlewares=kafka${1:+_$1}_ui_auth
        - traefik.http.services.kafka${1:+_$1}_ui.loadbalancer.server.port=8080
        - traefik.http.middlewares.kafka${1:+_$1}_ui_auth.basicauth.users=$senha_kafka

## --------------------------- FELSEN --------------------------- ##

volumes:
  kafka${1:+_$1}_data:
    external: true
    name: kafka${1:+_$1}_data
  kafka${1:+_$1}_logs:
    external: true
    name: kafka${1:+_$1}_logs

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Kafka"
fi

STACK_NAME="kafka${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c kafka.yaml kafka > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do kafka"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull apache/kafka:latest provectuslabs/kafka-ui:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack kafka${1:+_$1}_kafka${1:+_$1}_broker kafka${1:+_$1}_kafka${1:+_$1}_ui


cd dados_vps

cat > dados_kafka${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ KAFKA ]

Dominio do Kafka: https://$url_kafka
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
echo -e "\e[32m[ KAFKA ]\e[0m"
echo ""

echo -e "\e[33mDominio do kafka:\e[97m https://$url_kafka\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no kafka\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no kafka\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ###### ########################  ######             
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--            
## a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'            
## a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'            
## ##|  ##|#######|   ##|   ##|  ##|##|  ##|            
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a-   a-a-a-   a-a-a-  a-a-a-a-a-a-  a-a-a-            
##                                                                  
##  ####### ###### ####   ###########  ###### ### ####### ####   ###
## a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a- a-a-a-a-a--  a-a-a-'
## a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-'  a-a-a-a--a-a-a-"a-a-a-- a-a-a-'
## a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'
## a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-' a-a-a- a-a-a-'a-a-a-'     a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'
##  a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-     a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-

