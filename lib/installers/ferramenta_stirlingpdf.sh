#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_stirlingpdf() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Ativa a funcao dados para pegar os dados da vps
dados

## Mostra o nome da aplicacao
nome_stirlingpdf

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    echo -en "\e[33mDigite o dominio para o Stirling PDF (ex: stirlingpdf.example.com): \e[0m" && read -r url_stirlingpdf
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    echo -en "\e[33mDigite o nome para o App (ex: FELSENPDF): \e[0m" && read -r name_stirlingpdf
    echo ""

    ##Pergunta o Dominio para a ferramenta
    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -en "\e[33mDigite uma descricao para o App (ex: Meu app de PDF): \e[0m" && read -r desc_stirlingpdf
    echo ""
    
    ## Limpa o terminal
    clear
    
    ## Mostra o nome da aplicacao
    nome_stirlingpdf
    
    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info
    
    ## Informacao sobre URL do stirlingpdf
    echo -e "\e[33mDominio do Stirling PDF:\e[97m $url_stirlingpdf\e[0m"
    echo ""

    ## Informacao sobre URL do stirlingpdf
    echo -e "\e[33mNome do App:\e[97m $name_stirlingpdf\e[0m"
    echo ""

    ## Informacao sobre URL do stirlingpdf
    echo -e "\e[33mDescricao do App:\e[97m $desc_stirlingpdf\e[0m"
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
        nome_stirlingpdf

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO STIRLING PDF \e[33m[1/3]\e[0m"
echo ""
sleep 1


## Nadaaaaa

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO STIRLING PDF \e[33m[2/3]\e[0m"
echo ""
sleep 1

## Criando a stack stirlingpdf.yaml
cat > stirlingpdf${1:+_$1}.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"

services:

## --------------------------- FELSEN --------------------------- ##

  stirlingpdf${1:+_$1}_backend:
    image: stirlingtools/stirling-pdf:latest ## Versao da aplicacao
    
    volumes:
      - stirlingpdf${1:+_$1}_backend_data:/usr/share/tessdata
      - stirlingpdf${1:+_$1}_backend_config:/configs
      - stirlingpdf${1:+_$1}_backend_logs:/logs
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ## i SeguranAa e AutenticaAAo
      - SECURITY_ENABLELOGIN=true
      - DOCKER_ENABLE_SECURITY=false
      - DISABLE_ADDITIONAL_FEATURES=false
      
    ##  Branding e Interface
      - UI_APPNAME=$name_stirlingpdf
      - UI_APPNAMENAVBAR=$name_stirlingpdf
      - UI_HOMEDESCRIPTION=$desc_stirlingpdf
      # - UI_LOGOSTYLE=classic
      # - UI_LANGUAGES=
      
    ## Configuracoes do Sistema
      - SYSTEM_DEFAULTLOCALE=pt_BR
      - SYSTEM_MAXFILESIZE=100
      - SYSTEM_GOOGLEVISIBILITY=false
      - METRICS_ENABLED=true
      
    ##  Idiomas e OCR
      - LANGS=en_GB,en_US,ar_AR,de_DE,fr_FR,es_ES,zh_CN,zh_TW,ca_CA,it_IT,sv_SE,pl_PL,ro_RO,ko_KR,pt_BR,ru_RU,el_GR,hi_IN,hu_HU,tr_TR,id_ID
      # - TESSERACT_LANGS=eng,por,spa,fra,deu
      
    ##  Docker e PermissAes
      - PUID=1000
      - PGID=1000
      - UMASK=022
      
    ##  Dados do SMTP (opicional)
      - MAIL_ENABLED=false
      - MAIL_ENABLEINVITES=false
      - MAIL_HOST=smtp.example.com
      - MAIL_PORT=587
      - MAIL_USERNAME=
      - MAIL_PASSWORD=
      - MAIL_FROM=
      
    ## a Premium/Enterprise
      # - PREMIUM_KEY=
      # - PREMIUM_ENABLED=false
      # - PREMIUM_PROFEATURES_SSOAUTOLOGIN=false
      # - PREMIUM_ENTERPRISEFEATURES_AUDIT_ENABLED=true
      # - PREMIUM_ENTERPRISEFEATURES_AUDIT_LEVEL=2
      # - PREMIUM_ENTERPRISEFEATURES_AUDIT_RETENTIONDAYS=90
    
    ##  Modo
      - MODE=BACKEND
    
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

  stirlingpdf${1:+_$1}_frontend:
    image: stirlingtools/stirling-pdf:latest ## Versao do frontend
    
    volumes:
      - stirlingpdf${1:+_$1}_frontend_data:/usr/share/nginx/html
    
    networks:
      - $nome_rede_interna ## Nome da rede interna
    
    environment:
    ##  Backend e API
      - BACKEND_URL=http://stirlingpdf${1:+_$1}_backend:8080
    
    ## IntegraAAes Google Drive
      # - VITE_GOOGLE_DRIVE_CLIENT_ID=
      # - VITE_GOOGLE_DRIVE_API_KEY=
      # - VITE_GOOGLE_DRIVE_APP_ID=
    
    ##  Modo
      - MODE=FRONTEND
    
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: "0.5"
          memory: 512M
      labels:
        - traefik.enable=true
        - traefik.http.routers.stirlingpdf${1:+_$1}_frontend.rule=Host(\`$url_stirlingpdf\`) ## Url da aplicacao
        - traefik.http.services.stirlingpdf${1:+_$1}_frontend.loadbalancer.server.port=8080
        - traefik.http.routers.stirlingpdf${1:+_$1}_frontend.service=stirlingpdf${1:+_$1}_frontend
        - traefik.http.routers.stirlingpdf${1:+_$1}_frontend.tls.certresolver=letsencryptresolver
        - traefik.http.routers.stirlingpdf${1:+_$1}_frontend.entrypoints=websecure
        - traefik.http.routers.stirlingpdf${1:+_$1}_frontend.tls=true

## --------------------------- FELSEN --------------------------- ##

volumes:
  stirlingpdf${1:+_$1}_backend_data:
    external: true
    name: stirlingpdf${1:+_$1}_backend_data
  stirlingpdf${1:+_$1}_backend_config:
    external: true
    name: stirlingpdf${1:+_$1}_backend_config
  stirlingpdf${1:+_$1}_backend_logs:
    external: true
    name: stirlingpdf${1:+_$1}_backend_logs
  stirlingpdf${1:+_$1}_frontend_data:
    external: true
    name: stirlingpdf${1:+_$1}_frontend_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/10 - [ OK ] - Criando Stack"
else
    echo "1/10 - [ OFF ] - Criando Stack"
    echo "Nao foi possivel criar a stack do stirlingpdf"
fi
STACK_NAME="stirlingpdf${1:+_$1}"
stack_editavel # > /dev/null 2>&1
#docker stack deploy --prune --resolve-image always -c stirlingpdf.yaml stirlingpdf > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    echo "2/2 - [ OK ] - Deploy Stack"
#else
#    echo "2/2 - [ OFF ] - Deploy Stack"
#    echo "Nao foi possivel Subir a stack do stirlingpdf"
#fi

## Mensagem de Passo
echo -e "\e[97m- VERIFICANDO SERVICO \e[33m[3/3]\e[0m"
echo ""
sleep 1

## Baixando imagens:
pull stirlingtools/stirling-pdf:latest

## Usa o servico wait_stirlingpdf para verificar se o servico esta online
wait_stack stirlingpdf${1:+_$1}_stirlingpdf${1:+_$1}_backend stirlingpdf${1:+_$1}_stirlingpdf${1:+_$1}_frontend


cd dados_vps

cat > dados_stirlingpdf${1:+_$1} <<__FELSEN_MANAGED_FILE__
[ STIRLING PDF ]

Dominio do stirlingpdf: https://$url_stirlingpdf

Usuario: admin

Senha: stirling

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
echo -e "\e[32m[ STIRLING PDF ]\e[0m"
echo ""

echo -e "\e[33mDominio:\e[97m https://$url_stirlingpdf\e[0m"
echo ""

echo -e "\e[33mUsuario:\e[97m admin\e[0m"
echo ""

echo -e "\e[33mSenha:\e[97m stirling\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao

}

##  ##########     ### ##########  ######  ### ####### ###   ###################
## a-a-a-"a-a-a-a-a-a-a-a-'     a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-' a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-"a-a-a-a-a-a--a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-'     a-a-a-'     a-a-a-'a-a-a-'     a-a-a-a-a-a-"a- a-a-a-a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a--  
## a-a-a-'     a-a-a-'     a-a-a-'a-a-a-'     a-a-a-"a-a-a-a-- a-a-a-"a-a-a-a-a-'a-a-a-'   a-a-a-'a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'a-a-a-"a-a-a-  
## a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a--a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a--a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a-a-a--
##  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-  a-a-a- a-a-a-a-a-a-a-  a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-
                                                                                      
