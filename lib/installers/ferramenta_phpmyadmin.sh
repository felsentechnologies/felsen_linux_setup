#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_phpmyadmin() {

## Verifica os recursos
recursos 1 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_phpmyadmin

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o PhpMyAdmin (ex: phpmyadmin.example.com): \e[0m" && read -r url_phpmyadmin
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -en "\e[33mDigite o Host MySQL (ex: mysql ou 1.111.111.11:3306): \e[0m" && read -r host_phpmyadmin
    echo ""
    if [[ "$host_phpmyadmin" == *:* ]]; then
      PORTA_MYSQL_PMA=$(echo "$host_phpmyadmin" | cut -d':' -f2)
      HOST_MYSQL_PMA=$(echo "$host_phpmyadmin" | cut -d':' -f1)
    else
      PORTA_MYSQL_PMA=3306
      HOST_MYSQL_PMA=$host_phpmyadmin
    fi

    ##Pergunta o Dominio para a ferramenta
    #echo -e "\e[97mPasso$amarelo 4/4\e[0m"
    #echo -en "\e[33mDigite o Usuario MySQL  (ex: Felsen): \e[0m" && read -r user_phpmyadmin
    #echo ""

    ##Pergunta o Dominio para a ferramenta
    #echo -e "\e[97mPasso$amarelo 4/4\e[0m"
    #echo -e "$amarelo--> Sem caracteres especiais: \!#$"
    #echo -en "\e[33mDigite a Senha MySQL (ex: @Senha123_): \e[0m" && read -r pass_phpmyadmin
    #echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_phpmyadmin
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ##Informacao do Dominio
    echo -e "\e[33mDominio para o PhpMyAdmin:\e[97m $url_phpmyadmin\e[0m"
    echo ""

    ##Informacao do Dominio
    echo -e "\e[33mHost MySQL:\e[97m $host_phpmyadmin\e[0m"
    echo ""

    ###Informacao do Dominio
    #echo -e "\e[33mUsuario MySQL:\e[97m $user_phpmyadmin\e[0m"
    #echo ""

    ###Informacao do Dominio
    #echo -e "\e[33mSenha MYSQL:\e[97m $pass_phpmyadmin\e[0m"
    #echo ""
    
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
        nome_phpmyadmin

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO PHPMYADMIN \e[33m[1/3]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO PHPMYADMIN \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack phpmyadmin.yaml
cat > phpmyadmin${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  phpmyadmin${1:+_$1}:
    image: phpmyadmin/phpmyadmin:latest
    command: ["apache2-foreground"]

    networks:
      - $nome_rede_interna

    environment:
    ##  Dados do MySQL
      - PMA_HOSTS=$HOST_MYSQL_PMA
      - PMA_PORT=$PORTA_MYSQL_PMA
      
    ## " Dado de acesso
      #- PMA_USER=
      #- PMA_PASSWORD=
      - PMA_ABSOLUTE_URI=https://$url_phpmyadmin
      
    ##  Limite de Upload
      - UPLOAD_LIMIT=10M

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 2048M
      labels:
        - traefik.enable=true
        - traefik.http.routers.phpmyadmin${1:+_$1}.rule=Host(\`$url_phpmyadmin\`)
        - traefik.http.routers.phpmyadmin${1:+_$1}.entrypoints=web,websecure
        - traefik.http.routers.phpmyadmin${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.phpmyadmin${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.phpmyadmin${1:+_$1}.service=phpmyadmin${1:+_$1}

## --------------------------- FELSEN --------------------------- ##

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do phpmyadmin"
fi
STACK_NAME="phpmyadmin${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c phpmyadmin.yaml phpmyadmin #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do phpmyadmin"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull phpmyadmin/phpmyadmin:latest

## Usa o servico wait_stack "phpmyadmin" para verificar se o servico esta online
wait_stack phpmyadmin${1:+_$1}_phpmyadmin${1:+_$1}


cd
cd dados_vps

cat > dados_phpmyadmin${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ PHPMYADMIN ]

Dominio do phpmyadmin: https://$url_phpmyadmin

Usuario: Os mesmos do seu MySQL

Senha: Os mesmos do seu MySQL
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
echo -e "\e[32m[ PHPMYADMIN ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_phpmyadmin\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Os mesmos do seu MySQL\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Os mesmos do seu MySQL\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########   ##########  ###### #######  ###### ################
## a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a--  
## a-a-a-a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  
## a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-'     a-a-a-'  a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-
                                                                 
