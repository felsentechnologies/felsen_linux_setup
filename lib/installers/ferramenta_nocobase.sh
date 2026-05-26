#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_nocobase() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_nocobase
## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/4\e[0m"
    echo -en "\e[33mDigite o dominio para o Nocobase (ex: nocobase.example.com): \e[0m" && read -r url_nocobase
    echo ""
    
    ##Pergunta o Email para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/4\e[0m"
    echo -en "\e[33mDigite um email para o Nocobase (ex: contato@example.com): \e[0m" && read -r mail_nocobase
    echo ""
    
    ##Pergunta um Usuario para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/4\e[0m"
    echo -en "\e[33mDigite um nome de usuario para o Nocobase (ex: Felsen): \e[0m" && read -r user_nocobase
    echo ""
    
    ##Pergunta a Senha para a ferramenta
    echo -e "\e[97mPasso$amarelo 4/4\e[0m"
    echo -e "$amarelo--> Minimo 8 caracteres. Use Letras MAIUSCULAS e minusculas, numero e um caractere especial @ ou _"
    echo -e "$amarelo--> Evite os caracteres especiais: \!#$"
    echo -en "\e[33mDigite uma senha para o usuario (ex: @Senha123_): \e[0m" && read -r pass_nocobase
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_nocobase
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Nocobase
    echo -e "\e[33mDominio do Nocobase:\e[97m $url_nocobase\e[0m"
    echo ""
    
    ## Informacao sobre Email do Nocobase
    echo -e "\e[33mEmail:\e[97m $mail_nocobase\e[0m"
    echo ""
    
    ## Informacao sobre Usuario do Nocobase
    echo -e "\e[33mUsuario:\e[97m $user_nocobase\e[0m"
    echo ""
    
    ## Informacao sobre Senha do Nocobase
    echo -e "\e[33mSenha:\e[97m $pass_nocobase\e[0m"
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
echo -e "\e[97m- INICIANDO A INSTALACAO DO NOCOBASE \e[33m[1/4]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/4]\e[0m"
echo ""
sleep 1

## Cansei ja de explicar o que isso faz kkkk
verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "nocobase${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "nocobase${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO NOCOBASE \e[33m[3/4]\e[0m"
echo ""
sleep 1

## Criando uma Encryption Key Aleatoria
nocobase_key=$(openssl rand -hex 16)
nocobase_encryption=$(openssl rand -hex 16)

## Criando a stack nocobase.yaml
cat > nocobase${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  nocobase${1:+_$1}:
    image: nocobase/nocobase:latest ## Versao do Nocobase

    volumes:
      - nocobase${1:+_$1}_storage:/app/nocobase/storage

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracao da Conta
      - INIT_ROOT_EMAIL=$mail_nocobase
      - INIT_ROOT_PASSWORD=$pass_nocobase
      - INIT_ROOT_NICKNAME=$user_nocobase
      - INIT_ROOT_USERNAME=$user_nocobase
      - INIT_LANG=pt-BR

    ##  Dados do Postgres
      - DB_DIALECT=postgres
      - DB_HOST=postgres
      - DB_DATABASE=nocobase${1:+_$1}
      - DB_USER=postgres
      - DB_PASSWORD=$senha_postgres

    ##  Paths de URL
      - LOCAL_STORAGE_BASE_URL=/storage/uploads
      - API_BASE_PATH=/api/

    ## " Encryption Key
      - APP_KEY=$nocobase_key
      - ENCRYPTION_FIELD_KEY=$nocobase_encryption

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
        - traefik.http.routers.nocobase${1:+_$1}.rule=Host(\`$url_nocobase\`) ## Url da aplicacao
        - traefik.http.services.nocobase${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.nocobase${1:+_$1}.service=nocobase${1:+_$1}
        - traefik.http.routers.nocobase${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.nocobase${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.nocobase${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  nocobase${1:+_$1}_storage:
    external: true

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Nocobase"
fi
STACK_NAME="nocobase${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c nocobase.yaml nocobase > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Nocobase"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/4]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull nocobase/nocobase:latest

## Usa o servico wait_stack "nocobase" para verificar se o servico esta online
wait_stack nocobase${1:+_$1}_nocobase${1:+_$1}


cd dados_vps

cat > dados_nocobase<<__FELSEN_MANAGED_FILE__
[ NOCOBASE ]

Dominio do Nocobase: https://$url_nocobase

Email: $mail_nocobase

Usuario: $user_nocobase

Senha: $pass_nocobase
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
echo -e "\e[32m[ NOCOBASE ]\e[0m"
echo ""
echo -e "\e[33mDominio:\e[97m https://$url_nocobase\e[0m"
echo ""
echo -e "\e[33mEmail:\e[97m $mail_nocobase\e[0m"
echo ""
echo -e "\e[33mUsuario:\e[97m $user_nocobase\e[0m"
echo ""
echo -e "\e[33mSenha:\e[97m $pass_nocobase\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  ####### ################ ####### ########################
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--
## a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-"a-a-a-a- a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-'     a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a-'
## a-a-a-a-a-a-a-  a-a-a-a-a-a-a-    a-a-a-   a-a-a-     a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-
                                                                  
