#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_quepasa() {

## Verifica os recursos
recursos 2 2 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_quepasa

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o Quepasa (ex: quepasa.example.com): \e[0m" && read -r url_quepasa
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_quepasa
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do quepasa
    echo -e "\e[33mDominio do Quepasa:\e[97m $url_quepasa\e[0m"
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
        nome_minio

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO QUEPASA \e[33m[1/3]\e[0m"
echo ""
sleep 1


## NADA


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES\e[33m[2/5]\e[0m"
echo ""
sleep 1

## Verifica se tem postgres, se sim pega a senha e cria um banco nele, se nao instala, pega a senha e cria o banco
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "quepasa${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "quepasa${1:+_$1}"
fi


## Mensagem de Passo
echo -e "\e[97m- INSTALANDO QUEPASA \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack

key_quepasa=$(openssl rand -hex 16)
masterkey_quepasa=$(openssl rand -hex 16)

## Criando a stack quepasa.yaml
cat > quepasa${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  quepasa${1:+_$1}:
    image: codeleaks/quepasa:latest ## Imagem/versao do Quepasa
      
    volumes:
      - quepasa${1:+_$1}_volume:/opt/quepasa

    networks:
      - $nome_rede_interna

    environment:
    ##  Configuracoes do Quepasa
      - DOMAIN=$url_quepasa  # Usado pelo Traefik (labels)
      - MASTERKEY=$masterkey_quepasa
      - WEBSERVER_PORT=31000

    ## " Ativar/Desativar conta de setup
      - ACCOUNTSETUP=true ## Apos criar a conta, desative para nao permitir novos acessos.

    ##  Titulo no celular
      - APP_TITLE=Felsen ## Mude aqui o nome que vai aparecer no celular.

    ##  TimeZone (opcional, mas util para logs)
      - TZ=America/Sao_Paulo

    ## -"i Banco de dados
      - DBDRIVER=postgres
      - DBHOST=postgres
      - DBDATABASE=quepasa${1:+_$1}
      - DBPORT=5432
      - DBUSER=postgres
      - DBPASSWORD=$senha_postgres
      - DBSSLMODE=disable

    ##  Configuracoes para o WhatsApp
      - GROUPS=true
      - BROADCASTS=false
      - READRECEIPTS=forcedfalse
      - CALLS=true
      - READUPDATE=false

    ## " Configuracoes quepasa
      - WEBSOCKETSSL=true
      - REMOVEDIGIT9=true
      - SIGNING_SECRET=$masterkey_quepasa

    ##  Logging
      - LOGLEVEL=DEBUG
      - WHATSMEOW_LOGLEVEL=WARN
      - WHATSMEOW_DBLOGLEVEL=WARN
      - HTTPLOGS=false

    ##  Configuracoes gerais
      - SYNOPSISLENGTH=500
      - MIGRATIONS=/builder/migrations

    deploy:
      mode: replicated
      replicas: 1
      placement:
          constraints:
          - node.role == manager
      resources:
          limits:
              cpus: "2"
              memory: 2096M
      labels:
        - traefik.enable=true
        - traefik.http.routers.quepasa${1:+_$1}.rule=Host(\`$url_quepasa\`)
        - traefik.http.routers.quepasa${1:+_$1}.tls=true
        - traefik.http.routers.quepasa${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.quepasa${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.quepasa${1:+_$1}.service=quepasa${1:+_$1}
        - traefik.http.routers.quepasa${1:+_$1}.priority=1      
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.SSLRedirect=true
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.STSSeconds=315360000
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.browserXSSFilter=true
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.contentTypeNosniff=true
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.forceSTSHeader=true
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.SSLHost=$url_quepasa
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.STSIncludeSubdomains=true
        - traefik.http.middlewares.quepasa${1:+_$1}.headers.STSPreload=true
        - traefik.http.services.quepasa${1:+_$1}.loadbalancer.server.port=31000
        - traefik.http.services.quepasa${1:+_$1}.loadbalancer.passHostHeader=true              

## --------------------------- FELSEN --------------------------- ##

volumes:
  quepasa${1:+_$1}_volume:
    external: true
    name: quepasa${1:+_$1}_volume

networks:
  $nome_rede_interna:
    external: true
    name: $nome_rede_interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Quepasa"
fi
STACK_NAME="quepasa${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c quepasa.yaml quepasa > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Quepasa"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull deividms/quepasa:latest

## Usa o servico wait_quepasa para verificar se o servico esta online
wait_stack quepasa${1:+_$1}_quepasa${1:+_$1}


cd dados_vps

cat > dados_quepasa${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ QUEPASA ]

Dominio do Quepasa: https://$url_quepasa

Email: $email_quepasa

Usuario: Precisa de criar ao entrar no /setup

Senha: Precisa de criar ao entrar no /setup
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
echo -e "\e[32m[ QUEPASA ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_quepasa\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa de criar ao entrar no setup\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar ao entrar no setup\e[0m"
echo ""

echo -e "\e[97mObservacao:\e[33m Depois que criar sua conta no /setup, digite \e[97mquepasa.setup.off \e[0m"
echo -e "\e[33mpara desativar o /setup do quepasa.\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  #######  ##########   ################### ###### ###     
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'     
## ##|  ##|##|   ##|##|     ##|   ##|##############  #######|##|     
## a-a-a-'  a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a-'a-a-a-'     
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-a-a-a-a-  a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-
                                                                  
