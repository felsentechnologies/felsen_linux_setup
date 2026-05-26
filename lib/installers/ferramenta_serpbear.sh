#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_serpbear() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_serpbear

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para o Serpbear (ex: serpbear.example.com): \e[0m" && read -r url_serpbear
    echo ""

    ##Pergunta o usuario
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o usuario para o Serpbear (ex: admin): \e[0m" && read -r user_serpbear
    echo ""
    
    ##Pergunta a senha
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite a senha para o Serpbear (ex: @Senha123_): \e[0m" && read -r pass_serpbear
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_serpbear
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do transcrevezap
    echo -e "\e[33mDominio do Serpbear:\e[97m $url_serpbear\e[0m"
    echo ""

    ## Informacao sobre Usuario do Serpbear
    echo -e "\e[33mUsuario do Serpbear:\e[97m $user_serpbear\e[0m"
    echo ""

    ## Informacao sobre Senha do Serpbear
    echo -e "\e[33mSenha do Serpbear:\e[97m $pass_serpbear\e[0m"
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
        nome_serpbear

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO SERPBEAR \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO SERPBEAR \e[33m[2/1]\e[0m"
echo ""
sleep 1

secret_key_serpbear=$(openssl rand -hex 32)
apikey_serpbear=$(openssl rand -hex 16)

## Criando a stack serpbear.yaml
cat > serpbear${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  serpbear${1:+_$1}:
    image: towfiqi/serpbear:latest

    volumes:
      - serpbear${1:+_$1}_appdata:/app/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      ##  Url do Frontend
      - NEXT_PUBLIC_APP_URL=https://$url_serpbear

      ## " Dados de acesso
      - USER=$user_serpbear
      - PASSWORD=$pass_serpbear

      ##  SecretKey e APIKey
      - SECRET=$secret_key_serpbear
      - APIKEY=$apikey_serpbear

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
        - traefik.http.routers.serpbear${1:+_$1}.rule=Host(\`$url_serpbear\`)
        - traefik.http.services.serpbear${1:+_$1}.loadbalancer.server.port=3000
        - traefik.http.routers.serpbear${1:+_$1}.service=serpbear${1:+_$1}
        - traefik.http.routers.serpbear${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.serpbear${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.serpbear${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  serpbear${1:+_$1}_appdata:
    external: true
    name: serpbear${1:+_$1}_appdata

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Serpbear"
fi

STACK_NAME="serpbear${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c serpbear.yaml serpbear > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do serpbear"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull towfiqi/serpbear:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack serpbear${1:+_$1}_serpbear${1:+_$1}


cd dados_vps

cat > dados_serpbear${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ SERPBEAR ]

Dominio do Serpbear: https://$url_serpbear

Usuario: $user_serpbear

Senha: $pass_serpbear
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
echo -e "\e[32m[ SERPBEAR ]\e[0m"
echo ""

echo -e "\e[33mDominio do Serpbear:\e[97m https://$url_serpbear\e[0m"
echo ""

echo -e "\e[33mUsuario do Serpbear:\e[97m $user_serpbear\e[0m"
echo ""

echo -e "\e[33mSenha do Serpbear:\e[97m $pass_serpbear\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ######  ######################   ################## ########### #######################
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-a-'a-a-a-'        a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-'a-a-a-a-a-a--  a-a-a-'     a-a-a-a-a-a--  a-a-a-a-a-a-a-a--
## a-a-a-"a-a-a-a-a-'a-a-a-'        a-a-a-'   a-a-a-'a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-  a-a-a-"a-a-a-a- a-a-a-'a-a-a-"a-a-a-  a-a-a-'     a-a-a-"a-a-a-  a-a-a-a-a-a-a-a-'
## a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-' a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a--a-a-a-'     a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'
## a-a-a-  a-a-a- a-a-a-a-a-a-a-   a-a-a-   a-a-a-  a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-     a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

