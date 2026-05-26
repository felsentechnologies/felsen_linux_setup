#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_uptimekuma() {

## Verifica os recursos
recursos 1 1 || return

# Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_uptimekuma

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio do uptime kuma
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Uptime Kuma (ex: uptimekuma.example.com): \e[0m" && read -r url_uptimekuma
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_uptimekuma
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao do Dominio do uptimekuma
    echo -e "\e[33mDominio do Uptime Kuma:\e[97m $url_uptimekuma\e[0m"
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
echo -e "\e[97m- INICIANDO A INSTALACAO DO UPTIME KUMA \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO UPTIME KUMA \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack uptimekuma.yaml
cat > uptimekuma${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  uptimekuma${1:+_$1}:
    image: louislam/uptime-kuma:latest

    volumes:
      - uptimekuma${1:+_$1}:/app/data

    networks:
      - $nome_rede_interna
    
    environment:
    ##  Configuracao de Timezone
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
        - traefik.http.routers.uptimekuma${1:+_$1}.rule=Host(\`$url_uptimekuma\`)
        - traefik.http.routers.uptimekuma${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.uptimekuma${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.uptimekuma${1:+_$1}.loadBalancer.server.port=3001
        - traefik.http.routers.uptimekuma${1:+_$1}.service=uptimekuma${1:+_$1}

## --------------------------- FELSEN --------------------------- ##

volumes:
  uptimekuma${1:+_$1}:
    external: true
    name: uptimekuma${1:+_$1}

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Uptime Kuma"
fi
STACK_NAME="uptimekuma${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c uptimekuma.yaml uptimekuma #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Uptime Kuma"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull louislam/uptime-kuma:latest

## Usa o servico wait_stack "uptimekuma" para verificar se o servico esta online
wait_stack uptimekuma${1:+_$1}_uptimekuma${1:+_$1}


cd dados_vps

read -r ip_vps _ <<< "$(hostname -I)"

cat > dados_uptimekuma${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ UPTIME KUMA ]

Dominio do Uptime Kuma: $url_uptimekuma

Usuario: Precisa criar dentro do Uptime Kuma

Senha: Precisa criar dentro do Uptime Kuma

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
echo -e "\e[32m[ UPTIME KUMA ] \e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_uptimekuma\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar dentro do Uptime Kuma\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar dentro do Uptime Kuma\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ###### ###      ####### ####### ####   ####
## a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'     a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-a-a-- a-a-a-a-a-'
## ##|     #######|##|     ##|     ##|   ##|##########|
## a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-'     a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'a-a-a-a-"a-a-a-a-'
## a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a- a-a-a-'
##  a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-     a-a-a-
                                                    
