#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_redisinsight() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_redisinsight

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o RedisInsight (ex: redisinsight.example.com): \e[0m" && read -r url_redisinsight
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite um usuario para o RedisInsight (ex: admin): \e[0m" && read -r user_redisinsight
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite uma senha para o usuario (ex: @Senha123_): \e[0m" && read -r pass_redisinsight
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_redisinsight
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do redisinsight
    echo -e "\e[33mDominio do redisInsight:\e[97m $url_redisinsight\e[0m"
    echo ""

    ## Informacao sobre URL do redisinsight
    echo -e "\e[33mUsuario:\e[97m $user_redisinsight\e[0m"
    echo ""

    ## Informacao sobre URL do redisinsight
    echo -e "\e[33mSenha:\e[97m $pass_redisinsight\e[0m"
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
        nome_redisinsight

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO REDISINSIGHT \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO REDISINSIGHT \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Gerando Hash
auth_redisinsight=$(htpasswd -nb $user_redisinsight $pass_redisinsight | sed -e s/\\$/\\$\\$/g)

## Criando a stack redisinsight.yaml
cat > redisinsight${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  redisinsight${1:+_$1}:
    image: redislabs/redisinsight:latest

    volumes:
      - redisinsight${1:+_$1}_data:/db
      - redisinsight${1:+_$1}_logs:/data/logs

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Aplicacao
      - RI_APP_PORT=5540
      - RI_APP_HOST=0.0.0.0

    ## " Encryption Key
      - RI_ENCRYPTION_KEY=$key_redisinsight

    ##  Logs
      - RI_LOG_LEVEL=info
      - RI_FILES_LOGGER=false
      - RI_STDOUT_LOGGER=true

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
        - traefik.http.routers.redisinsight${1:+_$1}.rule=Host(\`$url_redisinsight\`) ## Dominio do RedisInsight
        - traefik.http.services.redisinsight${1:+_$1}.loadbalancer.server.port=5540
        - traefik.http.routers.redisinsight${1:+_$1}.service=redisinsight${1:+_$1}
        - traefik.http.routers.redisinsight${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.redisinsight${1:+_$1}.entrypoints=websecure
        - traefik.http.middlewares.redisinsight${1:+_$1}-auth.basicauth.users=$auth_redisinsight
        - traefik.http.routers.redisinsight${1:+_$1}.middlewares=redisinsight${1:+_$1}-auth
        - traefik.http.routers.redisinsight${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  redisinsight${1:+_$1}_data:
    external: true
    name: redisinsight${1:+_$1}_data
  redisinsight${1:+_$1}_logs:
    external: true
    name: redisinsight${1:+_$1}_logs

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do RedisInsight"
fi
STACK_NAME="redisinsight${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c redisinsight.yaml redisinsight > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do redisinsight"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redislabs/redisinsight:latest

## Usa o servico wait_redisinsight para verificar se o servico esta online
wait_stack redisinsight${1:+_$1}_redisinsight${1:+_$1}


cd dados_vps

cat > dados_redisinsight${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ REDISINSIGHT ]

Dominio do redisInsight: https://$url_redisinsight

Usuario: $user_redisinsight

Senha: $pass_redisinsight


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
echo -e "\e[32m[ REDISINSIGHT ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_redisinsight\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_redisinsight\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_redisinsight\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

## ################  ######  ####### ####### ###### ####### 
## a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--
##    a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-'     a-a-a-'     a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-
##    a-a-a-'   a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-'     a-a-a-'     a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a-a--
##    ##|   ##|  ##|##|  ##|##################|  ##|##|  ##|
##    a-a-a-   a-a-a-  a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a-
                                                                                      
