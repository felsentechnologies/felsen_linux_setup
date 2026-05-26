#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_rustdesk() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_rustdesk

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o HBBS do Rustdesk (ex: hbbs-rustdesk.example.com): \e[0m" && read -r url_hbbs
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -en "\e[33mDigite o dominio para o HBBR do Rustdesk (ex: hbbr-rustdesk.example.com): \e[0m" && read -r url_hbbr
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_rustdesk
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do rustdesk
    echo -e "\e[33mDominio do Servidor de ID do RustDesk:\e[97m $url_hbbs\e[0m"
    echo ""

    ## Informacao sobre URL do rustdesk
    echo -e "\e[33mDominio do Servidor de Relay RustDesk:\e[97m $url_hbbr\e[0m"
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
        nome_rustdesk

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO RUSTDESK \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Gerando a chave do RustDesk
rustdesk_api_key=$(openssl rand -hex 16)

generate_rustdesk_string() {
    local link_hbbs="$1"
    local link_hbbr="$2"
    local key="$3"
    
    # Criar o JSON com formatacao especifica
    local json="{\"host\":\"$link_hbbs\",\"relay\":\"$link_hbbr\",\"api\":\"\",\"key\":\"$key\"}"
    
    # Converter para base64 e inverter
    echo -n "$json" | base64 -w 0 | rev
}

link_hbbs="$url_hbbs"
link_hbbr="$url_hbbr"
key="$rustdesk_api_key"

rustdesk_string=$(generate_rustdesk_string "$url_hbbs" "$url_hbbr" "$key")

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO RUSTDESK \e[33m[2/3]\e[0m"
echo ""
sleep 1


## Criando a stack rustdesk.yaml
cat > rustdesk${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.8"
services:

## --------------------------- FELSEN --------------------------- ##

  rustdesk${1:+_$1}_hbbs:
    image: rustdesk/rustdesk-server:latest
    command: hbbs

    volumes:
      - rustdesk${1:+_$1}_data:/root
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    ports:
      - 21115:21115
      - 21116:21116
      - 21116:21116/udp
      - 21118:21118  
    
    environment:
      - ALWAYS_USE_RELAY=N
      - RELAY=$url_hbbr
    
    ## AAoA...AAa'AA'A SeguranA'A'Aa
      - KEY=$rustdesk_api_key
    
    ##  Logs
      - RUST_LOG=info

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.rustdesk${1:+_$1}_hbbs.rule=Host(\`$url_hbbs\`) ## Dominio para aplicacao
        - traefik.http.routers.rustdesk${1:+_$1}_hbbs.entrypoints=websecure
        - traefik.http.routers.rustdesk${1:+_$1}_hbbs.priority=1
        - traefik.http.routers.rustdesk${1:+_$1}_hbbs.tls.certresolver=letsencryptresolver
        - traefik.http.routers.rustdesk${1:+_$1}_hbbs.service=rustdesk${1:+_$1}_hbbs
        - traefik.http.services.rustdesk${1:+_$1}_hbbs.loadbalancer.server.port=21116
        - traefik.http.services.rustdesk${1:+_$1}_hbbs.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  rustdesk${1:+_$1}_hbbr:
    image: rustdesk/rustdesk-server:latest
    command: hbbr

    volumes:
      - rustdesk${1:+_$1}_data:/root
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    ports:
      - 21117:21117
      - 21119:21119      

    environment:
    ## AAoA...AAa'AA'A SeguranA'A'Aa
      - KEY=$rustdesk_api_key
    
    ##  Performance e Banda
      - LIMIT_SPEED=200
      - SINGLE_BANDWIDTH=50
      - TOTAL_BANDWIDTH=500
    
    ##  Logs
      - RUST_LOG=info

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=1
        - traefik.http.routers.rustdesk${1:+_$1}_hbbr.rule=Host(\`$url_hbbr\`) ## Dominio para aplicacao
        - traefik.http.routers.rustdesk${1:+_$1}_hbbr.entrypoints=websecure
        - traefik.http.routers.rustdesk${1:+_$1}_hbbr.priority=1
        - traefik.http.routers.rustdesk${1:+_$1}_hbbr.tls.certresolver=letsencryptresolver
        - traefik.http.routers.rustdesk${1:+_$1}_hbbr.service=rustdesk${1:+_$1}_hbbr
        - traefik.http.services.rustdesk${1:+_$1}_hbbr.loadbalancer.server.port=21117
        - traefik.http.services.rustdesk${1:+_$1}_hbbr.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  rustdesk${1:+_$1}_data:
    external: true
    name: rustdesk${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do rustdesk"
fi
STACK_NAME="rustdesk${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c rustdesk.yaml rustdesk > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do rustdesk"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull rustdesk/rustdesk-server:latest

## Usa o servico wait_rustdesk para verificar se o servico esta online
wait_stack rustdesk${1:+_$1}_rustdesk${1:+_$1}_hbbs rustdesk${1:+_$1}_rustdesk${1:+_$1}_hbbr


cd dados_vps

cat > dados_rustdesk${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ RUSTDESK ]

Dominio do Servidor de ID do RustDesk:$url_hbbs

Dominio do Servidor de Relay do RustDesk:$url_hbbr

Dominio do Servidor da API do RustDesk: VAZIO

ApiKey do RustDesk: $rustdesk_api_key

Configuracoes do Servidor Rundesk: $rustdesk_string
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
echo -e "\e[32m[ RUSTDESK ]\e[0m"
echo ""

echo -e "\e[33mDominio do Servidor de ID do RustDesk:\e[97m $url_hbbs\e[0m"
echo ""

echo -e "\e[33mDominio do Servidor de Relay do RustDesk:\e[97m $url_hbbr\e[0m"
echo ""

echo -e "\e[33mDominio do Servidor da API do RustDesk:\e[97m VAZIO\e[0m"
echo ""

echo -e "\e[33mKey do RustDesk:\e[97m $rustdesk_api_key\e[0m"
echo ""

echo -e "\e[33mConfiguracoes do Servidor Rundesk:\e[97m $rustdesk_string\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}
