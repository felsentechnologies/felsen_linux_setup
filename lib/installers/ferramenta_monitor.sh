#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_monitor() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_monitor

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/4\e[0m"
    echo -en "\e[33mDigite o Dominio para o Grafana (ex: grafana.example.com): \e[0m" && read -r url_grafana
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 2/4\e[0m"
    echo -en "\e[33mDigite o Dominio para o Prometheus (ex: prometheus.example.com): \e[0m" && read -r url_prometheus
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 3/4\e[0m"
    echo -en "\e[33mDigite o Dominio para o cAdvisor (ex: cadvisor.example.com): \e[0m" && read -r url_cadvisor
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 4/4\e[0m"
    echo -en "\e[33mDigite o Dominio para o NodeExporter (ex: node.example.com): \e[0m" && read -r url_nodeexporter
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_monitor
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do Grafana:\e[97m $url_grafana\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mDominio do Prometheus:\e[97m $url_prometheus\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mDominio do Cadvisor:\e[97m $url_cadvisor\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mDominio do NodeExporter:\e[97m $url_nodeexporter\e[0m"
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
        nome_monitor

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO GRAFANA + PROMETHEUS + CADVISOR \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Literalmente nada, apenas um espaco vazio caso precisar de adicionar alguma coisa antes..
## E claro, para aparecer a mensagem do passo..

## Mensagem de Passo
echo -e "\e[97m- BAIXANDO RECURSOS \e[33m[2/4]\e[0m"
echo ""
sleep 1

mkdir blablabla
cd blablabla

git clone https://github.com/felsen-labs/linux-setup.git > /dev/null 2>&1

if [ -d "/opt/monitor-FELSEN" ]; then
  sudo rm -r /opt/monitor-FELSEN
fi
sudo mv /root/blablabla/Felsen Linux Setup/Extras/Grafana/monitor-FELSEN /opt

cd

rm -r blablabla

cd

cd

## Criando arquivo datasource
cat > datasource.yml <<__FELSEN_MANAGED_FILE__
apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  url: https://$url_prometheus
  isDefault: true
  access: proxy
  editable: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/4 - [ OK ] - Criando datasource.yml"
else
    echo "1/4 - [ OFF ] - Criando datasource.ym"
    echo "Nao foi possivel criar o datasource"
fi


cp /root/datasource.yml /opt/monitor-FELSEN/grafana/
if [ $? -eq 0 ]; then
    echo "2/6 - [ OK ] - Movendo datasource.yml para o diretorio /opt/monitor-FELSEN/grafana/"
else
    echo "2/6 - [ OFF ] - Movendo datasource.yml para o diretorio /opt/monitor-FELSEN/grafana/"
    echo "Nao foi possivel copiar o datasource para o diretorio opt"
fi

cp /root/datasource.yml /opt/monitor-FELSEN/grafana/provisioning/datasources/
if [ $? -eq 0 ]; then
    echo "3/6 - [ OK ] - Movendo datasource.yml para o diretorio /opt/monitor-FELSEN/grafana/provisioning/datasources/"
else
    echo "3/6 - [ OFF ] - Movendo datasource.yml para o diretorio /opt/monitor-FELSEN/grafana/provisioning/datasources/"
    echo "Nao foi possivel copiar o datasource para o diretorio opt"
fi

rm /root/datasource.yml
if [ $? -eq 0 ]; then
    echo "4/6 - [ OK ] - Removendo datasource.yml do /root/"
else
    echo "4/6 - [ OFF ] - Removendo datasource.yml do /root/"
    echo "Nao foi possivel deletar o datasource para o diretorio opt"
fi

cd

## Criando arquivo prometheus yml
cat > prometheus.yml <<__FELSEN_MANAGED_FILE__
global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s
alerting:
  alertmanagers:
  - static_configs:
    - targets: []
    scheme: http
    timeout: 10s
    api_version: v2
scrape_configs:
- job_name: prometheus
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets: ['$url_prometheus','$url_cadvisor','$url_nodeexporter']

__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "5/6 - [ OK ] - Criando arquivo prometheus.yml"
else
    echo "5/6 - [ OFF ] - Criando arquivo prometheus.yml"
    echo "Nao foi possivel criar o prometheus"
fi

mv /root/prometheus.yml /opt/monitor-FELSEN/prometheus/
if [ $? -eq 0 ]; then
    echo "6/6 - [ OK ] - Movendo arquivo prometheus.yml para /opt/monitor-FELSEN/prometheus/"
else
    echo "6/6 - [ OFF ] - Movendo arquivo prometheus.yml para /opt/monitor-FELSEN/prometheus/"
    echo "Nao foi possivel copiar o datasource para o diretorio opt"
fi

cd
cd
echo ""

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO GRAFANA + PROMETHEUS + CADVISOR \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Aqui de fato vamos iniciar a instalacao das ferramentas

## Criando a stack monitor.yaml ou grafana.yaml
cat > monitor.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  prometheus:
    image: prom/prometheus:latest

    volumes:
      - /opt/monitor-FELSEN/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml

    networks:
      - $nome_rede_interna

    ports:
      - "9191:9090"

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager    
      labels:
        - traefik.enable=true
        - traefik.docker.network=$nome_rede_interna
        - traefik.http.routers.prometheus.rule=Host(\`$url_prometheus\`) ## Dominio para aplicacao
        - traefik.http.routers.prometheus.entrypoints=websecure
        - traefik.http.routers.prometheus.priority=1
        - traefik.http.routers.prometheus.tls.certresolver=letsencryptresolver
        - traefik.http.routers.prometheus.service=prometheus
        - traefik.http.services.prometheus.loadbalancer.server.port=9090

## --------------------------- FELSEN --------------------------- ##

  grafana:
    image: grafana/grafana:latest

    volumes:
      - /opt/monitor-FELSEN/grafana/grafana.ini:/etc/grafana/grafana.ini
      - /opt/monitor-FELSEN/grafana/provisioning/datasources:/etc/grafana/provisioning/datasources
      - /opt/monitor-FELSEN/grafana/provisioning/dashboards:/etc/grafana/provisioning/dashboards
      - /opt/monitor-FELSEN/grafana/dashboards:/etc/grafana/dashboards

    networks:
      - $nome_rede_interna

    ports:
      - "3111:3000"

    links:
      - prometheus
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.docker.network=$nome_rede_interna
        - traefik.http.routers.grafana.rule=Host(\`$url_grafana\`) ## Dominio para aplicacao
        - traefik.http.routers.grafana.entrypoints=websecure
        - traefik.http.routers.grafana.priority=1
        - traefik.http.routers.grafana.tls.certresolver=letsencryptresolver
        - traefik.http.routers.grafana.service=grafana
        - traefik.http.services.grafana.loadbalancer.server.port=3000

## --------------------------- FELSEN --------------------------- ##

  node-exporter:
    image: prom/node-exporter:latest
    restart: unless-stopped

    networks:
      - $nome_rede_interna

    ports:
      - "9100:9100"

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.docker.network=$nome_rede_interna
        - traefik.http.routers.node-exporter.rule=Host(\`$url_nodeexporter\`) ## Dominio para aplicacao
        - traefik.http.routers.node-exporter.entrypoints=websecure
        - traefik.http.routers.node-exporter.priority=1
        - traefik.http.routers.node-exporter.tls.certresolver=letsencryptresolver
        - traefik.http.routers.node-exporter.service=node-exporter
        - traefik.http.services.node-exporter.loadbalancer.server.port=9100

## --------------------------- FELSEN --------------------------- ##

  cadvisor:
    image: gcr.io/cadvisor/cadvisor
    restart: unless-stopped

    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:rw
      - /sys:/sys:ro
      - /sys/fs/cgroup:/sys/fs/cgroup
      - /var/lib/docker/:/var/lib/docker:ro

    networks:
      - $nome_rede_interna

    ports:
      - "8181:8080"

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager     
      labels:
        - traefik.enable=true
        - traefik.docker.network=$nome_rede_interna
        - traefik.http.routers.cadvisor.rule=Host(\`$url_cadvisor\`) ## Dominio para aplicacao
        - traefik.http.routers.cadvisor.entrypoints=websecure
        - traefik.http.routers.cadvisor.priority=1
        - traefik.http.routers.cadvisor.tls.certresolver=letsencryptresolver
        - traefik.http.routers.cadvisor.service=cadvisor
        - traefik.http.services.cadvisor.loadbalancer.server.port=8080

## --------------------------- FELSEN --------------------------- ##

networks:
  $nome_rede_interna:
    name: $nome_rede_interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Monitor"
fi
STACK_NAME="monitor"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c monitor.yaml monitor > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Monitor"
#fi

echo ""
sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull prom/prometheus:latest grafana/grafana:latest prom/node-exporter:latest gcr.io/cadvisor/cadvisor

## Usa o servico wait_monitor para verificar se o servico esta online
wait_stack monitor_prometheus monitor_grafana monitor_node-exporter monitor_cadvisor


cd dados_vps

cat > dados_monitor <<__FELSEN_MANAGED_FILE__
[ MONITOR ]

Dominio Grafana: https://$url_grafana

Dominio Prometheus: https://$url_prometheus

Dominio cAdvisor: https://$url_cadvisor

Dominio NodeExporter: https://$url_nodeexporter

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
echo -e "\e[32m[ GRAFANA + PROMETHEUS + CADVISOR ]\e[0m"
echo ""

echo -e "\e[97mDominio Grafana:\e[33m https://$url_grafana\e[0m"
echo ""

echo -e "\e[97mUsuario Grafana:\e[33m admin\e[0m"
echo ""

echo -e "\e[97mSenha Grafana:\e[33m admin\e[0m"
echo -e "\e[97mDepois do primeiro login, sera solicitado que voce altere a senha.\e[0m"
echo ""

echo -e "\e[97mDominio Prometheus:\e[33m https://$url_prometheus\e[0m"
echo ""

echo -e "\e[97mDominio cAdvisor:\e[33m https://$url_cadvisor\e[0m"
echo ""

echo -e "\e[97mDominio NodeExporter:\e[33m https://$url_nodeexporter\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####### ##############   ### ###### ###
## a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a--a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a--   a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-'a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-'a-a-a-"a-a-a-    a-a-a-a-"a-  a-a-a-"a-a-a-a-a-'a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-'        a-a-a-'a-a-a--a-a-a-'  a-a-a-'a-a-a-'
## a-a-a-a-a-a-a- a-a-a-a-a-a-        a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-

