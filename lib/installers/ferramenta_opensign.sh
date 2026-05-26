#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_opensign() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados
pegar_senha_mongodb

## Mostra o nome da aplicacao
nome_opensign

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o OpenSign (ex: opensign.example.com): \e[0m" && read -r url_opensign
    echo ""

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_opensign
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL
    echo -e "\e[33mDominio do OpenSign:\e[97m $url_opensign\e[0m"
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
        nome_opensign

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO OPENSIGN \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO OPENSIGN \e[33m[2/3]\e[0m"
echo ""
sleep 1

keymaster_opensign=$(openssl rand -hex 16)
jwtsecret_opensign=$(openssl rand -hex 16)
senha_pfx_opensign=$(openssl rand -hex 16)

KEY_FILE="/tmp/opensign_key.pem"
CERT_FILE="/tmp/opensign_cert.pem"
PFX_FILE="/tmp/opensign.pfx"

openssl req -x509 -newkey rsa:2048 \
  -keyout "$KEY_FILE" \
  -out "$CERT_FILE" \
  -days 3650 \
  -nodes \
  -subj "/C=BR/ST=SP/L=SaoPaulo/O=OpenSign/CN=${url_opensign}" \
  > /dev/null 2>&1

openssl pkcs12 -export \
  -out "$PFX_FILE" \
  -inkey "$KEY_FILE" \
  -in "$CERT_FILE" \
  -passout pass:"$senha_pfx_opensign" \
  > /dev/null 2>&1

PFX_BASE64=$(base64 "$PFX_FILE" | tr -d '\n')

rm -f "$KEY_FILE" "$CERT_FILE" "$PFX_FILE"

## Criando a stack opensign.yaml
cat > opensign${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  opensign${1:+_$1}_server:
    image: opensign/opensignserver:main
    command: ["node", "index.js"]

    networks:
      - $nome_rede_interna ## Nome da rede interna

    volumes:
      - opensign${1:+_$1}_files:/usr/src/app/files

    environment:
    ## Configuracoes da Aplicacao
      - NODE_ENV=production
      - SERVER_URL=https://$url_opensign/app
      - PUBLIC_URL=https://$url_opensign
      - PARSE_MOUNT=/app
      - SERVER_HOST=0.0.0.0
      - PORT=8080

    ## -"i Banco de Dados (MongoDB)
      - MONGODB_URI=mongodb://$user_mongo:$pass_mongo@mongodb:27017/OpenSignDB${1:+_$1}?authSource=admin
      - DATABASE_URI=mongodb://$user_mongo:$pass_mongo@mongodb:27017/OpenSignDB${1:+_$1}?authSource=admin
      - MONGO_URL=mongodb://$user_mongo:$pass_mongo@mongodb:27017/OpenSignDB${1:+_$1}?authSource=admin

    ## " Chaves de SeguranAa
      - MASTER_KEY=$keymaster_opensign
      - JWT_SECRET=$jwtsecret_opensign
      - APP_ID=opensign

    ## " Configuracoes de Armazenamento
      - USE_LOCAL=true

    ##  Configuracoes de SMTP
      - SMTP_ENABLE=false

    ##  Fuso Horario
      - TZ=America/Sao_Paulo

    ##  Certificado PFX para Assinatura Digital
      - PFX_BASE64=$PFX_BASE64
      - PASS_PHRASE=$senha_pfx_opensign

    deploy:
      mode: replicated
      replicas: 1
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.opensign${1:+_$1}_server.rule=Host(\`$url_opensign\`) && PathPrefix(\`/app\`)
        - traefik.http.services.opensign${1:+_$1}_server.loadbalancer.server.port=8080
        - traefik.http.routers.opensign${1:+_$1}_server.service=opensign${1:+_$1}_server
        - traefik.http.routers.opensign${1:+_$1}_server.tls.certresolver=letsencryptresolver
        - traefik.http.routers.opensign${1:+_$1}_server.entrypoints=websecure
        - traefik.http.routers.opensign${1:+_$1}_server.tls=true
        - traefik.http.routers.opensign${1:+_$1}_server.priority=100

## --------------------------- FELSEN --------------------------- ##

  opensign${1:+_$1}_client:
    image: opensign/opensign:main

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## Configuracoes da Aplicacao
      - NODE_ENV=production
      - REACT_APP_SERVERURL=https://$url_opensign/app
      - PUBLIC_URL=https://$url_opensign
      - REACT_APP_APPID=opensign
      - GENERATE_SOURCEMAP=false
    
    ##  Fuso Horario
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
        - traefik.http.routers.opensign${1:+_$1}_client.rule=Host(\`$url_opensign\`) && !PathPrefix(\`/app\`)
        - traefik.http.services.opensign${1:+_$1}_client.loadbalancer.server.port=3000
        - traefik.http.routers.opensign${1:+_$1}_client.service=opensign${1:+_$1}_client
        - traefik.http.routers.opensign${1:+_$1}_client.tls.certresolver=letsencryptresolver
        - traefik.http.routers.opensign${1:+_$1}_client.entrypoints=websecure
        - traefik.http.routers.opensign${1:+_$1}_client.tls=true
        - traefik.http.routers.opensign${1:+_$1}_client.priority=50

## --------------------------- FELSEN --------------------------- ##

volumes:
  opensign${1:+_$1}_files:
    external: true
    name: opensign${1:+_$1}_files

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do opensign"
fi

STACK_NAME="opensign${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c opensign.yaml opensign > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do opensign"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull opensign/opensignserver:main opensign/opensign:main

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack opensign${1:+_$1}_opensign${1:+_$1}_server opensign${1:+_$1}_opensign${1:+_$1}_client


cd dados_vps

cat > dados_opensign${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ OPENSIGN ]

Dominio do opensign: https://$url_opensign
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
echo -e "\e[32m[ OPENSIGN ]\e[0m"
echo ""

echo -e "\e[33mDominio do opensign:\e[97m https://$url_opensign\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa criar no opensign\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no opensign\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  #######  ###########   #### ####### #################
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-- a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-
## ##|  ##|##|   ##|##|     ##########|##|   ##|########   ##|   
## a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'a-a-a-a-"a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'   
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-' a-a-a- a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'   a-a-a-'   
## a-a-a-a-a-a-a-  a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-     a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-   a-a-a-   

