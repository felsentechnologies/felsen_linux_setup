#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_wisemapping() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_wisemapping

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/1\e[0m"
    echo -en "\e[33mDigite o dominio para o WiseMapping (ex: wisemapping.example.com): \e[0m" && read -r url_wisemapping
    echo ""

    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_wisemapping
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do wisemapping
    echo -e "\e[33mDominio do WiseMapping:\e[97m $url_wisemapping\e[0m"
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
        nome_wisemapping

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO WISEMAPPING \e[33m[1/5]\e[0m"
echo ""
sleep 1


## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO/INSTALANDO POSTGRES \e[33m[2/5]\e[0m"
echo ""
sleep 1

## Aqui vamos fazer uma verificacao se ja existe Postgres
## Se tiver ele vai criar um banco de dados no postgres ou perguntar se deseja apagar o que ja existe e criar outro

verificar_container_postgres
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Postgres ja instalado"
    pegar_senha_postgres > /dev/null 2>&1
    echo "2/3 - [ OK ] - Copiando senha do Postgres"
    criar_banco_postgres_da_stack "wisemapping${1:+_$1}"
    echo "3/3 - [ OK ] - Criando banco de dados"
    echo ""
else
    ferramenta_postgres
    pegar_senha_postgres > /dev/null 2>&1
    criar_banco_postgres_da_stack "wisemapping${1:+_$1}"
fi

## Mensagem de Passo
echo -e "\e[97m- CRIANDO ARQUIVOS DO WISEMAPPING \e[33m[3/5]\e[0m"
echo ""
sleep 1

sudo mkdir -p /root/wisemapping${1:+_$1}
if [ $? -eq 0 ]; then
    echo "1/3 - [ OK ] - Criando diretorio Wisemapping${1:+_$1}"
else
    echo "1/3 - [ OFF ] - Criando diretorio Wisemapping${1:+_$1}"
    echo "Nao foi criar o diretorio"
fi

cd

cd wisemapping${1:+_$1}

jwt_secret=$(openssl rand -hex 32)

cat > app.yml <<__FELSEN_MANAGED_FILE__
spring:
  main:
    allow-circular-references: true
  datasource:
    url: jdbc:postgresql://postgres:5432/wisemapping${1:+_$1}?stringtype=unspecified
    username: postgres
    password: $senha_postgres
    driver-class-name: org.postgresql.Driver
    type: com.zaxxer.hikari.HikariDataSource
    hikari:
      pool-name: HikariPool-WiseMapping
      minimum-idle: 5
      maximum-pool-size: 20
      idle-timeout: 300000
      max-lifetime: 1800000
      connection-timeout: 30000
      auto-commit: false
      transaction-isolation: TRANSACTION_READ_COMMITTED
      leak-detection-threshold: 60000
      data-source-properties:
        prepareThreshold: 0
        # PostgreSQL uses prepared statements by default, prepareThreshold=0 
        # means always use prepared statements (cached automatically)
  jpa:
    hibernate:
      ddl-auto: none
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        default_batch_fetch_size: 200
        format_sql: false
        # Fix for @Lob byte[] mapping to BYTEA in PostgreSQL
        jdbc:
          lob:
            non_contextual_creation: true
          use_streams_for_binary: true
        # Enable second-level cache (L2) for entity caching across sessions
        cache:
          use_second_level_cache: true
          use_query_cache: true
          region:
            factory_class: org.hibernate.cache.jcache.JCacheRegionFactory
        # Configure JCache provider (EHCache)
        jakarta:
          cache:
            provider: org.ehcache.jsr107.EhcacheCachingProvider
            uri: classpath:ehcache.xml
  sql:
    init:
      platform: postgresql
      mode: always
      schema-locations: classpath:schema-postgresql.sql
      data-locations: classpath:data-postgresql.sql
      continue-on-error: false
  mail:
    host: localhost
    port: 25
    test-connection: false

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
      base-path: /actuator
  endpoint:
    health:
      show-details: when-authorized
      probes:
        enabled: true
  metrics:
    tags:
      application: wisemapping-api
      environment: production
    export:
      prometheus:
        enabled: true
        step: 60s

# Application configuration
app:
  site:
    ui-base-url: https://$url_wisemapping
    api-base-url: https://$url_wisemapping
  admin:
    user: admin@wisemapping.org
  jwt:
    secret: $jwt_secret
    expirationMin: 10080
  mail:
    enabled: false
    sender-email: noreply@wisemapping.org
    support-email: support@wisemapping.org

# Server configuration
server:
  tomcat:
    remoteip:
      remote-ip-header: x-forwarded-for
      protocol-header: x-forwarded-proto
      port-header: x-forwarded-port

# Logging configuration
logging:
  level:
    root: INFO
    com.wisemapping: \${LOG_LEVEL_WISEMAPPING:-INFO}
    org.springframework: WARN
    org.hibernate: WARN
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "2/3 - [ OK ] - Criando arquivo application.yml"
else
    echo "2/3 - [ OFF ] - Criando arquivo application.yml"
    echo "Nao foi criar o arquivo application.yml"
fi

cat > nginx.conf <<__FELSEN_MANAGED_FILE__
# Detect HTTPS from Traefik's X-Forwarded-Proto header
# When behind Traefik, the connection to Nginx is HTTP, but the original request was HTTPS
map \$http_x_forwarded_proto \$forwarded_scheme {
  default \$scheme;
  https https;
}

# Use forwarded scheme if available, otherwise use default scheme
map \$forwarded_scheme \$final_scheme {
  default \$forwarded_scheme;
  "" \$scheme;
}

server {
  listen 80;
  gzip on;
  charset UTF-8;
  server_name _;
  
  # Replace <base> tag with absolute URL at runtime
  # Use \$final_scheme to correctly detect HTTPS when behind Traefik
  sub_filter '<base>' '<base href="\$final_scheme://\$http_host/">';
  sub_filter_once on;

  # Frontend routes
  location / {
    root /usr/share/nginx/html;
    try_files \$uri /index.html;
    
    # Add security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
  }

  location /c/ {
    try_files \$uri /usr/share/nginx/html/index.html;
    
    # Add security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
  }

  # Backend API proxy - intercept config endpoint to rewrite URLs with actual port
  location /api/restful/app/config {
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$final_scheme;
    proxy_set_header X-Forwarded-Host \$http_host;
    proxy_set_header X-NginX-Proxy true;
    proxy_pass http://localhost:8080/api/restful/app/config;
    proxy_ssl_session_reuse off;
    proxy_set_header Host \$http_host;
    proxy_cache_bypass \$http_upgrade;
    proxy_redirect off;
    
    # Rewrite apiBaseUrl and uiBaseUrl in JSON response to use correct scheme
    sub_filter '"apiBaseUrl":"http://localhost:8080"' '"apiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter '"apiBaseUrl":"http://localhost:3000"' '"apiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter '"apiBaseUrl":"https://localhost:8080"' '"apiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter '"apiBaseUrl":"https://localhost:3000"' '"apiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter '"uiBaseUrl":"http://localhost:3000"' '"uiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter '"uiBaseUrl":"http://localhost:8080"' '"uiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter '"uiBaseUrl":"https://localhost:3000"' '"uiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter '"uiBaseUrl":"https://localhost:8080"' '"uiBaseUrl":"\$final_scheme://\$http_host"';
    sub_filter_once off;  # Replace all occurrences
    sub_filter_types application/json;
  }

  # Backend API proxy - all other API endpoints
  location /api/ {
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto \$final_scheme;
    proxy_set_header X-Forwarded-Host \$http_host;
    proxy_set_header X-NginX-Proxy true;
    proxy_pass http://localhost:8080/api/;
    proxy_ssl_session_reuse off;
    proxy_set_header Host \$http_host;
    proxy_cache_bypass \$http_upgrade;
    proxy_redirect off;
    
    # Increase timeouts for long-running requests
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
  }

  # Health check endpoint
  location /health {
    access_log off;
    return 200 "healthy\n";
    add_header Content-Type text/plain;
  }
}
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "3/3 - [ OK ] - Criando arquivo nginx.conf"
else
    echo "3/3 - [ OFF ] - Criando arquivo nginx.conf"
    echo "Nao foi criar o arquivo nginx.conf"
fi
echo ""

cd

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO WISEMAPPING \e[33m[4/5]\e[0m"
echo ""
sleep 1

## Criando a stack wisemapping.yaml
cat > wisemapping${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  wisemapping${1:+_$1}:
    image: wisemapping/wisemapping:latest

    volumes:
      - wisemapping${1:+_$1}_db:/var/lib/wisemapping/db
      - /root/wisemapping${1:+_$1}/app.yml:/app/config/application.yml:z,ro
      - /root/wisemapping${1:+_$1}/nginx.conf:/etc/nginx/http.d/default.conf:z,ro

    networks:
      - $nome_rede_interna ## Nome da rede interna

    environment:
    ##  Configuracoes de Performance (Java)
      - JAVA_OPTS=Xmx2048m -Xms1024m -XX:+UseG1GC -XX:MaxGCPauseMillis=200
    
    ## Configuracoes da Aplicacao
      - SPRING_PROFILES_ACTIVE=production
      - TZ=America/Sao_Paulo
      - SPRING_CONFIG_ADDITIONAL_LOCATION=optional:file:/app/config/
    
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
        - traefik.http.routers.wisemapping${1:+_$1}.rule=Host(\`$url_wisemapping\`)
        - traefik.http.services.wisemapping${1:+_$1}.loadbalancer.server.port=80
        - traefik.http.routers.wisemapping${1:+_$1}.service=wisemapping${1:+_$1}
        - traefik.http.routers.wisemapping${1:+_$1}.tls.certresolver=letsencryptresolver
        - traefik.http.routers.wisemapping${1:+_$1}.entrypoints=websecure
        - traefik.http.routers.wisemapping${1:+_$1}.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  wisemapping${1:+_$1}_db:
    external: true
    name: wisemapping${1:+_$1}_db
    
networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do wisemapping"
fi
STACK_NAME="wisemapping${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c wisemapping.yaml wisemapping > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do wisemapping"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[5/5]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull wisemapping/wisemapping:latest

## Usa o servico wait_wisemapping para verificar se o servico esta online
wait_stack wisemapping${1:+_$1}_wisemapping${1:+_$1}

sleep 30


cd dados_vps

cat > dados_wisemapping${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ WISEMAPPING ]

Dominio do WiseMapping: https://$url_wisemapping

Email do usuario Admin: admin@wisemapping.org

Senha do usuario Admin: testAdmin123
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
echo -e "\e[32m[ WISEMAPPING ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_wisemapping\e[0m"
echo ""

echo -e "\e[33mEmail do usuario Admin:\e[97m admin@wisemapping.org\e[0m"
echo ""

echo -e "\e[33mSenha do usuario Admin:\e[97m testAdmin123\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## ###########   ### #######      ###### ###
## a-a-a-"a-a-a-a-a-a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a--    a-a-a-"a-a-a-a-a--a-a-a-'
## ######  ##|   ##|##|   ##|    #######|##|
## a-a-a-"a-a-a-  a-a-a-a-- a-a-a-"a-a-a-a-'   a-a-a-'    a-a-a-"a-a-a-a-a-'a-a-a-'
## a-a-a-a-a-a-a-a-- a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-"a-    a-a-a-'  a-a-a-'a-a-a-'
## a-a-a-a-a-a-a-a-  a-a-a-a-a-   a-a-a-a-a-a-a-     a-a-a-  a-a-a-a-a-a-
##                                          
                                         
