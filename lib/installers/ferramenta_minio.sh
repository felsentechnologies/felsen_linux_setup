#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_minio() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_minio

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do
    
    ##Pergunta o Dominio do Minio
    echo -e "\e[97mPasso$amarelo 1/5\e[0m"
    echo -en "\e[33mDigite o Dominio para o Painel do MinIO (ex: minio.example.com): \e[0m" && read -r url_minio
    echo ""
    
    ##Pergunta o Dominio para o S3 do Minio
    echo -e "\e[97mPasso$amarelo 2/5\e[0m"
    echo -en "\e[33mDigite o Dominio para a API S3 do Minio(ex: s3.example.com): \e[0m" && read -r url_s3
    echo ""
    
    ##Pergunta o Usuario para o Minio
    echo -e "\e[97mPasso$amarelo 3/5\e[0m"
    echo -e "$amarelo--> Evite os caracteres especiais: \!#$ e/ou espaco"
    echo -en "\e[33mDigite um usuario para o MinIO (ex: Felsen): \e[0m" && read -r user_minio
    echo ""
    
    ##Pergunta a Senha para o Minio
    echo -e "\e[97mPasso$amarelo 4/5\e[0m"
    echo -e "$amarelo--> Minimo 8 caracteres. Use Letras MAIUSCULAS e minusculas, numero e um caractere especial @ ou _"
    echo -e "$amarelo--> Evite os caracteres especiais: \!#$"
    echo -en "\e[33mDigite uma senha para o MinIO (ex: @Senha123_): \e[0m" && read -r senha_minio
    echo ""

    ##Pergunta a Senha para o Minio
    echo -e "\e[97mPasso$amarelo 5/5\e[0m"
    echo -e "$amarelo--> 1 = Ultima Versao"
    echo -e "$amarelo--> 2 = Versao Antiga"
    echo -en "\e[33mDigite o numero da versao que deseja instalar (1 ou 2): \e[0m" && read -r minio_version_op
    echo ""
    if [ "$minio_version_op" = "1" ]; then
        minio_version="latest"
    elif [ "$minio_version_op" = "2" ]; then
        minio_version="RELEASE.2024-01-13T07-53-03Z-cpuv1"
    else
        echo -e "\e[31mOpcao invalida. Usando versao 'latest' por padrao.\e[0m"
        minio_version="latest"
    fi

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_minio
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Minio 
    echo -e "\e[33mDominio do Painel do MinIO:\e[97m $url_minio\e[0m"
    echo ""
    
    ## Informacao sobre URL para o S# do Minio 
    echo -e "\e[33mDominio da API S3:\e[97m $url_s3\e[0m"
    echo ""
    
    ## Informacao sobre Usuario do Minio
    echo -e "\e[33mUsuario do MinIO:\e[97m $user_minio\e[0m"
    echo ""    
    
    ## Informacao sobre Senha do Minio
    echo -e "\e[33mSenha do MinIO:\e[97m $senha_minio\e[0m"
    echo ""

    ## Informacao sobre Senha do Minio
    echo -e "\e[33mVersao do MinIO:\e[97m $minio_version\e[0m"
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
echo -e "\e[97m- INICIANDO A INSTALACAO DO MINIO \e[33m[1/3]\e[0m"
echo ""
sleep 1


## NADA

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO MINIO \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack minio.yaml
cat > minio${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  minio${1:+_$1}:
    image: quay.io/minio/minio:$minio_version ## Versao do MinIO
    command: server /data --console-address ":9001"

    volumes:
      - minio${1:+_$1}_data:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Dados de acesso
      - MINIO_ROOT_USER=$user_minio
      - MINIO_ROOT_PASSWORD=$senha_minio

    ##  URL do MinIO
      - MINIO_BROWSER_REDIRECT_URL=https://$url_minio ## Url do minio
      - MINIO_SERVER_URL=https://$url_s3 ## Url do s3 | Comente esta linha caso tiver erro ao fazer login

    ## " RegiAo
      - MINIO_REGION_NAME=eu-south

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        ## Console
        - traefik.http.routers.minio_public${1:+_$1}.rule=Host(\`$url_s3\`) ## Url do s3
        - traefik.http.routers.minio_public${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.minio_public${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.minio_public${1:+_$1}.loadbalancer.server.port=9000
        - traefik.http.services.minio_public${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.routers.minio_public${1:+_$1}.service=minio_public${1:+_$1}
        ## API S3
        - traefik.http.routers.minio_console${1:+_$1}.rule=Host(\`$url_minio\`) ## Url do minio
        - traefik.http.routers.minio_console${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.minio_console${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.services.minio_console${1:+_$1}.loadbalancer.server.port=9001
        - traefik.http.services.minio_console${1:+_$1}.loadbalancer.passHostHeader=true
        - traefik.http.routers.minio_console${1:+_$1}.service=minio_console${1:+_$1}

## --------------------------- FELSEN --------------------------- ##

volumes:
  minio${1:+_$1}_data:
    external: true
    name: minio${1:+_$1}_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do MinIO"
fi
sleep 1
STACK_NAME="minio${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c minio.yaml minio

#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel subir a stack do Minio"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull quay.io/minio/minio:$minio_version

## Usa o servico wait_minio para verificar se o servico esta online
wait_stack minio${1:+_$1}_minio${1:+_$1}


cd dados_vps

cat > dados_minio${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ MINIO ]

Dominio do painel do Minio: https://$url_minio

Dominio da API S3: https://$url_s3

Usuario: $user_minio

Senha: $senha_minio

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
echo -e "\e[32m[ MINIO ]\e[0m"
echo ""

echo -e "\e[33mDominio do Painel do MinIO:\e[97m https://$url_minio\e[0m"
echo ""

echo -e "\e[33mDominio da API S3:\e[97m https://$url_s3\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m $user_minio\e[0m"
echo ""  

echo -e "\e[33mSenha:\e[97m $senha_minio\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}


## ############   ########## ###############  ####### #########
## a-a-a-a-a-a-"a-a-a-a-a-a-a-- a-a-a-"a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-a-a-a-"a-a-a-
##    a-a-a-'    a-a-a-a-a-a-"a- a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'   a-a-a-'   
##    a-a-a-'     a-a-a-a-"a-  a-a-a-"a-a-a-a- a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--a-a-a-'   a-a-a-'   a-a-a-'   
##    a-a-a-'      a-a-a-'   a-a-a-'     a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-   a-a-a-'   
##    a-a-a-      a-a-a-   a-a-a-     a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-    a-a-a-   

