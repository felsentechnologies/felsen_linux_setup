#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_n8n_quepasa() {

## Verifica os recursos
recursos 2 2 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_n8n_quepasa

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio do N8N
    echo -e "\e[97mPasso$amarelo 1/8\e[0m"
    echo -en "\e[33mDigite o dominio para o N8N (ex: n8n.example.com): \e[0m" && read -r url_editorn8n
    echo ""
    
    ##Pergunta o Dominio do Webhook
    echo -e "\e[97mPasso$amarelo 2/8\e[0m"
    echo -en "\e[33mDigite o dominio para o Webhook do N8N (ex: webhook.example.com): \e[0m" && read -r url_webhookn8n
    echo ""

    ##Pergunta Dominio do Chatwoot
    echo -e "\e[97mPasso$amarelo 3/8\e[0m"
    echo -en "\e[33mDigite o dominio do Chatwoot (ex: chatwoot.example.com): \e[0m" && read -r dominio_chatwoot
    echo ""

    ##Pergunta Dominio do Quepasa
    echo -e "\e[97mPasso$amarelo 4/8\e[0m"
    echo -en "\e[33mDigite o dominio do Quepasa (ex: quepasa.example.com): \e[0m" && read -r dominio_quepasa
    echo ""

    ##Pergunta Email do Quepasa
    echo -e "\e[97mPasso$amarelo 5/8\e[0m"
    echo -en "\e[33mDigite o email do Quepasa (ex: contato@example.com): \e[0m" && read -r email_quepasa
    echo ""

     ## Nome usuario padrao para criacao do qrcode (utoken)
    echo -e "\e[97mPasso$amarelo 6/8\e[0m"
    echo -en "\e[33mNome do usuario padrao (Crie um usuario Admin no Chatwoot) (ex: Bot): \e[0m" && read -r user_padrao
    echo ""

     ## Token do usuario criado Admin
    echo -e "\e[97mPasso$amarelo 7/8\e[0m"
    echo -en "\e[33mToken do seu usuario criado (ex: cv1dNNkgiXLvqKl6LSj0V4yu6Eqd77N): \e[0m" && read -r user_padrao_token
    echo ""

     ## ID do usuario criado Admin
    echo -e "\e[97mPasso$amarelo 8/8\e[0m"
    echo -en "\e[33mID do seu usuario criado (ex: 2): \e[0m" && read -r user_padrao_id
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_n8n_quepasa
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do N8N
    echo -e "\e[33mDominio do N8N:\e[97m $url_editorn8n\e[0m"
    echo ""
    
    ## Informacao sobre URL do Webhook
    echo -e "\e[33mDominio para o Webhook:\e[97m $url_webhookn8n\e[0m"
    echo ""

    ## Informacao sobre URL do Chatwoot
    echo -e "\e[33mDominio do Chatwoot:\e[97m $dominio_chatwoot\e[0m"
    echo ""

    ## Informacao sobre URL do Quepasa
    echo -e "\e[33mDominio do Quepasa:\e[97m $dominio_quepasa\e[0m"
    echo ""

    ## Informacao Email do Quepasa
    echo -e "\e[33mEmail do Quepasa:\e[97m $email_quepasa\e[0m"
    echo ""
    ## Nome do usuario padrao para vincular ao qrcode (utoken)
    echo -e "\e[33mNome do User Padrao:\e[97m $user_padrao\e[0m"
    echo ""

     ## Token do usuario padrao para vincular ao qrcode (utoken)
    echo -e "\e[33mToken User Padrao:\e[97m $user_padrao_token\e[0m"
    echo ""
    
     ## ID do usuario padrao para vincular ao qrcode (utoken)
    echo -e "\e[33mToken User Padrao:\e[97m $user_padrao_id\e[0m"
    echo ""

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
        nome_n8n_quepasa

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO N8N \e[33m[1/5]\e[0m"
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
    criar_banco_postgres_da_stack "n8n_quepasa${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "n8n_quepasa${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO REDIS \e[33m[3/5]\e[0m"
echo ""
sleep 1

## Verifica/instala o Redis
verificar_container_redis
if [ $? -eq 0 ]; then
    echo "1/1 - [ OK ] - Redis ja instalado"
    echo ""
else
    ferramenta_redis
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO N8N \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Criando key Aleatoria
encryption_key=$(openssl rand -hex 16)

## Criando a stack n8n_quepasa.yaml
cat > n8n_quepasa${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  n8n_quepasa${1:+_$1}_editor:
    image: deividms/n8n-quepasa:latest ## Versao do N8N
    command: start

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      ## Dados do postgres
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n_quepasa${1:+_$1}
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=$senha_postgres

      ## Dados do Quepasa
      ### Fluxos IDS
      - C8Q_QUEPASAINBOXCONTROL=1001
      - C8Q_GETCHATWOOTCONTACTS=1002
      - C8Q_QUEPASACHATCONTROL=1003
      - C8Q_CHATWOOTPROFILEUPDATE=1004
      - C8Q_POSTTOWEBCALLBACK=1005
      - C8Q_POSTTOCHATWOOT=1006
      - C8Q_CHATWOOTTOQUEPASAGREETINGS=1007
      - C8Q_TOCHATWOOTTRANSCRIPT=pi4APHD9F05Dv6FR
      - C8Q_TOCHATWOOTTRANSCRIPTRESUME=true
      - C8Q_GETVALIDCONVERSATION=qjdP01sHPfaPFUq1
      - C8Q_WF_CHATWOOTEXTRA=t1o1WDo9E7C5EmJC
      - C8Q_WF_TOTYPEBOT=JSpCXQiF7TT1zUgp
      - C8Q_WF_QUEPASAINBOXCONTROL_TYPEBOT=BvfU3kc7i0j68IpZ
      - C8Q_WF_QUEPASAINBOXCONTROL_SOC=wtn1ZvAUTFwKCHfK 
      - C8Q_WF_QUEPASAINBOXCONTROL_WEBHOOK=Zj197aISsaIkZP2Z

      ### Config Gerais
      - C8Q_SINGLETHREAD=false
      - C8Q_MSGFOR_NO_CSAT=
      - C8Q_SUPERUSER_NAME=$user_padrao
      - C8Q_SUPERUSER_TOKEN=$user_padrao_token
      - C8Q_SUPERUSER_ID=$user_padrao_id
      - C8Q_CW_PUBLIC_URL=$dominio_chatwoot
      - C8Q_QP_DEFAULT_USER=$email_quepasa
      - C8Q_QP_BOTTITLE=$nome_servidor
      - C8Q_QP_CONTACT=$email_quepasa
      - C8Q_CW_HOST=https://$dominio_chatwoot
      - C8Q_N8N_HOST=https://$url_editorn8n
      - C8Q_N8N_WEBHOOK=https://$url_webhookn8n
      - C8Q_QUEPASA_HOST=https://$dominio_quepasa
      - C8Q_QP_HOST=https://$dominio_quepasa
      - C8Q_MSGFOR_UNKNOWN_CONTENT=! "Algum EMOJI" ou "Alguma Reacao que o sistema nao entende ainda ..."
      - C8Q_MSGFOR_EDITED_CONTENT=**Essa mensagem foi editada !**
      - C8Q_MSGFOR_ATTACHERROR_CONTENT=** Falha ao baixar anexo !
      - C8Q_MSGFOR_LOCALIZATION_CONTENT=* Localizacao *
      - C8Q_MSGFOR_REVOKED_CONTENT=a Essa mensagem foi apagada !!!
      - C8Q_MSGFOR_CALL_CONTENT=O usuario requisitou uma chamada de voz !
      - C8Q_MSGFOR_REJECT_CALL=Nao aceitamos Ligacao - MSG configurada na Stack
      - C8Q_QP_DEFAULT_CALL=true

      ### Typebot
      # - C8Q_TYPEBOT_HOST=url_web_typebot
      # - C8Q_TYPEBOT_TOKEN=API-Token

      ## Encryption Key
      - N8N_ENCRYPTION_KEY=$encryption_key

      ## Url do N8N
      - N8N_HOST=$url_editorn8n
      - N8N_EDITOR_BASE_URL=https://$url_editorn8n/
      - WEBHOOK_URL=https://$url_webhookn8n/
      - N8N_PROTOCOL=https

      ## Modo do Node
      - NODE_ENV=production
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true
      - N8N_RUNNERS_ENABLED=true

      ## Modo de execucao (deletar caso deseje em modo regular)
      - EXECUTIONS_MODE=queue

      ## Dados do Redis
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=2
      - NODE_FUNCTION_ALLOW_EXTERNAL=moment,lodash
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=336

      ## Timezone
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - TZ=America/Sao_Paulo

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.n8n_quepasa${1:+_$1}_editor.rule=Host(\`$url_editorn8n\`)
        - traefik.http.routers.n8n_quepasa${1:+_$1}_editor.entrypoints=websecure
        - traefik.http.routers.n8n_quepasa${1:+_$1}_editor.priority=1
        - traefik.http.routers.n8n_quepasa${1:+_$1}_editor.tls.certresolver=letsencryptresolver
        - traefik.http.routers.n8n_quepasa${1:+_$1}_editor.service=n8n_quepasa${1:+_$1}_editor
        - traefik.http.services.n8n_quepasa${1:+_$1}_editor.loadbalancer.server.port=5678
        - traefik.http.services.n8n_quepasa${1:+_$1}_editor.loadbalancer.passHostHeader=1

## --------------------------- FELSEN --------------------------- ##

  n8n_quepasa${1:+_$1}_webhook:
    image: deividms/n8n-quepasa:latest ## Versao do N8N
    command: webhook

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      ## Dados do postgres
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n_quepasa${1:+_$1}
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=$senha_postgres

      ## Dados do Quepasa
      ### Fluxos IDS
      - C8Q_QUEPASAINBOXCONTROL=1001
      - C8Q_GETCHATWOOTCONTACTS=1002
      - C8Q_QUEPASACHATCONTROL=1003
      - C8Q_CHATWOOTPROFILEUPDATE=1004
      - C8Q_POSTTOWEBCALLBACK=1005
      - C8Q_POSTTOCHATWOOT=1006
      - C8Q_CHATWOOTTOQUEPASAGREETINGS=1007
      - C8Q_TOCHATWOOTTRANSCRIPT=pi4APHD9F05Dv6FR
      - C8Q_TOCHATWOOTTRANSCRIPTRESUME=true
      - C8Q_GETVALIDCONVERSATION=qjdP01sHPfaPFUq1
      - C8Q_WF_CHATWOOTEXTRA=t1o1WDo9E7C5EmJC
      - C8Q_WF_TOTYPEBOT=JSpCXQiF7TT1zUgp
      - C8Q_WF_QUEPASAINBOXCONTROL_TYPEBOT=BvfU3kc7i0j68IpZ
      - C8Q_WF_QUEPASAINBOXCONTROL_SOC=wtn1ZvAUTFwKCHfK 
      - C8Q_WF_QUEPASAINBOXCONTROL_WEBHOOK=Zj197aISsaIkZP2Z

      ### Config Gerais
      - C8Q_SINGLETHREAD=false
      - C8Q_MSGFOR_NO_CSAT=
      - C8Q_SUPERUSER_NAME=$user_padrao
      - C8Q_SUPERUSER_TOKEN=$user_padrao_token
      - C8Q_SUPERUSER_ID=$user_padrao_id
      - C8Q_CW_PUBLIC_URL=$dominio_chatwoot
      - C8Q_QP_DEFAULT_USER=$email_quepasa
      - C8Q_QP_BOTTITLE=$nome_servidor
      - C8Q_QP_CONTACT=$email_quepasa
      - C8Q_CW_HOST=https://$dominio_chatwoot
      - C8Q_N8N_HOST=https://$url_editorn8n
      - C8Q_N8N_WEBHOOK=https://$url_webhookn8n
      - C8Q_QUEPASA_HOST=https://$dominio_quepasa
      - C8Q_QP_HOST=https://$dominio_quepasa
      - C8Q_MSGFOR_UNKNOWN_CONTENT=! "Algum EMOJI" ou "Alguma Reacao que o sistema nao entende ainda ..."
      - C8Q_MSGFOR_EDITED_CONTENT=**Essa mensagem foi editada !**
      - C8Q_MSGFOR_ATTACHERROR_CONTENT=** Falha ao baixar anexo !
      - C8Q_MSGFOR_LOCALIZATION_CONTENT=* Localizacao *
      - C8Q_MSGFOR_REVOKED_CONTENT=a Essa mensagem foi apagada !!!
      - C8Q_MSGFOR_CALL_CONTENT=O usuario requisitou uma chamada de voz !
      - C8Q_MSGFOR_REJECT_CALL=Nao aceitamos Ligacao - MSG configurada na Stack
      - C8Q_QP_DEFAULT_CALL=true

      ### Typebot
      # - C8Q_TYPEBOT_HOST=url_web_typebot
      # - C8Q_TYPEBOT_TOKEN=API-Token

      ## Encryption Key
      - N8N_ENCRYPTION_KEY=$encryption_key

      ## Url do N8N
      - N8N_HOST=$url_editorn8n
      - N8N_EDITOR_BASE_URL=https://$url_editorn8n/
      - WEBHOOK_URL=https://$url_webhookn8n/
      - N8N_PROTOCOL=https

      ## Modo do Node
      - NODE_ENV=production
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true
      - N8N_RUNNERS_ENABLED=true

      ## Modo de execucao (deletar caso deseje em modo regular)
      - EXECUTIONS_MODE=queue

      ## Dados do Redis
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=2
      - NODE_FUNCTION_ALLOW_EXTERNAL=moment,lodash
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=336

      ## Timezone
      - GENERIC_TIMEZONE=America/Sao_Paulo
      - TZ=America/Sao_Paulo
      
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.n8n_quepasa${1:+_$1}_webhook.rule=(Host(\`$url_webhookn8n\`))
        - traefik.http.routers.n8n_quepasa${1:+_$1}_webhook.entrypoints=websecure
        - traefik.http.routers.n8n_quepasa${1:+_$1}_webhook.priority=1
        - traefik.http.routers.n8n_quepasa${1:+_$1}_webhook.tls.certresolver=letsencryptresolver
        - traefik.http.routers.n8n_quepasa${1:+_$1}_webhook.service=n8n_quepasa${1:+_$1}_webhook
        - traefik.http.services.n8n_quepasa${1:+_$1}_webhook.loadbalancer.server.port=5678
        - traefik.http.services.n8n_quepasa${1:+_$1}_webhook.loadbalancer.passHostHeader=1

## --------------------------- FELSEN --------------------------- ##

  n8n_quepasa${1:+_$1}_worker:
    image: deividms/n8n-quepasa:latest ## Versao do N8N
    command: worker --concurrency=10

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      ## Dados do postgres
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=n8n_quepasa${1:+_$1}
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=postgres
      - DB_POSTGRESDB_PASSWORD=$senha_postgres

      ## Dados do Quepasa
      ### Fluxos IDS
      - C8Q_QUEPASAINBOXCONTROL=1001
      - C8Q_GETCHATWOOTCONTACTS=1002
      - C8Q_QUEPASACHATCONTROL=1003
      - C8Q_CHATWOOTPROFILEUPDATE=1004
      - C8Q_POSTTOWEBCALLBACK=1005
      - C8Q_POSTTOCHATWOOT=1006
      - C8Q_CHATWOOTTOQUEPASAGREETINGS=1007
      - C8Q_TOCHATWOOTTRANSCRIPT=pi4APHD9F05Dv6FR
      - C8Q_TOCHATWOOTTRANSCRIPTRESUME=true
      - C8Q_GETVALIDCONVERSATION=qjdP01sHPfaPFUq1
      - C8Q_WF_CHATWOOTEXTRA=t1o1WDo9E7C5EmJC
      - C8Q_WF_TOTYPEBOT=JSpCXQiF7TT1zUgp
      - C8Q_WF_QUEPASAINBOXCONTROL_TYPEBOT=BvfU3kc7i0j68IpZ
      - C8Q_WF_QUEPASAINBOXCONTROL_SOC=wtn1ZvAUTFwKCHfK 
      - C8Q_WF_QUEPASAINBOXCONTROL_WEBHOOK=Zj197aISsaIkZP2Z

      ### Config Gerais
      - C8Q_SINGLETHREAD=false
      - C8Q_MSGFOR_NO_CSAT=
      - C8Q_SUPERUSER_NAME=$user_padrao
      - C8Q_SUPERUSER_TOKEN=$user_padrao_token
      - C8Q_SUPERUSER_ID=$user_padrao_id
      - C8Q_CW_PUBLIC_URL=$dominio_chatwoot
      - C8Q_QP_DEFAULT_USER=$email_quepasa
      - C8Q_QP_BOTTITLE=$nome_servidor
      - C8Q_QP_CONTACT=$email_quepasa
      - C8Q_CW_HOST=https://$dominio_chatwoot
      - C8Q_N8N_HOST=https://$url_editorn8n
      - C8Q_N8N_WEBHOOK=https://$url_webhookn8n
      - C8Q_QUEPASA_HOST=https://$dominio_quepasa
      - C8Q_QP_HOST=https://$dominio_quepasa
      - C8Q_MSGFOR_UNKNOWN_CONTENT=! "Algum EMOJI" ou "Alguma Reacao que o sistema nao entende ainda ..."
      - C8Q_MSGFOR_EDITED_CONTENT=**Essa mensagem foi editada !**
      - C8Q_MSGFOR_ATTACHERROR_CONTENT=** Falha ao baixar anexo !
      - C8Q_MSGFOR_LOCALIZATION_CONTENT=* Localizacao *
      - C8Q_MSGFOR_REVOKED_CONTENT=a Essa mensagem foi apagada !!!
      - C8Q_MSGFOR_CALL_CONTENT=O usuario requisitou uma chamada de voz !
      - C8Q_MSGFOR_REJECT_CALL=Nao aceitamos Ligacao - MSG configurada na Stack
      - C8Q_QP_DEFAULT_CALL=true

      ### Typebot
      # - C8Q_TYPEBOT_HOST=url_web_typebot
      # - C8Q_TYPEBOT_TOKEN=API-Token

      ## Encryption Key
      - N8N_ENCRYPTION_KEY=$encryption_key

      ## Url do N8N
      - N8N_HOST=$url_editorn8n
      - N8N_EDITOR_BASE_URL=https://$url_editorn8n/
      - WEBHOOK_URL=https://$url_webhookn8n/
      - N8N_PROTOCOL=https

      ## Modo do Node
      - NODE_ENV=production
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - OFFLOAD_MANUAL_EXECUTIONS_TO_WORKERS=true
      - N8N_RUNNERS_ENABLED=true

      ## Modo de execucao (deletar caso deseje em modo regular)
      - EXECUTIONS_MODE=queue

      ## Dados do Redis
      - QUEUE_BULL_REDIS_HOST=redis
      - QUEUE_BULL_REDIS_PORT=6379
      - QUEUE_BULL_REDIS_DB=2
      - NODE_FUNCTION_ALLOW_EXTERNAL=moment,lodash
      - EXECUTIONS_DATA_PRUNE=true
      - EXECUTIONS_DATA_MAX_AGE=336

      ## Timezone
      - GENERIC_TIMEZONE=America/Sao_Paulo
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

## --------------------------- FELSEN --------------------------- ##


networks:
  $nome_rede_interna:
    name: $nome_rede_interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do N8N Quepasa"
fi
STACK_NAME="n8n_quepasa${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c n8n_quepasa.yaml n8n_quepasa > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do N8N Quepasa"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull deividms/n8n-quepasa:latest

## Usa o servico wait_n8n para verificar se o servico esta online
wait_stack n8n_quepasa${1:+_$1}_n8n_quepasa${1:+_$1}_editor n8n_quepasa${1:+_$1}_n8n_quepasa${1:+_$1}_webhook n8n_quepasa${1:+_$1}_n8n_quepasa${1:+_$1}_worker


cd dados_vps

cat > dados_n8n_quepasa${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ N8N QUEPASA ]

Dominio do N8N: https://$url_editorn8n

Dominio do N8N: https://$url_webhookn8n

Email: Precisa criar no primeiro acesso do N8N

Senha: Precisa criar no primeiro acesso do N8N
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
echo -e "\e[32m[ N8N QUEPASA ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_editorn8n\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m Precisa criar no primeiro acesso do N8N\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa criar no primeiro acesso do N8N\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}


##  ####### ###   ##################  ###### ######## ###### 
## a-a-a-"a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--
## a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'
## a-a-a-'a-"a-" a-a-a-'a-a-a-'   a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-'
## a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-'     a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-'  a-a-a-'
##  a-a-a-a-EURa-EURa-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-

