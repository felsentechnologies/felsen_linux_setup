#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_mongodb() {

## Verifica os recursos
recursos 1 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_mongodb

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o nome de usuario
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -e "$amarelo--> Evite os caracteres especiais: @\!#$ e/ou espaco"
    echo -en "\e[33mDigite o nome de usuario (ex: Felsen): \e[0m" && read -r user_mongo
    echo ""
    
    ## Gera a senha aleatoria
    pass_mongo=$(openssl rand -hex 16)
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_mongodb
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao do Usuario
    echo -e "\e[33mUsuario:\e[97m $user_mongo\e[0m"
    echo ""
    
    ## Informacao da Senha gerada
    echo -e "\e[33mSenha gerada:\e[97m $pass_mongo\e[0m"
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
        nome_mongodb

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO MONGO DB \e[33m[1/3]\e[0m"
echo ""
sleep 1


## NADA NADA NADA

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO MONGO DB \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack mongodb.yaml
cat > mongodb${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  mongodb${1:+_$1}:
    image: mongo:latest
    command: mongod --port 27017

    volumes:
      - mongodb${1:+_$1}_data:/data/db
      - mongodb${1:+_$1}_dump:/dump
      - mongodb${1:+_$1}_configdb_data:/data/configdb

    networks:
      - $nome_rede_interna
    #ports:
    #  - 27017:27017

    environment:
    ##  Dados de acesso
      - MONGO_INITDB_ROOT_USERNAME=$user_mongo
      - MONGO_INITDB_ROOT_PASSWORD=$pass_mongo

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: '1'
          memory: 2048M

## --------------------------- FELSEN --------------------------- ##

volumes:
  mongodb${1:+_$1}_data:
    external: true
    name: mongodb${1:+_$1}_data
  mongodb${1:+_$1}_dump:
    external: true
    name: mongodb${1:+_$1}_dump
  mongodb${1:+_$1}_configdb_data:
    external: true
    name: mongodb${1:+_$1}_configdb_data

networks:
  $nome_rede_interna:
    name: $nome_rede_interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do MongoDB"
fi
STACK_NAME="mongodb${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c mongodb.yaml mongodb > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do MongoDB"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull mongo:latest

## Usa o servico wait_stack "mongodb" para verificar se o servico esta online
wait_stack mongodb${1:+_$1}_mongodb${1:+_$1}


cd dados_vps

read -r ip _ <<<$(hostname -I)
ip_vps=$ip

cat > dados_mongodb${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ MONGODB ]

Dominio do MongoDB: MongoDB://$user_mongo:$pass_mongo@$ip_vps:27017/?authSource=admin&readPreference=primary&ssl=false&directConnection=true

Usuario: $user_mongo

Senha: $pass_mongo

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
echo -e "\e[32m[ MONGODB ]\e[0m"
echo ""
echo -e "\e[33mUsuario:\e[97m $user_mongo\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_mongo\e[0m"
echo ""

echo -e "\e[33mUrl Database:\e[97m mongodb://$user_mongo:$pass_mongo@$ip_vps:27017/?authSource=admin&readPreference=primary&ssl=false&directConnection=true\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  ###### ####### ####### ################   #### ####### 
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'   a-a-a-"a-a-a-a-a-"a-a-a-'a-a-a-'   a-a-a-'
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'   a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'a-"a-" a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'   a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a-"a-
## a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-   a-a-a-   a-a-a-     a-a-a- a-a-a-a-EURa-EURa-a- 
                                                                
