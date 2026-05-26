#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_wordpress() {

## Verifica os recursos
recursos 1 1 && continue || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_wordpress

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ## Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/2\e[0m"
    echo -en "\e[33mDigite o dominio para o Wordpress (ex: example.com ou loja.example.com): \e[0m" && read -r url_wordpress
    echo ""
    
    ## Pergunta o nome do site
    echo -e "\e[97mPasso$amarelo 2/2\e[0m"
    echo -e "$amarelo--> Use apenas letras minusculas, sem espaco ou caracteres especiais"
    echo -en "\e[33mDigite o nome do Site (ex: lojaFELSEN): \e[0m" && read -r nome_site_wordpress
    echo ""  

    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_wordpress
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do Wordpress
    echo -e "\e[33mDominio do Wordpress:\e[97m $url_wordpress\e[0m"
    echo ""
    
    ## Informacao sobre Nome do site
    echo -e "\e[33mNome do Site:\e[97m $nome_site_wordpress\e[0m"
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
echo -e "\e[97m- INICIANDO A INSTALACAO DO WORDPRESS \e[33m[1/6]\e[0m"
echo ""
sleep 1


## Ativa a funcao dados para pegar os dados da vps
dados

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO MYSQL \e[33m[2/6]\e[0m"
echo ""
sleep 1

## Cria banco de dados do site no mysql
verificar_container_mysql
    if [ $? -eq 0 ]; then
        echo "1/3 - [ OK ] - MySQL ja instalado"
        pegar_senha_mysql > /dev/null 2>&1
        echo "2/3 - [ OK ] - Copiando senha do MySQL"
        criar_banco_mysql_da_stack "$nome_site_wordpress"
        echo "3/3 - [ OK ] - Criando banco de dados"
        echo ""
    else
        ferramenta_mysql
        pegar_senha_mysql > /dev/null 2>&1
        criar_banco_mysql_da_stack "$nome_site_wordpress"
    fi

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO WORDPRESS \e[33m[3/6]\e[0m"
echo ""
sleep 1

## Criando a stack wordpress.yaml
cat > wordpress_$nome_site_wordpress.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  wordpress_$nome_site_wordpress:
    image: wordpress:latest ## Versao do Wordpress

    volumes:
      - wordpress_$nome_site_wordpress:/var/www/html
      - wordpress_${nome_site_wordpress}_php:/usr/local/etc/php

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
      - WORDPRESS_DB_NAME=$nome_site_wordpress
      - WORDPRESS_DB_HOST=mysql
      - WORDPRESS_DB_PORT=3306
      - WORDPRESS_DB_USER=root
      - WORDPRESS_DB_PASSWORD=$senha_mysql

    ##  Redis
      - WP_REDIS_HOST=wordpress_${nome_site_wordpress}_redis
      - WP_REDIS_PORT=6379
      - WP_REDIS_DATABASE=1

      - VIRTUAL_HOST=$url_wordpress

      - WP_LOCALE=pt_BR

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      labels:
        - traefik.enable=true
        - traefik.http.routers.wordpress_$nome_site_wordpress.rule=Host(\`$url_wordpress\`)
        - traefik.http.routers.wordpress_$nome_site_wordpress.entrypoints=websecure
        - traefik.http.routers.wordpress_$nome_site_wordpress.tls.certresolver=letsencryptresolver
        - traefik.http.routers.wordpress_$nome_site_wordpress.service=wordpress_$nome_site_wordpress
        - traefik.http.services.wordpress_$nome_site_wordpress.loadbalancer.server.port=80
        - traefik.http.services.wordpress_$nome_site_wordpress.loadbalancer.passHostHeader=true

## --------------------------- FELSEN --------------------------- ##

  wordpress_${nome_site_wordpress}_redis:
    image: redis:latest  ## Versao do Redis
    command: [
        "redis-server",
        "--appendonly",
        "yes",
        "--port",
        "6379"
      ]

    volumes:
      - wordpress_${nome_site_wordpress}_redis:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ## Descomente as linhas abaixo para uso externo
    #ports:
    #  - 6379:6379

    deploy:
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "1"
          memory: 1024M

## --------------------------- FELSEN --------------------------- ##

volumes:
  wordpress_$nome_site_wordpress:
    external: true
    name: wordpress_$nome_site_wordpress
  wordpress_${nome_site_wordpress}_php:
    external: true
    name: wordpress_${nome_site_wordpress}_php
  wordpress_${nome_site_wordpress}_redis:
    external: true
    name: wordpress_${nome_site_wordpress}_redis

networks:
  $nome_rede_interna: ## Nome da rede interna
    name: $nome_rede_interna ## Nome da rede interna
    external: true
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do Wordpress"
fi
STACK_NAME="wordpress_$nome_site_wordpress"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c $nome_da_stack_wordpress $nome_da_stack_wordpress_subir #> /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do Wordpress"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[4/6]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull redis:latest wordpress:latest

## Usa o servico wait_wordpress para verificar se o servico esta online
wait_stack "wordpress_$nome_site_wordpress"

## Mensagem de Passo
echo ""
echo -e "\e[97m- EDITANDO PHP.INI \e[33m[5/6]\e[0m"
echo ""
sleep 1

## Validacao de variaveis obrigatorias
if [ -z "$nome_site_wordpress" ]; then
    echo "ERRO: Variavel 'nome_site_wordpress' nao esta definida!"
    exit 1
fi

## Funcao para verificar e exibir status de comandos
verificar_comando() {
    local passo=$1
    local descricao=$2
    local status=$3
    
    if [ $status -eq 0 ]; then
        echo "$passo - [ OK ] - $descricao"
        return 0
    else
        echo "$passo - [ ERRO ] - $descricao"
        return 1
    fi
}

## Definindo caminhos
caminho_php_ini="/var/lib/docker/volumes/wordpress_${nome_site_wordpress}_php/_data/php.ini"
caminho_php_ini_prod="/var/lib/docker/volumes/wordpress_${nome_site_wordpress}_php/_data/php.ini-production"
caminho_wp_config="/var/lib/docker/volumes/wordpress_${nome_site_wordpress}/_data/wp-config.php"

## Verificando se os diretorios existem
if [ ! -d "$(dirname "$caminho_php_ini")" ]; then
    echo "ERRO: Diretorio do volume PHP nao encontrado: $(dirname "$caminho_php_ini")"
    exit 1
fi

if [ ! -d "$(dirname "$caminho_wp_config")" ]; then
    echo "ERRO: Diretorio do volume WordPress nao encontrado: $(dirname "$caminho_wp_config")"
    exit 1
fi

## Copiando arquivo php.ini-production para php.ini
if [ ! -f "$caminho_php_ini_prod" ]; then
    echo "AVISO: Arquivo php.ini-production nao encontrado. Tentando criar php.ini do zero..."
    touch "$caminho_php_ini"
else
    cp "$caminho_php_ini_prod" "$caminho_php_ini"
fi
verificar_comando "1/8" "Copiando arquivo php.ini" $? || exit 1

## Modificando configuracoes do PHP.INI
sed -i "s/^upload_max_filesize =.*/upload_max_filesize = 1024M/" "$caminho_php_ini" 2>/dev/null
if [ $? -ne 0 ]; then
    # Se a linha nao existir, adiciona ao final do arquivo
    echo "upload_max_filesize = 1024M" >> "$caminho_php_ini"
fi
verificar_comando "2/8" "Modificando upload_max_filesize para 1024M" $?

sed -i "s/^post_max_size =.*/post_max_size = 1024M/" "$caminho_php_ini" 2>/dev/null
if [ $? -ne 0 ]; then
    # Se a linha nao existir, adiciona ao final do arquivo
    echo "post_max_size = 1024M" >> "$caminho_php_ini"
fi
verificar_comando "3/8" "Modificando post_max_size para 1024M" $?

sed -i "s/^max_execution_time =.*/max_execution_time = 450/" "$caminho_php_ini" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "max_execution_time = 450" >> "$caminho_php_ini"
fi
verificar_comando "4/8" "Modificando max_execution_time para 450" $?

sed -i "s/^memory_limit =.*/memory_limit = 1024M/" "$caminho_php_ini" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "memory_limit = 1024M" >> "$caminho_php_ini"
fi
verificar_comando "5/8" "Modificando memory_limit para 1024M" $?

## Verificando se wp-config.php existe
if [ ! -f "$caminho_wp_config" ]; then
    echo "ERRO: Arquivo wp-config.php nao encontrado: $caminho_wp_config"
    exit 1
fi
verificar_comando "6/8" "Verificando arquivo wp-config.php" 0

## Adicionando configuracoes do Redis no wp-config.php
sed -i "/\/\* Add any custom values between this line and the \"stop editing\" line. \*\//i\\
define( 'WP_REDIS_HOST', 'wordpress_${nome_site_wordpress}_redis' );\n\
define( 'WP_REDIS_PORT', 6379 );\n" "$caminho_wp_config" 2>/dev/null

# Verificando se a insercao foi bem-sucedida
if grep -q "WP_REDIS_HOST" "$caminho_wp_config" 2>/dev/null; then
    verificar_comando "7/8" "Adicionando configuracoes do Redis no wp-config.php" 0
else
    verificar_comando "7/8" "Adicionando configuracoes do Redis no wp-config.php" 1
fi

## Aplicando atualizacao no servico Docker
docker service update --force "wordpress_${nome_site_wordpress}_wordpress_${nome_site_wordpress}" > /dev/null 2>&1
verificar_comando "8/8" "Aplicando atualizacao no php.ini" $?

echo ""

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[6/6]\e[0m"
echo ""
sleep 1

## Usa o servico wait_wordpress para verificar se o servico esta online
wait_stack "wordpress_$nome_site_wordpress"

docker container prune -f > /dev/null 2>&1


cd dados_vps

cat > wordpress_$nome_do_servico_wordpress <<__FELSEN_MANAGED_FILE__
[ WORDPRESS ]

Dominio do Wordpress: https://$url_wordpress

Arquivos do site: /var/lib/docker/volumes/wordpress_$nome_site_wordpress/_data

Arquivos do php: /var/lib/docker/volumes/wordpress_${nome_site_wordpress}_php/_data
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
echo -e "\e[32m[ WORDPRESS ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_wordpress\e[0m"
echo ""

echo -e "\e[33mArquivos do site:\e[97m /var/lib/docker/volumes/wordpress_$nome_site_wordpress/_data\e[0m"
echo ""

echo -e "\e[33mArquivos do php:\e[97m /var/lib/docker/volumes/wordpress_${nome_site_wordpress}_php/_data\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}
