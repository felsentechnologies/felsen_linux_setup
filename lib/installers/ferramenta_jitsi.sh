#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_jitsi() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_jitsi

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/4\e[0m"
    echo -en "\e[33mDigite o Dominio para o Jitsi (ex: jitsi.example.com): \e[0m" && read -r url_jitsi
    echo ""

    read -r ip _ <<<$(hostname -I | tr ' ' '\n' | grep -v '^127\.0\.0\.1' | grep -v '^10\.0\.0\.' | tr '\n' ' ')

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/4\e[0m"
    echo -en "\e[33mDigite o IP Publico da VPS (ex: $ip): \e[0m" && read -r ip_jitsi
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/4\e[0m"
    echo -en "\e[33mDigite o Usuario para o Jitsi (ex: admin): \e[0m" && read -r user_jitsi
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/4\e[0m"
    echo -en "\e[33mDigite a Senha para o Jitsi (ex: @Senha123_): \e[0m" && read -r pass_jitsi
    echo ""

    ## Limpa o terminal
    clear

    ## Mostra o nome da aplicacao
    nome_jitsi

    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do Jitsi:\e[97m $url_jitsi\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mIP da VPS:\e[97m $ip_jitsi\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mUsuario do Jitsi:\e[97m $user_jitsi\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do Jitsi:\e[97m $pass_jitsi\e[0m"
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
        nome_jitsi

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO JITSI \e[33m[1/4]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO JITSI \e[33m[2/4]\e[0m"
echo ""
sleep 1

jicofo_secret_jitsi=$(openssl rand -hex 16)
jicofo_component_jitsi=$(openssl rand -hex 16)
jvb_auth_jitsi=$(openssl rand -hex 16)

## Criando a stack jitsi.yaml
cat > jitsi${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  jitsi${1:+_$1}_web:
    image: jitsi/web:stable

    networks:
      - $nome_rede_interna ## Nome da rede interna

    volumes:
      - jitsi${1:+_$1}_web_config:/config:Z
      - jitsi${1:+_$1}_web_crontabs:/var/spool/cron/crontabs:Z
      - jitsi${1:+_$1}_transcripts:/usr/share/jitsi-meet/transcripts:Z

    environment:
    ##  Fuso Horario
      - TZ=America/Sao_Paulo

    ## " AutenticaAAo e Acesso
      - ENABLE_AUTH=1 ## Ativa autenticacao (secure-domain)
      - AUTH_TYPE=internal ## Backend de auth do Prosody (interno)
      - ENABLE_GUESTS=1 ## Convidados entram apos a sala existir
      - ENABLE_LOBBY=1 ## Lobby disponivel
      - PUBLIC_URL=https://$url_jitsi ## URL publica de acesso

    ##  Paginas e Fluxo de Entrada/Saida
      - ENABLE_PREJOIN_PAGE=1 ## Tela de pre-entrada (checar audio/video, nome)
      - ENABLE_WELCOME_PAGE=1 ## Sem pagina inicial; "/" cria sala automaticamente
      - ENABLE_CLOSE_PAGE=1 ## Mostra pAgina aEURreuniAo encerradaaEUR

    ##  Recursos de Sala e Moderacao
      - ENABLE_BREAKOUT_ROOMS=1 ## Salas paralelas
      - ENABLE_AV_MODERATION=1 ## Moderacao de audio/video
      - ENABLE_END_CONFERENCE=1 ## Moderador pode encerrar reuniao
      - ENABLE_REQUIRE_DISPLAY_NAME=1 ## Obriga digitar nome

    ##  Recursos de Gravacao e Transcricao
      - ENABLE_RECORDING=0 ## Gravacao via Jibri (infra extra) - deixe 0 se nao tiver
      - ENABLE_FILE_RECORDING_SHARING=0 ## Compartilhar arquivo de gravacao (se usar Jibri)
      - ENABLE_TRANSCRIPTIONS=0 ## Transcricoes via Jigasi/STT (infra extra) - deixe 0

    ##  Interatividade e Engajamento
      - ENABLE_POLLS=1 ## Enquetes
      - ENABLE_REACTIONS=1 ## Reacoes
      - ENABLE_RAISE_HAND=1 ## Levantar mao

    ##  ConexAo e Qualidade de Audio/VAdeo
      - ENABLE_P2P=1 ## P2P quando so 2 participantes
      - ENABLE_NOISE_SUPPRESSION=1 ## Supressao de ruido (client-side)
      - ENABLE_STEREO=0 ## Audio esta(c)reo (consome mais banda)
      - ENABLE_TALK_WHILE_MUTED=1 ## Aviso ao falar no mudo
      - ENABLE_NO_AUDIO_DETECTION=1      ## Aviso quando nao ha audio

    ##  Configuracao do XMPP/Prosody
      - XMPP_SERVER=jitsi${1:+_$1}_prosody
      - XMPP_DOMAIN=meet.jitsi
      - XMPP_AUTH_DOMAIN=auth.meet.jitsi
      - XMPP_GUEST_DOMAIN=guest.meet.jitsi
      - XMPP_MUC_DOMAIN=muc.meet.jitsi
      - XMPP_BOSH_URL_BASE=http://jitsi${1:+_$1}_prosody:5280
      - ENABLE_XMPP_WEBSOCKET=1

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
        - traefik.http.routers.jitsi${1:+_$1}_web.rule=Host(\`$url_jitsi\`)
        - traefik.http.services.jitsi${1:+_$1}_web.loadbalancer.server.port=80
        - traefik.http.routers.jitsi${1:+_$1}_web.service=jitsi${1:+_$1}_web
        - traefik.http.routers.jitsi${1:+_$1}_web.tls.certresolver=letsencryptresolver
        - traefik.http.routers.jitsi${1:+_$1}_web.entrypoints=websecure
        - traefik.http.routers.jitsi${1:+_$1}_web.tls=true

## --------------------------- FELSEN --------------------------- ##

  jitsi${1:+_$1}_prosody:
    image: jitsi/prosody:stable

    volumes:
      - jitsi${1:+_$1}_prosody_config:/config:Z
      - jitsi${1:+_$1}_prosody_plugins:/prosody-plugins-custom:Z

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Fuso Horario
      - TZ=America/Sao_Paulo

    ## " AutenticaAAo e Acesso
      - ENABLE_AUTH=1
      - AUTH_TYPE=internal
      - ENABLE_GUESTS=1

    ## " Credenciais do Jicofo e JVB
      - JICOFO_AUTH_USER=focus
      - JICOFO_AUTH_PASSWORD=$jicofo_secret_jitsi
      - JICOFO_COMPONENT_SECRET=$jicofo_component_jitsi
      - JVB_AUTH_USER=jvb
      - JVB_AUTH_PASSWORD=$jvb_auth_jitsi

    ##  Configuracao do XMPP/Prosody
      - XMPP_DOMAIN=meet.jitsi
      - XMPP_AUTH_DOMAIN=auth.meet.jitsi
      - XMPP_GUEST_DOMAIN=guest.meet.jitsi
      - XMPP_MUC_DOMAIN=muc.meet.jitsi
      - XMPP_INTERNAL_MUC_DOMAIN=internal-muc.meet.jitsi
      - ENABLE_XMPP_WEBSOCKET=1

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

## --------------------------- FELSEN --------------------------- ##

  jitsi${1:+_$1}_jicofo:
    image: jitsi/jicofo:stable

    volumes:
      - jitsi${1:+_$1}_jicofo_config:/config:Z

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Fuso Horario
      - TZ=America/Sao_Paulo

    ## " AutenticaAAo e Acesso
      - ENABLE_AUTH=1
      - AUTH_TYPE=internal

    ## " Credenciais do Jicofo
      - JICOFO_COMPONENT_SECRET=$jicofo_component_jitsi
      - JICOFO_AUTH_USER=focus
      - JICOFO_AUTH_PASSWORD=$jicofo_secret_jitsi

    ##  Configuracao do XMPP/Prosody
      - XMPP_DOMAIN=meet.jitsi
      - XMPP_SERVER=jitsi${1:+_$1}_prosody
      - XMPP_AUTH_DOMAIN=auth.meet.jitsi

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

## --------------------------- FELSEN --------------------------- ##

  jitsi${1:+_$1}_jvb:
    image: jitsi/jvb:stable

    volumes:
      - jitsi${1:+_$1}_jvb_config:/config:Z

    networks:
      - $nome_rede_interna ## Nome da rede interna
    ports:
      - target: 10000
        published: 10000
        protocol: udp
        mode: host
      - target: 4443
        published: 4443
        protocol: tcp
        mode: host

    environment:
    ##  Fuso Horario
      - TZ=America/Sao_Paulo

    ## " Credenciais do JVB
      - JVB_AUTH_USER=jvb
      - JVB_AUTH_PASSWORD=$jvb_auth_jitsi
      - JVB_BREWERY_MUC=jvbbrewery

    ##  Portas de midia
      - JVB_PORT=10000
      - JVB_TCP_PORT=4443
      - JVB_TCP_HARVESTER_DISABLED=false

    ##  EndereAo pAoblico (para ICE / NAT)
      - DOCKER_HOST_ADDRESS=$ip_jitsi
      - JVB_ADVERTISE_IPS=$ip_jitsi

    ##  Servidor STUN para candidatos reflexivos (ajuda NAT)
      - JVB_STUN_SERVERS=stun.l.google.com:19302

    ##  Configuracao do XMPP/Prosody
      - XMPP_SERVER=jitsi${1:+_$1}_prosody
      - XMPP_DOMAIN=meet.jitsi
      - XMPP_AUTH_DOMAIN=auth.meet.jitsi
      - XMPP_INTERNAL_MUC_DOMAIN=internal-muc.meet.jitsi

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "2"
          memory: 2048M

## --------------------------- FELSEN --------------------------- ##

volumes:
  jitsi${1:+_$1}_web_config:
    external: true
    name: jitsi${1:+_$1}_web_config
  jitsi${1:+_$1}_web_crontabs:
    external: true
    name: jitsi${1:+_$1}_web_crontabs
  jitsi${1:+_$1}_transcripts:
    external: true
    name: jitsi${1:+_$1}_transcripts
  jitsi${1:+_$1}_prosody_config:
    external: true
    name: jitsi${1:+_$1}_prosody_config
  jitsi${1:+_$1}_prosody_plugins:
    external: true
    name: jitsi${1:+_$1}_prosody_plugins
  jitsi${1:+_$1}_jicofo_config:
    external: true
    name: jitsi${1:+_$1}_jicofo_config
  jitsi${1:+_$1}_jvb_config:
    external: true
    name: jitsi${1:+_$1}_jvb_config

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna

__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do jitsi"
fi

STACK_NAME="jitsi${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c jitsi.yaml jitsi > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do jitsi"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull jitsi/web:stable jitsi/prosody:stable jitsi/jicofo:stable jitsi/jvb:stable

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack jitsi${1:+_$1}_jitsi${1:+_$1}_web jitsi${1:+_$1}_jitsi${1:+_$1}_prosody jitsi${1:+_$1}_jitsi${1:+_$1}_jicofo jitsi${1:+_$1}_jitsi${1:+_$1}_jvb


## Mensagem de Passo
echo -e "\e[97m- CRIANDO USUARIO \e[33m[4/4]\e[0m"
echo ""
sleep 1

docker exec -t "$(docker ps --filter "name=jitsi${1:+_$1}_prosody" -q)" bash -c "prosodyctl --config /config/prosody.cfg.lua register $user_jitsi meet.jitsi $pass_jitsi"


cd dados_vps

cat > dados_jitsi${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ JITSI ]

Dominio do jitsi: https://$url_jitsi

Usuario: $user_jitsi

Senha: $pass_jitsi
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
echo -e "\e[32m[ JITSI ]\e[0m"
echo ""

echo -e "\e[33mDominio do jitsi:\e[97m https://$url_jitsi\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_jitsi\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_jitsi\e[0m"
echo ""

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##  ####### ####### ####### ########    ####################### ###   ################## 
## a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-    a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--
## a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-a-a-a--      a-a-a-a-a-a-a-a--a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-
## a-a-a-'     a-a-a-'   a-a-a-'a-a-a-'  a-a-a-'a-a-a-"a-a-a-      a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--    a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-' a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'
##  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-    a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-  a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-  a-a-a-

