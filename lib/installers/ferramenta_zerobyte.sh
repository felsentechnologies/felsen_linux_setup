#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_zerobyte() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_zerobyte

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o ZeroByte (ex: zerobyte.example.com): \e[0m" && read -r url_zerobyte
    echo ""

    ## Limpa o terminal
    clear

    ## Mostra o nome da aplicacao
    nome_zerobyte

    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do ZeroByte:\e[97m $url_zerobyte\e[0m"
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
        nome_zerobyte

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO ZEROBYTE \e[33m[1/3]\e[0m"
echo ""
sleep 1


echo -e "\e[97m- INSTALANDO ZEROBYTE \e[33m[2/3]\e[0m"
echo ""
sleep 1

key_zerobyte=$(openssl rand -hex 32)

## Criando a stack zerobyte.yaml
cat > zerobyte${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  zerobyte${1:+_$1}:
    image: ghcr.io/nicotsx/zerobyte:latest

    volumes:
      - zerobyte${1:+_$1}_data:/var/lib/zerobyte
      - /etc/localtime:/etc/localtime:ro
      - /var/lib/docker/volumes:/docker/volumes:rw ## Permite acessar os volumes do Docker
      - /root:/root:rw ## Permite acessar o /root
    
    ## Permissoes Extras
    #cap_add:
    #  - SYS_ADMIN
    #devices:
    #  - /dev/fuse:/dev/fuse
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  Base URL
      - BASE_URL=https://$url_zerobyte

    ## " App Secret
      - APP_SECRET=$key_zerobyte

    ## Ambiente da Aplicacao
      - NODE_ENV=production
    
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
        - traefik.http.routers.zerobyte${1:+_$1}.rule=Host(\`$url_zerobyte\`)
        - traefik.http.services.zerobyte${1:+_$1}.loadbalancer.server.port=4096
        - traefik.http.routers.zerobyte${1:+_$1}.service=zerobyte${1:+_$1}
        - traefik.http.routers.zerobyte${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.zerobyte${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.zerobyte${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  zerobyte${1:+_$1}_data:
    external: true
    name: zerobyte${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna

__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do ZeroByte"
fi

STACK_NAME="zerobyte${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c zerobyte.yaml zerobyte > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do zerobyte"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull ghcr.io/nicotsx/zerobyte:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack zerobyte${1:+_$1}_zerobyte${1:+_$1}


cd dados_vps

cat > dados_zerobyte${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ ZEROBYTE ]

Dominio do ZeroByte: https://$url_zerobyte

Usuario: Precisa de criar no primeiro acesso do ZeroByte

Senha: Precisa de criar no primeiro acesso do ZeroByte
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
echo -e "\e[32m[ ZEROBYTE ]\e[0m"
echo ""

echo -e "\e[33mDominio do ZeroByte:\e[97m https://$url_zerobyte\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa de criar no primeiro acesso do ZeroByte\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar no primeiro acesso do ZeroByte\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########   ### ####### ###     ###   ############### ####### ####   ###     #######  ####### 
## a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-a-a--  a-a-a-'    a-a-a-"a-a-a-a-a- a-a-a-"a-a-a-a-a-a--
## ######  ##|   ##|##|   ##|##|     ##|   ##|   ##|   ##|##|   ##|###### ##|    ##|  ######|   ##|
## a-a-a-"a-a-a-  a-a-a-a-- a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-'a-a-a-a--a-a-a-'    a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'
## a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-' a-a-a-a-a-a-'    a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-
## a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-a-a-a-a- a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-    a-a-a-   a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-     a-a-a-a-a-a-a-  a-a-a-a-a-a-a- 

