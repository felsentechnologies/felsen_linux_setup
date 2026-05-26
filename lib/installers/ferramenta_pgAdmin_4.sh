#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_pgAdmin_4() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_pgAdmin_4

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o PgAdmin 4 (ex: pgadmin.example.com): \e[0m" && read -r url_PgAdmin_4
    echo ""
    
    ##Pergunta o Email para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite um email para o PgAdmin 4 (ex: contato@example.com): \e[0m" && read -r user_PgAdmin_4
    echo ""
    
    ##Pergunta a Senha para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "$amarelo--> Minimo 8 caracteres. Use Letras MAIUSCULAS e minusculas, numero e um caractere especial @ ou _"
    echo -e "$amarelo--> Evite os caracteres especiais: \!#$"
    echo -en "\e[33mDigite uma senha para o usuario (ex: @Senha123_): \e[0m" && read -r pass_PgAdmin_4
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_pgAdmin_4
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do PgAdmin
    echo -e "\e[33mDominio do PgAdmin 4\e[97m $url_PgAdmin_4\e[0m"
    echo ""
    
    ## Informacao sobre email do PgAdmin
    echo -e "\e[33mEmail:\e[97m $user_PgAdmin_4\e[0m"
    echo ""
    
    ## Informacao sobre a senha do PgAdmin
    echo -e "\e[33mSenha:\e[97m $pass_PgAdmin_4\e[0m"
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
echo -e "\e[97m- INICIANDO A INSTALACAO DO PGADMIN 4 \e[33m[1/3]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO PGADMIN 4 \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack pgadmin.yaml 
cat > pgadmin${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:  

## --------------------------- FELSEN --------------------------- ##

  pgadmin${1:+_$1}:
    image: dpage/pgadmin4:latest ## Versao do PgAdmin 4

    volumes:
      - pgadmin${1:+_$1}_data:/var/lib/pgadmin

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Dados de Acesso
      - PGADMIN_DEFAULT_EMAIL=$user_PgAdmin_4
      - PGADMIN_DEFAULT_PASSWORD=$pass_PgAdmin_4

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: '1'
          memory: 1024M
      labels:
        - traefik.enable=true
        - traefik.http.routers.pgadmin${1:+_$1}.rule=Host(\`$url_PgAdmin_4\`) ## Url da Ferramenta
        - traefik.http.services.pgadmin${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.pgadmin${1:+_$1}.service=pgadmin${1:+_$1}
        - traefik.http.routers.pgadmin${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.pgadmin${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.pgadmin${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  pgadmin${1:+_$1}_data:
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
    echo "Nao foi possivel criar a stack do PgAdmin 4"
fi
STACK_NAME="pgadmin${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c pgadmin.yaml pgadmin  > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do PgAdmin 4"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull dpage/pgadmin4:latest

## Usa o servico wait_pgadmin_4 para verificar se o servico esta online
wait_stack pgadmin${1:+_$1}_pgadmin${1:+_$1}


cd dados_vps

cat > dados_pgadmin${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ PGADMIN 4 ]

Dominio do pgadmin: https://$url_PgAdmin_4

Usuario: $user_PgAdmin_4

Senha: $pass_PgAdmin_4
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
echo -e "\e[32m[ PGADMIN 4 ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_PgAdmin_4\e[0m"
echo ""

echo -e "\e[33mEmail:\e[97m $user_PgAdmin_4\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m $pass_PgAdmin_4\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ####   ### #######  ####### ####### #######  ###### ################
## a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-"a-a-a-- a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a--  
## a-a-a-'a-a-a-a--a-a-a-'a-a-a-'   a-a-a-'a-a-a-'     a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  
## a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--
## a-a-a-  a-a-a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

