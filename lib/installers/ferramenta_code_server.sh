#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_code_server() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_code_server

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o Dominio para o CodeServer (ex: code-server.example.com): \e[0m" && read -r url_code_server
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite a senha Admin do CodeServer (ex: @Senha123_): \e[0m" && read -r pass_admin_code_server
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite a senha SuperAdmin do CodeServer (ex: @SuperSenha123_): \e[0m" && read -r pass_super_admin_code_server
    echo ""

    ## Limpa o terminal
    clear

    ## Mostra o nome da aplicacao
    nome_code_server

    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do CodeServer:\e[97m $url_code_server\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha Admin do CodeServer:\e[97m $pass_admin_code_server\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha SuperAdmin do CodeServer:\e[97m $pass_super_admin_code_server\e[0m"
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
        nome_code_server

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO CODE SERVER \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO CODE SERVER \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack code_server.yaml
cat > code_server${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  code_server${1:+_$1}:
    image: lscr.io/linuxserver/code-server:latest

    volumes:
      - code_server${1:+_$1}_config:/config

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Permissoes e Identidade do Usuario
      - PUID=1000
      - PGID=1000
    
    ##  Fuso Horario
      - TZ=America/Sao_Paulo
    
    ## " Credenciais e Acesso
      - PASSWORD=$pass_admin_code_server
      - SUDO_PASSWORD=$pass_super_admin_code_server
    
    ##  Configuracoes de Rede e Proxy
      - PROXY_DOMAIN=$url_code_server
    
    ## " Configuracoes de Workspace
      - DEFAULT_WORKSPACE=/config/workspace
    
    ##  Configuracoes da Aplicacao
      - PWA_APPNAME=code-server
    
    ##  Extensoes e Mods do Container
      - DOCKER_MODS=linuxserver/mods:code-server-nodejs|linuxserver/mods:code-server-npmglobal ## Outros Mods: https://mods.linuxserver.io/?mod=code-server
    
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
        - traefik.http.routers.code_server${1:+_$1}.rule=Host(\`$url_code_server\`)
        - traefik.http.services.code_server${1:+_$1}.loadbalancer.server.port=8443
        - traefik.http.routers.code_server${1:+_$1}.service=code_server${1:+_$1}
        - traefik.http.routers.code_server${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.code_server${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.code_server${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  code_server${1:+_$1}_config:
    external: true
    name: code_server${1:+_$1}_config

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do code_server"
fi

STACK_NAME="code_server${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c code_server.yaml code_server > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do code_server"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull lscr.io/linuxserver/code-server:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack code_server${1:+_$1}_code_server${1:+_$1}


cd dados_vps

cat > dados_code_server${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ CODE SERVER ]

Dominio do Code Server: https://$url_code_server

Senha Admin: $pass_admin_code_server

Senha SuperAdmin: $pass_super_admin_code_server
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
echo -e "\e[32m[ CODE SERVER ]\e[0m"
echo ""

echo -e "\e[33mDominio do code_server:\e[97m https://$url_code_server\e[0m"
echo ""

echo -e "\e[33mSenha admin:\e[97m $pass_admin_code_server\e[0m"
echo ""

echo -e "\e[33mSenha SuperAdmin:\e[97m $pass_super_admin_code_server\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  ###### ####### #######  ###### 
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'
## a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'
## ##|     ##|  ##|##|     ##|  ##|##|  ##|
## a-a-a-     a-a-a-  a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-  a-a-a-

