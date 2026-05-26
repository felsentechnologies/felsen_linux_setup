#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_rabbitmq() {

## Verifica os recursos
recursos 1 1 && continue || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_rabbitmq

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio do RabbitMq
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o RabbitMQ (ex: rabbitmq.example.com): \e[0m" && read -r url_rabbitmq
    echo ""
    
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -e "$amarelo--> Evite os caracteres especiais: @\!#$ e/ou espaco"
    echo -en "\e[33mDigite o nome de usuario (ex: Felsen): \e[0m" && read -r user_rabbitmq
    echo ""
    
    ## Gera a senha aleatoria
    pass_rabbitmq=$(openssl rand -hex 16)
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_rabbitmq
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao do Dominio do RabbitMQ
    echo -e "\e[33mDominio do RabbitMQ:\e[97m $url_rabbitmq\e[0m"
    echo ""
    
    ## Informacao do Usuario do RabbitMQ
    echo -e "\e[33mUsario:\e[97m $user_rabbitmq\e[0m"
    echo ""
    
    ## Informacao da Senha do RabbitMQ
    echo -e "\e[33mSenha:\e[97m $pass_rabbitmq\e[0m"
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
        nome_rabbitmq

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done
## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO RABBITMQ \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO RABBITMQ \e[33m[2/3]\e[0m"
echo ""
sleep 1

#Key aleatoria cookie
key_cookie=$(openssl rand -hex 16)

## Criando a stack rabbitmq.yaml
cat > rabbitmq${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  rabbitmq${1:+_$1}:
    image: rabbitmq:management
    command: rabbitmq-server

    hostname: rabbitmq

    volumes:
      - rabbitmq${1:+_$1}_data:/var/lib/rabbitmq

    networks:
      - $nome_rede_interna
    #ports:
    #  - 5672:5672
    #  - 15672:15672

    environment:
    ##  Dados de acesso
      RABBITMQ_DEFAULT_USER: $user_rabbitmq
      RABBITMQ_DEFAULT_PASS: $pass_rabbitmq

    ## " Key para os Cookies
      RABBITMQ_ERLANG_COOKIE: $key_cookie
      
    ##  VHost padrao
      RABBITMQ_DEFAULT_VHOST: "/"

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
        - traefik.http.routers.rabbitmq${1:+_$1}.rule=Host(\`$url_rabbitmq\`)
        - traefik.http.routers.rabbitmq${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.rabbitmq${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.rabbitmq${1:+_$1}.service=rabbitmq${1:+_$1}
        - traefik.http.services.rabbitmq${1:+_$1}.loadbalancer.server.port=15672

## --------------------------- FELSEN --------------------------- ##

volumes:
  rabbitmq${1:+_$1}_data:
    external: true

networks:
  $nome_rede_interna:
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do RabbitMQ"
fi
STACK_NAME="rabbitmq${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c rabbitmq.yaml rabbitmq > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do RabbitMQ"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull rabbitmq:management

## Usa o servico wait_stack "pgadmin_4" para verificar se o servico esta online
wait_stack rabbitmq${1:+_$1}_rabbitmq${1:+_$1}


cd dados_vps

read -r ip_vps _ <<< "$(hostname -I)"

cat > dados_rabbitmq${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ RABBITMQ ]

Dominio do RabbitMq: $url_rabbitmq

Usuario: $user_rabbitmq

Senha: $pass_rabbitmq

URL: amqp://$user_rabbitmq:$pass_rabbitmq@rabbitmq:5672
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
echo -e "\e[32m[ RABBITMQ ]\e[0m"
echo ""
echo -e "\e[33mDominio:\e[97m https://$url_rabbitmq\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_rabbitmq\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_rabbitmq\e[0m"
echo ""

echo -e "\e[33mURL:\e[97m amqp://$user_rabbitmq:$pass_rabbitmq@rabbitmq:5672\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###   ########## ################   ############    ###  ######   #######   #### ###### 
## a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-    a-a-a-' a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a--
## a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a--      a-a-a-a-a-a-"a- a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-    a-a-a-'   a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-      a-a-a-"a-a-a-a-- a-a-a-'   a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-"a-a-a-a-a-'
## a-a-a-a-a-a-a-a-"a-a-a-a-'        a-a-a-'   a-a-a-'a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a--    a-a-a-'  a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'a-a-a-'  a-a-a-'
##  a-a-a-a-a-a-a- a-a-a-        a-a-a-   a-a-a-a-a-a-     a-a-a-a-a-a-a-a-a-a-a-    a-a-a-  a-a-a- a-a-a-a-a-a-a- a-a-a-     a-a-a-a-a-a-  a-a-a-
                                                                                        
