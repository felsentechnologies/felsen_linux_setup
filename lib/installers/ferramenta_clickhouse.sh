#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_clickhouse() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_clickhouse

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o ClickHouse (ex: clickhouse.example.com): \e[0m" && read -r url_clickhouse
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite um nome de usuario para o ClickHouse (ex: admin): \e[0m" && read -r user_clickhouse
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite uma senha para o usuario (ex: @Senha123_): \e[0m" && read -r pass_clickhouse
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_clickhouse
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do clickhouse
    echo -e "\e[33mDominio do ClickHouse:\e[97m $url_clickhouse\e[0m"
    echo ""

    ## Informacao sobre URL do clickhouse
    echo -e "\e[33mUsuario:\e[97m $user_clickhouse\e[0m"
    echo ""

    ## Informacao sobre URL do clickhouse
    echo -e "\e[33mSenha:\e[97m $pass_clickhouse\e[0m"
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
        nome_clickhouse

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO CLICKHOUSE \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO CLICKHOUSE \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack clickhouse.yaml
cat > clickhouse${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  clickhouse${1:+_$1}:
    image: clickhouse/clickhouse-server:23.8.8.20-alpine

    volumes:
      - clickhouse${1:+_$1}_data:/var/lib/clickhouse
      - clickhouse${1:+_$1}_log:/var/log/clickhouse-server

    networks:
      - $nome_rede_interna ## Nome da rede interna
    #ports:
    #  - "8123:8123"
    #  - "9000:9000"
    #  - "9009:9009"

    environment:
    ## -"i Database PadrAo
      - CLICKHOUSE_DB=default

    ## " Credenciais
      - CLICKHOUSE_USER=$user_clickhouse
      - CLICKHOUSE_PASSWORD=$pass_clickhouse

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.clickhouse${1:+_$1}.rule=Host(\`$url_clickhouse\`)
        - traefik.http.services.clickhouse${1:+_$1}.loadbalancer.server.port=8123
        - traefik.http.routers.clickhouse${1:+_$1}.service=clickhouse${1:+_$1}
        - traefik.http.routers.clickhouse${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.clickhouse${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.routers.clickhouse${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.clickhouse${1:+_$1}.tls=true        

## --------------------------- FELSEN --------------------------- ##

volumes:
  clickhouse${1:+_$1}_data:
    external: true
    name: clickhouse${1:+_$1}_data
  clickhouse${1:+_$1}_log:
    external: true
    name: clickhouse${1:+_$1}_log
  
networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do clickhouse"
fi
STACK_NAME="clickhouse${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c clickhouse.yaml clickhouse > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do clickhouse"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull clickhouse/clickhouse-server:23.8.8.20-alpine

## Usa o servico wait_clickhouse para verificar se o servico esta online
wait_stack clickhouse${1:+_$1}_clickhouse${1:+_$1}


cd dados_vps

cat > dados_clickhouse${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ CLICKHOUSE ]

Dashboard do clickhouse: https://$url_clickhouse/dashboard

API do clickhouse: https://$url_clickhouse

Usuario: $user_clickhouse

Senha: $pass_clickhouse

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
echo -e "\e[32m[ CLICKHOUSE ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_clickhouse\e[0m"
echo ""

echo -e "\e[33mDashboard:\e[97m https://$url_clickhouse/dashboard\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_clickhouse\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_clickhouse\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ####### ############### ##################   ############## ####### ###  ############
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a- a-a-a-'  a-a-a-'a-a-a-a-a-a-"a-a-a-
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'a-a-a-'  a-a-a-a--a-a-a-a-a-a-a-a-'   a-a-a-'   
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-'  a-a-a-'a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-'   a-a-a-'   
## a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'   a-a-a-'   
## a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-   a-a-a-   
                                                                                      
