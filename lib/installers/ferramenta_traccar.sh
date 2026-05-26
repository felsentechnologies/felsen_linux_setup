#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_traccar() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_traccar

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Traccar (ex: traccar.example.com): \e[0m" && read -r url_traccar
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_traccar
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do traccar
    echo -e "\e[33mDominio do Traccar:\e[97m $url_traccar\e[0m"
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
        nome_traccar

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO TRACCAR \e[33m[1/3]\e[0m"
echo ""
sleep 1


cd
cd

gerar_senha_mysql=$(openssl rand -hex 16)

mkdir -p /opt/traccar${1:+_$1}/logs

cat > traccar.xml <<__FELSEN_MANAGED_FILE__
<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
    <entry key="database.driver">com.mysql.cj.jdbc.Driver</entry>
    <entry key="database.url">jdbc:mysql://traccar${1:+_$1}_db:3306/traccar?allowPublicKeyRetrieval=true&amp;useSSL=false</entry>
    <entry key="database.user">traccar</entry>
    <entry key="database.password">$gerar_senha_mysql</entry>
    <entry key="web.port">8082</entry>
</properties>
__FELSEN_MANAGED_FILE__
mv traccar.xml /opt/traccar${1:+_$1}/

cd
cd

## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO TRACCAR \e[33m[2/3]\e[0m"
echo ""
sleep 1



## Criando a stack traccar.yaml
cat > traccar${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  traccar${1:+_$1}:
    image: traccar/traccar:latest
    
    volumes:
      - /opt/traccar${1:+_$1}/logs:/opt/traccar${1:+_$1}/logs:rw
      - /opt/traccar${1:+_$1}/traccar.xml:/opt/traccar${1:+_$1}/conf/traccar.xml:ro
      - traccar${1:+_$1}_data:/opt/traccar/

    networks:
     - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Java Options
      - JAVA_OPTS=-Xms1g -Xmx1g -Djava.net.preferIPv4Stack=true
    
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
        - traefik.http.routers.traccar${1:+_$1}.rule=Host(\`$url_traccar\`)
        - traefik.http.services.traccar${1:+_$1}.loadbalancer.server.port=8082
        - traefik.http.routers.traccar${1:+_$1}.service=traccar${1:+_$1}
        - traefik.http.routers.traccar${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.traccar${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.traccar${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

  traccar${1:+_$1}_db:
    image: mysql:8.0

    volumes:
      - traccar${1:+_$1}_db:/var/lib/mysql

    networks:
     - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Credenciais
      - MYSQL_ROOT_PASSWORD=rootpassword
      - MYSQL_DATABASE=traccar
      - MYSQL_USER=traccar
      - MYSQL_PASSWORD=$gerar_senha_mysql

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

volumes:
  traccar${1:+_$1}_data:
    external: true
    name: traccar${1:+_$1}_data
  traccar${1:+_$1}_db:
    external: true
    name: traccar${1:+_$1}_db
    
networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do traccar"
fi
STACK_NAME="traccar${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c traccar.yaml traccar > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do traccar"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull traccar/traccar:latest mysql:8.0

## Usa o servico wait_traccar para verificar se o servico esta online
wait_stack traccar${1:+_$1}_traccar${1:+_$1} traccar${1:+_$1}_traccar${1:+_$1}_db


cd dados_vps

cat > dados_traccar${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ TRACCAR ]

Dominio do Traccar: https://$url_traccar

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
echo -e "\e[32m[ TRACCAR ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_traccar\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa de criar no primeiro acesso do traccar\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar no primeiro acesso do traccar\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ################## ######## ##############  ###### ###    ######     
## a-a-a-"a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'    a-a-a-'a-a-a-'     
## a-a-a-a-a-a--  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-'     a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-' a-a-- a-a-a-'a-a-a-'     
## a-a-a-"a-a-a-  a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-'     a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'     
## a-a-a-'     a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a--
## a-a-a-     a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-
                                                                                      
