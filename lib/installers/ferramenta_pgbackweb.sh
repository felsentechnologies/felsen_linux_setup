#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_pgbackweb() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_pgbackweb

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o Dominio para o PgBackWeb (ex: pgbackweb.example.com): \e[0m" && read -r url_pgbackweb
    echo ""

    ## Limpa o terminal
    clear

    ## Mostra o nome da aplicacao
    nome_pgbackweb

    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mDominio do PgBackWeb:\e[97m $url_pgbackweb\e[0m"
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
        nome_pgbackweb

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO PGBACKWEB \e[33m[1/4]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres Instalado
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

## Verifica container postgres e cria banco no postgres

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "pgbackweb${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "pgbackweb${1:+_$1}"
fi

pegar_senha_postgres > /dev/null 2>&1

echo -e "\e[97m- INSTALANDO PGBACKWEB \e[33m[3/4]\e[0m"
echo ""
sleep 1

encryptionkey_pgbackweb=$(openssl rand -hex 16)

## Criando a stack pgbackweb.yaml
cat > pgbackweb${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  pgbackweb${1:+_$1}:
    image: eduardolat/pgbackweb:latest

    volumes:
      - pgbackweb${1:+_$1}_backups:/backups #Pasta backups locais caso nao utilize Minio S3

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ## " Criptografia e SeguranAa
      - PBW_ENCRYPTION_KEY=$encryptionkey_pgbackweb #Chave criptografia
    
    ## -"i Configuracao do PostgreSQL
      - PBW_POSTGRES_CONN_STRING=postgresql://postgres:$senha_postgres@postgres:5432/pgbackweb${1:+_$1}?sslmode=disable
    
    ##  Fuso Horario
      - TZ=America/Sao_Paulo #Fuso horario

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
        - traefik.http.routers.pgbackweb${1:+_$1}.rule=Host(\`$url_pgbackweb\`) ## Url da aplicacao
        - traefik.http.services.pgbackweb${1:+_$1}.loadbalancer.server.port=8085
        - traefik.http.routers.pgbackweb${1:+_$1}.service=pgbackweb${1:+_$1}
        - traefik.http.routers.pgbackweb${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.pgbackweb${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.pgbackweb${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  pgbackweb${1:+_$1}_backups:
    external: true
    name: pgbackweb${1:+_$1}_backups

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do pgbackweb"
fi

STACK_NAME="pgbackweb${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c pgbackweb.yaml pgbackweb > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do pgbackweb"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull eduardolat/pgbackweb:latest

## Usa o servico wait_stack para verificar se o servico esta online
wait_stack pgbackweb${1:+_$1}_pgbackweb${1:+_$1}


cd dados_vps

cat > dados_pgbackweb${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ PGBACKWEB ]

Dominio do PgBackWeb: https://$url_pgbackweb
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
echo -e "\e[32m[ PGBACKWEB ]\e[0m"
echo ""

echo -e "\e[33mDominio do pgbackweb:\e[97m https://$url_pgbackweb\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m Precisa de criar no PgBackWeb\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m Precisa de criar no PgBackWeb\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

##      ##########################
##      a-a-a-'a-a-a-'a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a-a-a-a-'
##      ##|##|   ##|   ##########|
## a-a-   a-a-a-'a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-'a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-'a-a-a-'
##  a-a-a-a-a-a- a-a-a-   a-a-a-   a-a-a-a-a-a-a-a-a-a-a-

