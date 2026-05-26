#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_easyappointments() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_easyappointments

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Easy!Appointments (ex: easyappointments.example.com): \e[0m" && read -r url_easyappointments
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_easyappointments
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do easyappointments
    echo -e "\e[33mDominio do Easy!Appointments:\e[97m $url_easyappointments\e[0m"
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
        nome_easyappointments

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO EASY!APPOINTMENTS \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO MYSQL \e[33m[2/4]\e[0m"
echo ""
sleep 1

dados

## Cria banco de dados do site no mysql
verificar_container_mysql
    if [ $? -eq 0 ]; then
        echo "1/3 - [ OK ] - MySQL ja instalado"
        pegar_senha_mysql > /dev/null 2>&1
        echo "2/3 - [ OK ] - Copiando senha do MySQL"
        criar_banco_mysql_da_stack "easyapointments${1:+_$1}"
        echo "3/3 - [ OK ] - Criando banco de dados"
        echo ""
    else
        ferramenta_mysql
        pegar_senha_mysql > /dev/null 2>&1
        criar_banco_mysql_da_stack "easyapointments${1:+_$1}"
    fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO EASY!APPOINTMENTS \e[33m[3/4]\e[0m"
echo ""
sleep 1


# Cria o arquivo com o conteudo desejado
cat > apache-custom.conf <<__FELSEN_MANAGED_FILE__
ServerName $url_easyappointments
__FELSEN_MANAGED_FILE__
# Cria o diretorio, se ainda nao existir
mkdir -p /root/easyappointments${1:+_$1} > /dev/null 2>&1

# Move o arquivo para o diretorio de destino
sudo mv apache-custom.conf /root/easyappointments${1:+_$1}/apache-custom.conf

## Criando a stack
cat > easyappointments${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  easyapointments${1:+_$1}:
    image: alextselegidis/easyappointments:latest

    volumes:
      - easyapointments${1:+_$1}_data:/var/www/html
      - /root/easyappointments${1:+_$1}/apache-custom.conf:/etc/apache2/conf-enabled/custom.conf:ro

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Dados de acesso
      - BASE_URL=https://$url_easyappointments
      - APACHE_SERVER_NAME=$url_easyappointments

    ## -"i Dados do banco de dados
      - DB_HOST=mysql
      - DB_NAME=easyapointments${1:+_$1}
      - DB_USERNAME=root
      - DB_PASSWORD=$senha_mysql

    ##  Dados Google Calendar
      - GOOGLE_SYNC_FEATURE=false
      - GOOGLE_PRODUCT_NAME=
      - GOOGLE_CLIENT_ID=
      - GOOGLE_CLIENT_SECRET=
      - GOOGLE_API_KEY=

    ##  Modo de Debug
      - DEBUG_MODE=TRUE

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
        - traefik.http.routers.easyapointments${1:+_$1}.rule=Host(\`$url_easyappointments\`)
        - traefik.http.services.easyapointments${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.easyapointments${1:+_$1}.service=easyapointments${1:+_$1}
        - traefik.http.routers.easyapointments${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.easyapointments${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.easyapointments${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  easyapointments${1:+_$1}_data:
    external: true
    name: easyapointments${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Easy!Appointments"
fi
STACK_NAME="easyappointments${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c easyappointments.yaml easyappointments > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do easyappointments"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull alextselegidis/easyappointments:latest

## Usa o servico wait_stack "easyappointments" para verificar se o servico esta online
wait_stack easyappointments${1:+_$1}_easyapointments${1:+_$1}


cd dados_vps

cat > dados_easyappointments${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ EASY!APPOINTMENTS ]

Dominio do Easy!Appointments: https://$url_easyappointments

Usuario: Precisa criar no primeiro acesso do Easy!Appointments

Senha: Precisa criar no primeiro acesso do Easy!Appointments
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
echo -e "\e[32m[ EASY!APPOINTMENTS ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_easyappointments\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no primeiro acesso do Easy!Appointments\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do Easy!Appointments\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## #######  #######  ##########   #######   ################   ########### ####### 
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--
## ##|  ##|##|   ##|##|     ##|   ##|##########|######  ###### ##|##########|   ##|
## a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-  a-a-a-'a-a-a-a--a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'   a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a--a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-
## a-a-a-a-a-a-a-  a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- 

