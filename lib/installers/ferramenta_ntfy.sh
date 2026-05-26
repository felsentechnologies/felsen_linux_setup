#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_ntfy() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_ntfy

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para o Ntfy (ex: ntfy.example.com): \e[0m" && read -r url_ntfy
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o Usuario (ex: Felsen): \e[0m" && read -r user_ntfy
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite a Senha (ex: @Senha123_): \e[0m" && read -r pass_ntfy
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_ntfy
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio da Ntfy:\e[97m $url_ntfy\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mUsuario do Ntfy:\e[97m $user_ntfy\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do Ntfy:\e[97m $pass_ntfy\e[0m"
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
        nome_ntfy

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO NTFY \e[33m[1/3]\e[0m"
echo ""
sleep 1

## Literalmente nada, apenas um espaco vazio caso precisar de adicionar alguma coisa
## Antes..
## E claro, para aparecer a mensagem do passo..

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO O NTFY \e[33m[2/3]\e[0m"
echo ""
sleep 1


## Gerando Hash
hashed_senha=$(htpasswd -nb $user_ntfy $pass_ntfy | sed -e s/\\$/\\$\\$/g)

## Gerando Base64
authentication=$(echo -n "$user_ntfy:$pass_ntfy" | base64)

## Criando a stack ntfy.yaml
cat > ntfy${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  ntfy${1:+_$1}:
    image: binwiederhier/ntfy:latest
    command:
      - serve

    volumes:
      - ntfy${1:+_$1}_cache:/var/cache/ntfy
      - ntfy${1:+_$1}_etc:/etc/ntfy

    networks:
      - $nome_rede_interna

    environment:
    ##  TimeZone
      - TZ=America/Sao_Paulo

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
        - traefik.http.routers.ntfy${1:+_$1}.rule=Host(\`$url_ntfy\`)
        - traefik.http.services.ntfy${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.ntfy${1:+_$1}.service=ntfy${1:+_$1}
        - traefik.http.routers.ntfy${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.ntfy${1:+_$1}.entrypoints=websecure
        - traefik.http.middlewares.ntfy${1:+_$1}-auth.basicauth.users=$hashed_senha
        - traefik.http.routers.ntfy${1:+_$1}.middlewares=ntfy${1:+_$1}-auth
        - traefik.http.routers.ntfy${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  ntfy${1:+_$1}_cache:
    external: true
    name: ntfy${1:+_$1}_cache
  ntfy${1:+_$1}_etc:
    external: true
    name: ntfy${1:+_$1}_etc

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack da Ntfy"
fi
STACK_NAME="ntfy${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c ntfy.yaml ntfy > /dev/null 2>&1

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack da Ntfy"
#fi

sleep 10

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull binwiederhier/ntfy:latest

## Usa o servico wait_ntfy para verificar se o servico esta online
wait_stack ntfy${1:+_$1}_ntfy${1:+_$1}


cd dados_vps

cat > dados_ntfy${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ NTFY ]

Link do Ntfy: https://$url_ntfy

Usuario: $user_ntfy

Senha: $pass_ntfy

Authorization: Basic $authentication
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
echo -e "\e[32m[ NTFY ]\e[0m"
echo ""

echo -e "\e[97mLink do Ntfy:\e[33m https://$url_ntfy\e[0m"
echo ""

echo -e "\e[97mUsuario:\e[33m $user_ntfy\e[0m"
echo ""

echo -e "\e[97mSenha:\e[33m $pass_ntfy\e[0m"
echo ""

echo -e "\e[97mAuthorization:\e[33m Basic $authentication\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###      ####### ###    ### ####### ####### ####### ############### 
## a-a-a-'     a-a-a-"a-a-a-a-a-a--a-a-a-'    a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--
## a-a-a-'     a-a-a-'   a-a-a-'a-a-a-' a-a-- a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-
## a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'
## a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-  a-a-a-

