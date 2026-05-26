#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

traefik.dash() {
clear
nome_traefik
## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do
    ## Pergunta o link do Dashboard
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite um link para o Dashboard do Traefik (ex: traefik.example.com): \e[0m" && read -r traefik_url_dashboard
    echo ""

    ## Pergunta o usuario da ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$ e/ou espacos"
    echo -en "\e[33mDigite um usuario (ex: Felsen): \e[0m" && read -r traefik_user
    echo ""

    ## Pergunta o senha da ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "$amarelo--> Sem caracteres especiais: \!#$"
    echo -en "\e[33mDigite uma Senha (ex: @Senha123_): \e[0m" && read -r traefik_pass
    echo ""

## Pergunta se as respostas estao corretas
    read -p "As respostas estao corretas? (Y/N): " confirmacao
    if [ "$confirmacao" = "Y" ] || [ "$confirmacao" = "y" ]; then

        ## Digitou Y para confirmar que as informacoes estao corretas
        echo ""
        ## Sai do Loop
        break
    else

        ## Digitou N para dizer que as informacoes nao estao corretas.

        ## Limpar o terminal
        clear

        nome_traefik
        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

clear
instalando_msg
## Coletando informacoes da atual Stack do Traefik

## Mensagem de Passo
echo -e "\e[97m- PEGANDO INFORMACOES DO TRAEFIK \e[33m[1/4]\e[0m"
echo ""
sleep 1

ARQUIVO="/root/traefik.yaml"
email_ssl=$(grep -oP '(?<=--certificatesresolvers\.letsencryptresolver\.acme\.email=).*' "$ARQUIVO" | awk '{print $1}' | tr -d '"')
nome_rede_interna=$(awk '/^networks:/,/^volumes:/ {if ($1 == "name:") print $2}' "$ARQUIVO")

echo -e "\e[97mEmail SSL \e[33m$email_ssl\e[0m"
echo ""

echo -e "\e[97mRede Interna \e[33m$nome_rede_interna\e[0m"
echo ""

## Mensagem de Passo
echo -e "\e[97m- ATUALIZANDO STACK DO TRAEFIK \e[33m[2/4]\e[0m"
echo ""
sleep 1

mv /root/traefik.yaml /root/traefik.yaml.old

## Gera BasicAuth
basicauth=$(htpasswd -nbB "$traefik_user" "$traefik_pass" | sed 's/\$/\$\$/g')

## Criando a stack traefik.yaml
cat > traefik.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:
  ## --------------------------- FELSEN --------------------------- ##

  traefik:
    image: traefik:v3.5.3
    command:
      - "--api.dashboard=true"
      - "--providers.swarm=true"
      - "--providers.docker.endpoint=unix:///var/run/docker.sock"
      - "--providers.docker.exposedbydefault=false"
      - "--providers.docker.network=$nome_rede_interna" ## Nome da rede interna
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      - "--entrypoints.web.http.redirections.entrypoint.permanent=true"
      - "--entrypoints.websecure.address=:443"
      - "--api.insecure=true"
      - "--entrypoints.web.transport.respondingTimeouts.idleTimeout=3600"
      - "--certificatesresolvers.letsencryptresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencryptresolver.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencryptresolver.acme.storage=/etc/traefik/letsencrypt/acme.json"
      - "--certificatesresolvers.letsencryptresolver.acme.email=$email_ssl" ## Email para receber as notificacoes
      - "--log.level=DEBUG"
      - "--log.format=common"
      - "--log.filePath=/var/log/traefik/traefik.log"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik/access-log"

    volumes:
      - "vol_certificates:/etc/traefik/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ports:
      - target: 80
        published: 80
        mode: host
      - target: 443
        published: 443
        mode: host

    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        - "traefik.enable=true"
        - "traefik.http.middlewares.redirect-https.redirectscheme.scheme=https"
        - "traefik.http.middlewares.redirect-https.redirectscheme.permanent=true"
        - "traefik.http.routers.http-catchall.rule=Host(\`{host:.+}\`)"
        - "traefik.http.routers.http-catchall.entrypoints=web"
        - "traefik.http.routers.http-catchall.middlewares=redirect-https@docker"
        - "traefik.http.routers.http-catchall.priority=1"

        ## Dashboard Traefik
        - "traefik.http.routers.traefik.rule=Host(\`$traefik_url_dashboard\`)" ## Dominio do traefik
        - "traefik.http.services.traefik.loadbalancer.server.port=8080"
        - "traefik.http.routers.traefik.tls.certresolver=letsencryptresolver"
        - "traefik.http.routers.traefik.service=traefik"
        - "traefik.http.routers.traefik.entrypoints=websecure"
        - "traefik.http.routers.traefik.priority=1"
        - "traefik.http.routers.traefik.middlewares=authtraefik"
        - "traefik.http.middlewares.authtraefik.basicauth.users=$basicauth"

## --------------------------- FELSEN --------------------------- ##

volumes:
  vol_shared:
    external: true
    name: volume_swarm_shared
  vol_certificates:
    external: true
    name: volume_swarm_certificates

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    attachable: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Criando Stack"
else
    echo "1/3 - [ OFF ] - Criando Stack"
    echo "Ops, nao foi possivel criar a stack do Traefik"
fi

docker stack deploy --prune --resolve-image always -c traefik.yaml traefik
if [ $? -eq 0 ]; then
    echo "2/3 - [ OK ] - Subindo stack do traefik"
else
    echo "2/3 - [ OFF ] - Erro ao subir stack do traefik"
    echo "Verifique se o arquivo 'traefik.yaml' existe e esta correto."
    return 1
fi

# Passo 2: Espera a stack ficar online
if wait_stack "traefik"; then
    sleep 20
    echo "3/3 - [ OK ] - Traefik esta online"
    rm /root/traefik.yaml.old
else
    echo "3/3 - [ OFF ] - Traefik nao ficou online"
    echo "Verifique os logs para mais detalhes."
    return 1
fi

# Resultado final
echo ""
echo -e "\e[32m[ TRAEFIK DASHBOARD ]\e[0m"
echo ""

echo -e "\e[33mUrl do Dashboard:\e[97m https://$traefik_url_dashboard\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $traefik_user\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $traefik_pass\e[0m"


## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

