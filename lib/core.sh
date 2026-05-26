#!/usr/bin/env bash
# Shared runtime helpers for Felsen Linux Setup.
# Application and command implementations live in lib/installers/*.sh.

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

versao() {
echo -e "                                   \e[97mVersao do Felsen Linux Setup: \e[32mv. 2.8.0\e[0m                                  "
echo -e "\e[32mexample.com/comunidade      \e[97m<----- Grupos no WhatsApp ----->     \e[32mexample.com/comunidade\e[0m"
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Cores do Setup

amarelo="\e[33m"
verde="\e[32m"
branco="\e[97m"
bege="\e[93m"
vermelho="\e[91m"
reset="\e[0m"

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

menu_instalador="1"

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

home_directory="$HOME"
dados_vps="${home_directory}/dados_vps/dados_vps"

dados() {
    nome_servidor=$(grep "Nome do Servidor:" "$dados_vps" | awk -F': ' '{print $2}')
    nome_rede_interna=$(grep "Rede interna:" "$dados_vps" | awk -F': ' '{print $2}')
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Licenca do Setup

## copia
direitos_setup() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=  $branco Este auto instalador foi desenvolvido para auxiliar na instalacao das principais aplicacoes $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco  disponiveis no mercado open source. Ja deixo todos os creditos aos desenvolvedores de cada $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco aplicacao disponiveis aqui. Este Setup e licenciado sob a Licenca MIT (MIT). Voce pode usar, $amarelo =\e[0m"
    echo -e "$amarelo=  $branco  copiar, modificar, integrar, publicar, distribuir e/ou vender copias dos produtos finais,  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco   mas deve sempre declarar que Felsen (contato@example.com) e o autor original  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco           destes codigos e atribuir um link para            $amarelo  =\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

direitos_instalador() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=  $branco Este auto instalador foi desenvolvido para auxiliar na instalacao das principais aplicacoes $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco  disponiveis no mercado open source. Ja deixo todos os creditos aos desenvolvedores de cada $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco aplicacao disponiveis aqui. Este Setup e licenciado sob a Licenca MIT (MIT). Voce pode usar, $amarelo =\e[0m"
    echo -e "$amarelo=  $branco  copiar, modificar, integrar, publicar, distribuir e/ou vender copias dos produtos finais,  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco   mas deve sempre declarar que Felsen (contato@example.com) e o autor original  $amarelo  =\e[0m"
    echo -e "$amarelo=  $branco           destes codigos e atribuir um link para            $amarelo  =\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
    read -p "Ao digitar Y voce aceita e concorda com as orientacoes passadas acima (Y/N): " choice
    while true; do
        case $choice in
            Y|y)
                return
                ;;
            N|n)
                clear
                nome_finalizado
                echo "Que pena que voce nao concorda, entao estarei encerrando o instalador. Ate mais."
                sleep 2
                clear
                exit 1
                ;;
            *)
                clear
                erro_msg
                echo ""
                echo ""
                echo "Por favor, digite apenas Y ou N."
                sleep 2
                clear
                nome_instalador
                direitos_setup
                ;;
        esac
        read -p "Ao digitar Y voce aceita e concorda com as orientacoes passadas acima (Y/N): " choice
    done
}

## Credenciais Portainerv2.5.0+
info_credenciais(){ 
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=  $branco A partir da versao 2.5.0 deste Setup foi implementado uma funcao para realizar deploy dentro $amarelo =\e[0m"
    echo -e "$amarelo=  $branco   do proprio portainer atraves de uma requisicao api. Para que esta nova funcao funcione em  $amarelo =\e[0m"
    echo -e "$amarelo=  $branco suas proximas instalacoes, voce precisara informar as credenciais de acesso do seu portainer $amarelo =\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
    
}

## Credito do Setup

creditos_msg() {
    echo ""
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo=           $branco Gostaria de contribuir para continuarmos o desenvolvimento deste projeto?            $amarelo=\e[0m"
    echo -e "$amarelo=                              $branco Voce pode fazer uma doacao via PIX:                               $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo=                                     $amarelo                                      $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo=          $branco Ou faca parte da nossa comunidade VIP no Discord e contribua com o projeto            $amarelo=\e[0m"
    echo -e "$amarelo=                       $branco Nossa comunidade:$amarelo https://example.com/comunidade                        $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo=                                   $branco Nossos grupos no WhatsApp                                    $amarelo=\e[0m"
    echo -e "$amarelo=      $amarelo https://example.com/comunidade $branco<-- ou -->$amarelo https://example.com/comunidade      $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}


## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Mensagens gerais

## Mensagem pedindo para preencher as informacoes

preencha_as_info() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo=                          $branco Preencha as informacoes solicitadas abaixo                            $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem pedindo para verificar se as informacoes estao certas

conferindo_as_info() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo=                          $branco Verifique se os dados abaixos estao certos                            $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem de Guarde os dados

guarde_os_dados_msg() {
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo=                 $branco Guarde todos os dados abaixo para evitar futuros transtornos                   $amarelo=\e[0m"
    echo -e "$amarelo=                                                                                                 $amarelo=\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem de Instalando

instalando_msg() {
  echo""
  echo -e "$amarelo===================================================================================================\e[0m"
  echo -e "$amarelo=                                                                                                 =\e[0m"
  echo -e "$amarelo=                                                                                                 =\e[0m"
  echo -e "$amarelo===================================================================================================\e[0m"
  echo ""
  echo ""
}

## Mensagem de Erro

erro_msg() {
   echo -e "$amarelo===================================================================================================\e[0m"
   echo -e "$amarelo=                                                                                                 =\e[0m"
   echo -e "$amarelo=                                                                                                 =\e[0m"
   echo -e "$amarelo===================================================================================================\e[0m"
}

## Mensagem de Instalado

instalado_msg() {
    clear
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}

## Mensagem de Testando

nome_testando() {
    clear
    echo ""
    echo ""
    echo ""
}
nome_credenciais() {
    clear
    echo ""
    echo -e "$branco                                                                                               \e[0m"
    echo ""
    echo ""
    info_credenciais
}
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Titulos

## Nome do instalador

nome_instalador() { 
    clear
    echo ""
    echo -e "$branco                                                                                            \e[0m"
    echo "" 
}



## Menu de ferramentas

nome_menu() {
    clear
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo -e "$branco                                                                                                \e[0m"
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    versao
    echo ""
}

## Titulo Teste de Email [0]

nome_testeemail() {
  clear
  echo ""
  echo -e "$branco                                                                              \e[0m"
  echo ""
  echo ""                                                          
}

## Titulo Traefik e Portainer [1]

nome_traefik_e_portainer() {
    clear
    echo ""
    echo -e "$branco                                                                                      \e[0m"
    echo ""
    echo ""
}

nome_traefik() {
    clear
    echo ""
    echo ""
    echo ""
}


## Titulo Chatwoot [2]

nome_chatwoot(){
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Evolution [3]

nome_evolution() {
    clear
    echo ""
    echo ""
    echo ""                                                                                        
}

nome_evolution_lite() {
    clear
    echo ""
    echo ""
    echo -e "$branco                                                                                                  \e[0m"
    echo ""
    echo ""
}

## Titulo Evolution [2.beta]

nome_evolution_v2() {
    clear
    echo ""
    echo -e "$branco                                                                                                \e[0m"
    echo ""
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo=                    $branco Esta e uma versao Alfa e nao deve ser usada em producao.                    $amarel=\e[0m"
    echo -e "$amarelo=                                                                                                 =\e[0m"
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
}    

## Titulo Minio [4]

nome_minio() {
    clear
    echo ""
    echo ""
    echo ""                                   
}

## Titulo Typebot [5]

nome_typebot() {
    clear
    echo ""
    echo ""
    echo ""                                                    
}

## Titulo N8N [6]

nome_n8n() {
    clear
    echo ""
    echo ""
    echo ""                     
}

## Titulo Flowise [7]

nome_flowise() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo PgAdmin [8]

nome_pgAdmin_4() {
    clear
    echo ""
    echo ""
    echo ""                                                                  
}

## Titulo Nocobase [9]

nome_nocobase() {
    clear
    echo ""
    echo ""
    echo ""                                                                 
}

## Titulo Botpress [10]

nome_botpress() {
    clear
    echo ""
    echo ""
    echo ""                                                          
}

## Titulo Wordpress [11]

nome_wordpress() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Baserow [12]

nome_baserow() {
    clear
    echo ""
    echo ""
    echo ""                                                          
}

## Titulo MongoDB [13]

nome_mongodb() {
  clear
  echo ""
  echo ""
  echo ""                                                               
}

## Titulo RabbitMQ [14]

nome_rabbitmq() {
  clear
  echo ""
  echo ""
  echo ""                                                                 
}

## Titulo UptimeKuma [15]

nome_uptimekuma() {
  clear
  echo ""
  echo ""
  echo ""
}

## Titulo Calcom [16]

nome_calcom() {
  clear
  echo ""
  echo ""
  echo ""
}

## Titulo Mautic [17]

nome_mautic(){
    clear
    echo ""
    echo ""
    echo ""                                              
}

## Titulo Appsmith [18]

nome_appsmith() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Qdrant [19]

nome_qdrant() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo WoofedCRM [20]

nome_woofedcrm() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Formbricks [21]

nome_formbricks() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo NocoDB [22]

nome_nocodb() {
    clear
    echo ""
    echo ""
    echo ""                                                 
}

## Titulo Langfuse [23]

nome_langfuse() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Metabase [24]

nome_metabase() {
    clear
    echo ""
    echo ""
    echo ""
}   

## Titulo Odoo [25]

nome_odoo() {
    clear
    echo ""
    echo -e "$branco                                ##|   ##|##|  ##|##|   ##|##|   ##|\e[0m"
    echo -e "$branco                                ##|   ##|##|  ##|##|   ##|##|   ##|\e[0m"
    echo ""
    echo ""
}

## Titulo Chatwoot Nestor [26]
nome_chatwoot_nestor(){
    clear
    echo ""
    echo ""
    echo ""
}

nome_unoapi() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Uno API [27]

nome_n8n_quepasa(){
    clear
    echo ""
    echo -e "$branco                                                                                       \e[0m"                            
    echo ""
    echo ""
}

## Titulo Quepasa API [29]

nome_quepasa() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Docuseal [30]

nome_docuseal(){
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Grafana + Prometheus + cAdvisor [31]

nome_monitor() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Dify AI [32]

nome_dify() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Ollama [33]

nome_ollama() {
    clear
    echo ""
    echo ""
    echo ""                                   
}

## Titulo Affine [34]

nome_affine(){
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Directus [35]

nome_directus(){
clear
echo ""
echo ""
echo ""
}

## Titulo VaultWarden [36]

nome_vaultwarden() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo NextCloud [37]

nome_nextcloud() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Strapi [38]

nome_strapi() {
    clear
    echo ""
    echo -e "$branco                         #######|   ##|   ##|  ##|##|  ##|##|     ##|\e[0m"
    echo ""
    echo ""
}

## Titulo PhpMyAdmin [39]

nome_phpmyadmin(){
    clear
    echo "" 
    echo "" 
    echo "" 
}

## Titulo Supabase [40]

nome_supabase(){
    clear
    echo ""
    echo "" 
    echo "" 
}

## Titulo Ntfy [41]

nome_ntfy(){
    clear
    echo ""
    echo -e "$branco                                ##| #####|   ##|   ##|        ##|   \e[0m"
    echo "" 
    echo ""
}
 
## Titulo Lowcoder [42]

nome_lowcoder(){
    clear
    echo ""
    echo ""
    echo ""  
}

## Titulo Langflow [43]

nome_langflow() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo OpenProject [44]

nome_openproject() {
    clear
    echo ""
    echo ""
    echo ""
}                

## Titulo Zep [45]

nome_zep() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo HumHub [46]

nome_humhub() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Yourls [47]

nome_yourls() {
clear
echo ""
echo ""
echo ""
}

## Titulo TwentyCRM [48]

nome_twentycrm() {
clear
echo ""
echo ""
echo ""
}

## Titulo Mattermost [49]

nome_mattermost() {
clear
echo ""
echo ""
echo ""
}

## Titulo Outline [50]

nome_outline() {
clear
echo ""
echo ""
echo ""
}

## Titulo FocalBoard [51]

nome_focalboard() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo GLPI [52]

nome_glpi() {
    clear
    echo ""
    echo ""
    echo ""
}

## Titulo Anything LLM [53]

nome_anythingllm() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Excalidraw [54]

nome_excalidraw() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Excalidraw [53]

nome_easyappointments() {
    clear
    echo ""
    echo ""
    echo -e "$branco                                                                                                     \e[0m"
    echo ""
    echo ""
}

## Titulo Documenso [54]

nome_documenso() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Moodle [55]

#nome_moodle() {
#    clear
#    echo ""
#    echo ""
#    echo ""
#    echo ""
#}

## Titulo ToolJet [55]

nome_tooljet() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Stirling PDF [56]

nome_stirlingpdf() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo ClickHouse [57]

nome_clickhouse() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo RedisInsight [58]

nome_redisinsight() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Traccar [59]

nome_traccar() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Firecrawl [60]

nome_firecrawl() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Wuzapi [61]

nome_wuzapi() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Krayin CRM [62]

nome_krayincrm() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Planka [63]

nome_planka() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo WppConnect [64]

nome_wppconnect() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Browserless [65]

nome_browserless() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Frappe [66]

nome_frappe() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Bolt [67]

nome_bolt() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo WiseMapping [68]

nome_wisemapping() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Evo AI [69]

nome_evoai() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Evo AI [70]

nome_keycloak(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Passbolt [71]

nome_passbolt(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Gotenberg [72]

nome_gotenberg(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Wiki.js [73]

nome_wiki(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo AzuraCast [74]

nome_azuracast(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Shlink [75]

nome_shlink(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo RustDesk [76]

nome_rustdesk(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Hoppscotch [77]

    nome_hoppscotch(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Transcreve Zap [78]

nome_transcrevezap(){
    clear
    echo ""
    echo ""
    echo -e "$branco                                                                                            \e[0m"
    echo ""
    echo ""
}

## Titulo OmniTools [79]

nome_omnitools(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo serpbear [80]

nome_serpbear(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo ActivePieces [81]

nome_activepieces(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Authentik [82]

nome_authentik(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}     

## Titulo Checkmate [83]

nome_checkmate(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Heyform [84]

nome_heyform(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Wekan [85]
nome_wekan(){
  clear
  echo ""
  echo ""
  echo ""
  echo ""
}

## Titulo OpenSing [86]

nome_opensign(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Docmost [87]

nome_docmost() {
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo NetBox [88]

nome_netbox(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Kafka [89]

nome_kafka(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo AstraCampaign [90]

nome_astracampaign(){
    clear
    echo ""
    echo ""
    echo -e "$branco                             ##|  ##|#######|   ##|   ##|  ##|##|  ##|            \e[0m"
    echo -e "$branco                                                                                  \e[0m"
    echo ""
    echo ""
}

## Titulo Duplicati [91]

nome_duplicati(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo PgBackWeb [92]

nome_pgbackweb(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo JitsiMeet [93]

nome_jitsi(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo CodeServer [94]

nome_code_server(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Papra [95]

nome_papra(){
    clear
    echo ""
    echo ""
    echo -e "$branco                              ##|     ##|  ##|##|     ##|  ##|##|  ##|\e[0m"
    echo ""
    echo ""
}

## Titulo Zerobyte [96]

nome_zerobyte(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo Evoltuion Go [97]

nome_evolution_go(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

## Titulo EvoCRM [98]

nome_evocrm(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}
nome_openwebui(){
    clear
    echo ""
    echo ""
    echo ""
    echo ""
}

# ===================================================================================================


## Titulo Saindo do setup

nome_saindo() {
    clear
    echo ""
    echo -e "$branco                                                                   \e[0m"
    echo ""
    echo "" 
}

## Titulo Remover Stack

nome_remover_stack() {
    clear
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
    echo -e "$branco                                                                               \e[0m"
    echo ""
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
    echo""                                                                                             
}
nome_portainer.reset() {
    clear
    echo -e "$amarelo===================================================================================================\e[0m"
    echo ""
    echo ""
    echo -e "$branco                                                                                       \e[0m"
    echo ""
    echo ""
    echo -e "$amarelo===================================================================================================\e[0m"
}

nome_verificar_stack() {
    clear
    echo ""
    echo ""
    echo -e "$branco                                                                                   \e[0m"
    echo ""
    echo ""
}

nome_expurgando() {
clear
echo ""
echo ""
echo -e "$branco                                                                                            \e[0m"
echo ""
echo ""
}


## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Defasados

nome_trocar_logos() {
    clear
    echo ""
    echo -e "$branco                                                                                                 \e[0m"
    echo ""
    echo ""
}

nome_finalizado() {
    clear
    echo ""
    echo ""
    echo ""
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Menu de opcoes

#menu_instalador(){
#    echo -e "${amarelo}[ 00 ]${reset} - ${branco}Testar SMTP                             ${verde}| ${reset}  ${amarelo}[ 21 ]${reset} - ${branco}Formbricks${reset}"
#    echo -e "${amarelo}[ 01 ]${reset} - ${branco}Traefik & Portainer                     ${verde}| ${reset}  ${amarelo}[ 22 ]${reset} - ${branco}NocoDB${reset}"
#    echo -e "${amarelo}[ 02 ]${reset} - ${branco}Chatwoot                                ${verde}| ${reset}  ${amarelo}[ 23 ]${reset} - ${branco}Langfuse${reset}"
#    echo -e "${branco}  '-->${amarelo}[ 2.1 ]${reset} - ${branco}Chatwoot (ARM)                   ${verde}| ${reset}  ${amarelo}[ 24 ]${reset} - ${branco}Metabase${reset}"
#    echo -e "${amarelo}[ 03 ]${reset} -  ${branco}Evolution API                          ${verde}| ${reset}  ${amarelo}[ 25 ]${reset} - ${branco}Odoo${reset}"
#    echo -e "${branco}  '-->${amarelo}[ 3.1 ]${reset} - ${branco}Evolution API (ARM)              ${verde}| ${reset}  ${amarelo}[ 26 ]${reset} - ${branco}Chatwoot Nestor${reset}"
#    echo -e "${amarelo}[ 04 ]${reset} - ${branco}MinIO                                   ${verde}| ${reset}  ${amarelo}[ 27 ]${reset} - ${branco}Uno API${reset}"
#    echo -e "${amarelo}[ 05 ]${reset} - ${branco}Typebot                                 ${verde}| ${reset}  ${amarelo}[ 28 ]${reset} - ${branco}N8N + Nodes Quepasa $vermelho[OFF]${reset}"
#    echo -e "${amarelo}[ 06 ]${reset} - ${branco}N8N                                     ${verde}| ${reset}  ${amarelo}[ 29 ]${reset} - ${branco}Quepasa API $vermelho[OFF]${reset}"
#    echo -e "${amarelo}[ 07 ]${reset} - ${branco}Flowise                                 ${verde}| ${reset}  ${amarelo}[ 30 ]${reset} - ${branco}Docuseal${reset}"
#    echo -e "${amarelo}[ 08 ]${reset} - ${branco}PgAdmin 4                               ${verde}| ${reset}  ${amarelo}[ 31 ]${reset} - ${branco}Grafana + Prometheus + cAdvisor${reset}"
#    echo -e "${amarelo}[ 09 ]${reset} - ${branco}Nocobase                                ${verde}| ${reset}  ${amarelo}[ 32 ]${reset} - ${branco}Dify AI${reset}"
#    echo -e "${amarelo}[ 10 ]${reset} - ${branco}Botpress                                ${verde}| ${reset}  ${amarelo}[ 33 ]${reset} - ${branco}Ollama${reset}"
#    echo -e "${amarelo}[ 11 ]${reset} - ${branco}Wordpress                               ${verde}| ${reset}  ${amarelo}[ 34 ]${reset} - ${branco}Affine${reset}"
#    echo -e "${amarelo}[ 12 ]${reset} - ${branco}Baserow                                 ${verde}| ${reset}  ${amarelo}[ 35 ]${reset} - ${branco}Directus${reset}"
#    echo -e "${amarelo}[ 13 ]${reset} - ${branco}MongoDB                                 ${verde}| ${reset}  ${amarelo}[ 36 ]${reset} - ${branco}VaultWarden${reset}"
#    echo -e "${amarelo}[ 14 ]${reset} - ${branco}RabbitMQ                                ${verde}| ${reset}  ${amarelo}[ 37 ]${reset} - ${branco}NextCloud${reset}"
#    echo -e "${amarelo}[ 15 ]${reset} - ${branco}Uptime Kuma                             ${verde}| ${reset}  ${amarelo}[ 38 ]${reset} - ${branco}Strapi${reset}"
#    echo -e "${amarelo}[ 16 ]${reset} - ${branco}Cal.com                                 ${verde}| ${reset}  ${amarelo}[ 39 ]${reset} - ${branco}PhpMyAdmin${reset}"
#    echo -e "${amarelo}[ 17 ]${reset} - ${branco}Mautic                                  ${verde}| ${reset}  ${amarelo}[ 40 ]${reset} - ${branco}Supabase${reset}"
#    echo -e "${amarelo}[ 18 ]${reset} - ${branco}Appsmith                                ${verde}| ${reset}  ${amarelo}[ 41 ]${reset} - ${branco}Ntfy ${verde}[NOVO]${reset}"
#    echo -e "${amarelo}[ 19 ]${reset} - ${branco}Qdrant                                  ${verde}| ${reset}  ${amarelo}[ 42 ]${reset} - ${branco}REMOVER STACK${reset}"
#    echo -e "${amarelo}[ 20 ]${reset} - ${branco}Woofed CRM                              ${verde}| ${reset}  ${amarelo}[ 43 ]${reset} - ${branco}Sair do instalador${reset}"
#    echo""
#}

menu_instalador() {
  case $menu_instalador in
    1) menu_instalador_pg_1 ;;
    2) menu_instalador_pg_2 ;;
    3) menu_instalador_pg_3 ;;
    4) menu_comandos ;;
    *) echo "Erro ao listar menu..." ;;
  esac
}

menu_instalador_pg_1(){
    echo -e "${amarelo}[ 00 ]${reset} - ${branco}Testar SMTP                            ${verde}| ${reset}  ${amarelo}[ 23 ]${reset} - ${branco}Langfuse ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 01 ]${reset} - ${branco}Traefik & Portainer ${verde}[1/1]${reset}              ${verde}| ${reset}  ${amarelo}[ 24 ]${reset} - ${branco}Metabase ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 02 ]${reset} - ${branco}Chatwoot ${verde}[2/2]${reset}                         ${verde}| ${reset}  ${amarelo}[ 25 ]${reset} - ${branco}Odoo ${verde}[2/2] ${reset}"
    echo -e "${amarelo}[ 03 ]${reset} - ${branco}Evolution API ${verde}[1/1]${reset}                    ${verde}| ${reset}  ${amarelo}[ 26 ]${reset} - ${branco}Uno API ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 04 ]${reset} - ${branco}MinIO ${verde}[1/1]${reset}                            ${verde}| ${reset}  ${amarelo}[ 27 ]${reset} - ${branco}Quepasa API ${verde}[2/2] ${reset}"
    echo -e "${amarelo}[ 05 ]${reset} - ${branco}Typebot ${verde}[2/2]${reset}                          ${verde}| ${reset}  ${amarelo}[ 28 ]${reset} - ${branco}Docuseal ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 06 ]${reset} - ${branco}N8N ${verde}[2/2]${reset}                              ${verde}| ${reset}  ${amarelo}[ 29 ]${reset} - ${branco}Grafana + Prometheus + cAdvisor ${verde}[2/2] ${reset}"
    echo -e "${amarelo}[ 07 ]${reset} - ${branco}Flowise ${verde}[1/1]${reset}                          ${verde}| ${reset}  ${amarelo}[ 30 ]${reset} - ${branco}Dify AI ${verde}[2/4] ${reset}"
    echo -e "${amarelo}[ 08 ]${reset} - ${branco}PgAdmin 4 ${verde}[1/1]${reset}                        ${verde}| ${reset}  ${amarelo}[ 31 ]${reset} - ${branco}Ollama ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 09 ]${reset} - ${branco}Nocobase ${verde}[1/1]${reset}                         ${verde}| ${reset}  ${amarelo}[ 32 ]${reset} - ${branco}Affine ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 10 ]${reset} - ${branco}Botpress ${verde}[1/1]${reset}                         ${verde}| ${reset}  ${amarelo}[ 33 ]${reset} - ${branco}Directus ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 11 ]${reset} - ${branco}Wordpress ${verde}[1/1]${reset}                        ${verde}| ${reset}  ${amarelo}[ 34 ]${reset} - ${branco}VaultWarden ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 12 ]${reset} - ${branco}Baserow ${verde}[2/4]${reset}                          ${verde}| ${reset}  ${amarelo}[ 35 ]${reset} - ${branco}NextCloud ${verde}[2/2] ${reset}"
    echo -e "${amarelo}[ 13 ]${reset} - ${branco}MongoDB ${verde}[1/2]${reset}                          ${verde}| ${reset}  ${amarelo}[ 36 ]${reset} - ${branco}Strapi ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 14 ]${reset} - ${branco}RabbitMQ ${verde}[1/1]${reset}                         ${verde}| ${reset}  ${amarelo}[ 37 ]${reset} - ${branco}PhpMyAdmin ${verde}[1/2] ${reset}"
    echo -e "${amarelo}[ 15 ]${reset} - ${branco}Uptime Kuma ${verde}[1/1]${reset}                      ${verde}| ${reset}  ${amarelo}[ 38 ]${reset} - ${branco}Supabase ${verde}[2/4] ${reset}"
    echo -e "${amarelo}[ 16 ]${reset} - ${branco}Cal.com ${verde}[1/1]${reset}                          ${verde}| ${reset}  ${amarelo}[ 39 ]${reset} - ${branco}Ntfy ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 17 ]${reset} - ${branco}Mautic ${verde}[2/2]${reset}                           ${verde}| ${reset}  ${amarelo}[ 40 ]${reset} - ${branco}LowCoder ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 18 ]${reset} - ${branco}Appsmith ${verde}[2/4]${reset}                         ${verde}| ${reset}  ${amarelo}[ 41 ]${reset} - ${branco}LangFlow ${verde}[2/2] ${reset}"
    echo -e "${amarelo}[ 19 ]${reset} - ${branco}Qdrant ${verde}[1/1]${reset}                           ${verde}| ${reset}  ${amarelo}[ 42 ]${reset} - ${branco}OpenProject ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 20 ]${reset} - ${branco}Woofed CRM ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 43 ]${reset} - ${branco}ZEP ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 21 ]${reset} - ${branco}Formbricks ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 44 ]${reset} - ${branco}HumHub ${verde}[1/1] ${reset}"
    echo -e "${amarelo}[ 22 ]${reset} - ${branco}NocoDB ${verde}[1/1]${reset}                           ${verde}| ${reset}  ${amarelo}[ 45 ]${reset} - ${branco}Yourls ${verde}[1/1] ${reset}"
    echo -e ""
    echo -e "${branco}<-- Digite ${amarelo}P1 ${branco}para ir para pagina 1             ${amarelo}|${branco}              Digite ${amarelo}P2${branco} para ir para pagina 2 -->${reset}"
    echo -e ""
}

menu_instalador_pg_2(){
    echo -e "${amarelo}[ 46 ]${reset} - ${branco}TwentyCRM${vermelho} ${verde}[1/4]${reset}                        ${verde}| ${reset}  ${amarelo}[ 69 ]${reset} - ${branco}Evo AI ${verde}[1/1]${reset}${reset}"
    echo -e "${amarelo}[ 47 ]${reset} - ${branco}Mattermost ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 70 ]${reset} - ${branco}Keycloak ${verde}[2/2]${reset}${reset}"
    echo -e "${amarelo}[ 48 ]${reset} - ${branco}Outline ${verde}[1/1]${reset}                          ${verde}| ${reset}  ${amarelo}[ 71 ]${reset} - ${branco}Passbolt ${verde}[1/1]${reset}${reset}"
    echo -e "${amarelo}[ 49 ]${reset} - ${branco}Focalboard ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 72 ]${reset} - ${branco}Gotenberg ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 50 ]${reset} - ${branco}GLPI ${verde}[1/1]${reset}                             ${verde}| ${reset}  ${amarelo}[ 73 ]${reset} - ${branco}Wiki.js ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 51 ]${reset} - ${branco}Anything LLM ${verde}[1/1]${reset}                     ${verde}| ${reset}  ${amarelo}[ 74 ]${reset} - ${branco}AzuraCast ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 52 ]${reset} - ${branco}Excalidraw ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 75 ]${reset} - ${branco}Shlink ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 53 ]${reset} - ${branco}Easy!Apointments ${verde}[1/1]${reset}                 ${verde}| ${reset}  ${amarelo}[ 76 ]${reset} - ${branco}RustDesk ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 54 ]${reset} - ${branco}Documenso ${verde}[1/1]${reset}                        ${verde}| ${reset}  ${amarelo}[ 77 ]${reset} - ${branco}Hoppscotch ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 55 ]${reset} - ${branco}ToolJet ${verde}[2/4]${reset}                          ${verde}| ${reset}  ${amarelo}[ 78 ]${reset} - ${branco}Transcreve Zap ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 56 ]${reset} - ${branco}Stirling PDF ${verde}[1/1]${reset}                     ${verde}| ${reset}  ${amarelo}[ 79 ]${reset} - ${branco}OmniTools ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 57 ]${reset} - ${branco}ClickHouse ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 80 ]${reset} - ${branco}SerpBear ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 58 ]${reset} - ${branco}RedisInsight ${verde}[1/1]${reset}                     ${verde}| ${reset}  ${amarelo}[ 81 ]${reset} - ${branco}ActivePieces ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 59 ]${reset} - ${branco}Traccar ${verde}[1/1]${reset}                          ${verde}| ${reset}  ${amarelo}[ 82 ]${reset} - ${branco}Authentik ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 60 ]${reset} - ${branco}Firecrawl ${verde}[2/4]${reset}                        ${verde}| ${reset}  ${amarelo}[ 83 ]${reset} - ${branco}Checkmate ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 61 ]${reset} - ${branco}Wuzapi ${verde}[1/1]${reset}                           ${verde}| ${reset}  ${amarelo}[ 84 ]${reset} - ${branco}Heyform ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 62 ]${reset} - ${branco}krayin CRM ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 85 ]${reset} - ${branco}Wekan ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 63 ]${reset} - ${branco}Planka ${verde}[1/1]${reset}                           ${verde}| ${reset}  ${amarelo}[ 86 ]${reset} - ${branco}OpenSing ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 64 ]${reset} - ${branco}WppConnect ${verde}[1/1]${reset}                       ${verde}| ${reset}  ${amarelo}[ 87 ]${reset} - ${branco}Docmost ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 65 ]${reset} - ${branco}Browserless ${verde}[2/4]${reset}                      ${verde}| ${reset}  ${amarelo}[ 88 ]${reset} - ${branco}NetBox ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 66 ]${reset} - ${branco}Frappe ${verde}[2/4]${reset}                           ${verde}| ${reset}  ${amarelo}[ 89 ]${reset} - ${branco}Kafka ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 67 ]${reset} - ${branco}Bolt ${verde}[2/4]${reset}                             ${verde}| ${reset}  ${amarelo}[ 90 ]${reset} - ${branco}AstraCampaign ${verde}[1/1]${reset}"
    echo -e "${amarelo}[ 68 ]${reset} - ${branco}WiseMapping ${verde}[1/1]${reset}                      ${verde}| ${reset}  ${amarelo}[ 91 ]${reset} - ${branco}Duplicati ${verde}[1/1]${reset}"
    echo -e ""
    echo -e "${branco}<-- Digite ${amarelo}P1 ${branco}para ir para pagina 1             ${amarelo}|${branco}              Digite ${amarelo}P3${branco} para ir para pagina 3 -->${reset}"
    echo -e ""
}

menu_instalador_pg_3(){
    echo -e "${amarelo}[ 92 ]${reset} - ${branco}PgBackWeb ${verde}[1/1]${reset}                        ${verde}| ${reset}  ${amarelo}[ 115 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 93 ]${reset} - ${branco}Jitsi Meet ${verde}[2/2]${reset}                       ${verde}| ${reset}  ${amarelo}[ 116 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 94 ]${reset} - ${branco}Code Server ${verde}[1/1]${reset}                      ${verde}| ${reset}  ${amarelo}[ 117 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 95 ]${reset} - ${branco}Papra ${verde}[1/1]${reset}                            ${verde}| ${reset}  ${amarelo}[ 118 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 96 ]${reset} - ${branco}ZeroByte ${verde}[1/1]${reset}                         ${verde}| ${reset}  ${amarelo}[ 119 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 97 ]${reset} - ${branco}Evolution GO ${verde}[1/1]${reset} ${verde}[NOVO]${reset}              ${verde}| ${reset}  ${amarelo}[ 120 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 98 ]${reset} - ${branco}EvoCRM ${verde}[4/8]${reset} ${verde}[NOVO]${reset}                    ${verde}| ${reset}  ${amarelo}[ 121 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 99 ]${reset} - ${branco}EM BREVE...${reset}                            ${verde}| ${reset}  ${amarelo}[ 122 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 100 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 123 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 101 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 124 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 102 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 125 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 103 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 126 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 104 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 127 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 105 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 128 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 106 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 129 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 107 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 130 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 108 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 131 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 109 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 132 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 110 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 133 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 111 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 134 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 112 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 135 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 113 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 136 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e "${amarelo}[ 114 ]${reset} - ${branco}EM BREVE...${reset}                           ${verde}| ${reset}  ${amarelo}[ 137 ]${reset} - ${branco}EM BREVE...${reset}"
    echo -e ""
    echo -e "${branco}<-- Digite ${amarelo}P2 ${branco}para ir para pagina 2             ${amarelo}|${branco}              Digite ${amarelo}P3${branco} para ir para pagina 3 -->${reset}"
    echo -e ""
}

menu_comandos(){
  ## Portainer
  echo -e "> ${verde}Gerenciamento de Servicos:${reset}"
  echo -e "${branco} - ${amarelo}portainer.restart${reset} - ${branco}Reinicia o Portainer${reset}"
  echo -e "${branco} - ${amarelo}portainer.reset${reset} - ${branco}Reseta a senha do Portainer${reset}"
  echo -e "${branco} - ${amarelo}portainer.update${reset} - ${branco}Atualiza o Portainer${reset}"
  echo -e "${branco} - ${amarelo}traefik.update${reset} - ${branco}Atualiza o Traefik${reset}"
  echo -e "${branco} - ${amarelo}traefik.dash${reset} - ${branco}Ativa o Dashboard do Traefik${reset}"
  echo ""

  ## Monitoramento
  echo -e "> ${verde}Comandos de Monitoramento:${reset}"
  echo -e "${branco} - ${amarelo}ctop${reset} - ${branco}Instala o CTOP${reset}"
  echo -e "${branco} - ${amarelo}htop${reset} - ${branco}Instala o HTOP${reset}"
  echo ""

  ## Chatwoot
  echo -e "> ${verde}Comandos do Chatwoot:${reset}"
  echo -e "${branco} - ${amarelo}chatwoot.mail${reset} - ${branco}Troca os Emails do Chatwoot pela versao do FELSEN${reset}"
  echo -e "${branco} - ${amarelo}chatwoot.n.mail${reset} - ${branco}Troca os Emails do Chatwoot Mega pela versao do FELSEN${reset}"
  echo ""

  ## Ferramentas
  echo -e "> ${verde}Comandos de Ferramentas:${reset}"
  echo -e "${branco} - ${amarelo}evolution.v1${reset} - ${branco}Instala a Evolution v1.8+${reset}"
  echo -e "${branco} - ${amarelo}evolution.lite${reset} - ${branco}Instala a Evolution Lite${reset}"
  echo -e "${branco} - ${amarelo}transcrevezap${reset} - ${branco}Instala o Transcreve Zap${reset}"
  echo -e "${branco} - ${amarelo}minio.bucket${reset} - ${branco}Cria Buckets Publicas no MinIO${reset}"
  echo ""

  ## Quepasa
  echo -e "> ${verde}Comandos do Quepasa:${reset}"
  echo -e "${branco} - ${amarelo}quepasa.setup.off${reset} - ${branco}Desativa o Setup do Quepasa${reset}"
  echo -e "${branco} - ${amarelo}quepasa.setup.on${reset} - ${branco}Ativa o Setup do Quepasa${reset}"
  echo ""

  ## Manutencao
  echo -e "> ${verde}Comandos de Manutencao:${reset}"
  echo -e "${branco} - ${amarelo}limpar${reset} - ${branco}Limpa Logs, volumes e imagens do Docker nao usadas${reset}"

  echo -e ""
  echo -e "${branco}<-- Digite ${amarelo}P1 ${branco}para ir para pagina 1             ${amarelo}|${branco}              Digite ${amarelo}P2${branco} para ir para pagina 2 -->${reset}"
  echo -e ""
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Verificar se stack ja existe
verificar_stack() {
    clear
    local nome_stack="$1"

    if docker stack ls --format "{{.Name}}" | grep -q "^${nome_stack}$"; then
        nome_verificar_stack
        echo -e "A stack '$amarelo${nome_stack}\e[0m' existe."
        echo -e "Caso deseje refazer a instalacao, por favor, remova a stack $amarelo${nome_stack}\e[0m do"
        echo -e "seu Portainer e tente novamente..."
        echo -e ""
        echo -e "Voltando ao menu principal em 10 segundos"
        sleep 10

        clear 

        return 0
    else
        return 1
    fi
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

# Funcao para verificar recursos
recursos() {
    # Parametros de entrada: vCPU e GbRam
    vcpu_requerido=$1
    ram_requerido=$2

    # Obtendo a quantidade de vCPUs e GB de RAM disponiveis
    if command -v neofetch >/dev/null 2>&1; then
        # Debian 11
        vcpu_disponivel=$(neofetch --stdout | grep "CPU" | grep -oP '\(\d+\)' | tr -d '()')
        ram_disponivel=$(neofetch --stdout | grep "Memory" | awk '{print $4}' | tr -d 'MiB' | awk '{print int($1/1024 + 0.5)}')
    elif command -v fastfetch >/dev/null 2>&1; then
        # Debian 13 (usa saida JSON do fastfetch)
        vcpu_disponivel=$(fastfetch --json | jq '.cpu.cores')
        ram_disponivel=$(fastfetch --json | jq '.memory.total / 1024 / 1024' | awk '{print int($1+0.5)}')
    else
        echo "Erro: nem neofetch nem fastfetch encontrados. Instale um deles para continuar."
        return 1
    fi

    # Comparando os recursos
    if [[ $vcpu_disponivel -ge $vcpu_requerido && $ram_disponivel -ge $ram_requerido ]]; then
        echo "ok"
        clear
        return 0
    else
        clear
        erro_msg
        echo -e "Ops, parece que o seu servidor nao atende os requisitos minimos dessa aplicacao."
        echo -e "Esse servico precisa de \e[32m$vcpu_requerido vCPU${reset} e \e[32m$ram_requerido Gb RAM${reset}."
        echo -e "Atualmente, seu servidor possui apenas: \e[32m$vcpu_disponivel vCPU${reset} com \e[32m$ram_disponivel Gb RAM${reset}."
        echo -e "Voce pode ter problemas de desempenho, falhas na execucao ou problemas na instalacao."

        echo ""
        read -p "Deseja continuar mesmo assim? (y/n): " escolha
        if [[ "$escolha" =~ ^[Yy]$ ]]; then
            return 0
        else
            echo ""
            echo "Voltando ao menu em 10 segundos."
            sleep 10
            nome_menu
            menu_instalador
            return 1
        fi
    fi
}


## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

stack_editavel(){

    ## Instalar jq
    sudo apt install jq -y > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "2/10 - [ OK ] - Instalando JQ Metodo 1/2"
    else
        echo "2/10 - [ OFF ] - Erro ao instalar JQ Metodo 1/2"
    fi

    sudo apt-get install -y jq > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "3/10 - [ OK ] - Instalando JQ Metodo 2/2"
    else
        echo "3/10 - [ OFF ] - Erro ao instalar JQ Metodo 2/2"
    fi

    ## Definindo o diretorio do arquivo dados_portainer
    arquivo="/root/dados_vps/dados_portainer"

    ## Verifica se o arquivo existe
    if [ ! -f "$arquivo" ]; then
        echo "Arquivo nao encontrado: $arquivo"
        sleep 2

        ## Cria o arquivo caso nao exista
        criar_arquivo
    fi

    ## Remove o https:// caso existir
    sed -i 's/Dominio do portainer: https:\/\/\(.*\)/Dominio do portainer: \1/' "$arquivo"

    ## Pega o usuario do portainer
    USUARIO=$(grep "Usuario: " /root/dados_vps/dados_portainer | awk -F "Usuario: " '{print $2}')
    if [ $? -eq 0 ]; then
        echo -e "4/10 - [ OK ] - Pegando usuario do portainer: $bege$USUARIO$reset"
    else
        echo "4/10 - [ OFF ] - Erro ao pegar usuario do portainer"
    fi


    ## Pega a senha do portainer
    SENHA=$(grep "Senha: " /root/dados_vps/dados_portainer | awk -F "Senha: " '{print $2}')
    esconder_senha "$SENHA"
    if [ $? -eq 0 ]; then
        echo -e "5/10 - [ OK ] - Pegando a senha do portainer: $bege$SENHAOCULTA$reset"
    else
        echo "5/10 - [ OFF ] - Erro ao pegar senha do portainer"
    fi

    ## Pega a URL do portainer
    PORTAINER_URL=$(grep "Dominio do portainer: " /root/dados_vps/dados_portainer | awk -F "Dominio do portainer: " '{print $2}')
    if [ $? -eq 0 ]; then
        echo -e "6/10 - [ OK ] - Pegando dominio do Portainer: $bege$PORTAINER_URL$reset"
    else
        echo "6/10 - [ OFF ] - Erro ao pegar dominio do Portainer"
    fi

    ## Usa o token do portainer
    #TOKEN=$(grep "Token: " /root/dados_vps/dados_portainer | awk -F "Token: " '{print $2}')
    
    ## Pega um token do portainer
    #TOKEN=$(curl -k -X POST -H "Content-Type: application/json" -d "{\"username\":\"$USUARIO\",\"password\":\"$SENHA\"}" https://$PORTAINER_URL/api/auth | jq -r .jwt)

    TOKEN=""
    Tentativa_atual=0
    Maximo_de_tentativas=6
    
    while [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; do
        TOKEN=$(curl -k -s -X POST -H "Content-Type: application/json" -d "{\"username\":\"$USUARIO\",\"password\":\"$SENHA\"}" https://$PORTAINER_URL/api/auth | jq -r .jwt)
    
        Tentativa_atual=$((Tentativa_atual + 1))
    
        ## Verifica se atingiu o numero maximo de tentativas
        if [ "$Tentativa_atual" -ge "$Maximo_de_tentativas" ]; then
            clear
            erro_msg
            echo "7/10 - [ OFF ] - Erro: Falha ao obter token apos $Maximo_de_tentativas tentativas."
            echo "Verifique suas credenciais do Portainer para conseguirmos realizar o deploy."
            sleep 5
            criar_arquivo
            return
            #exit 1
        fi
    
        ## Se o token foi obtido com sucesso, sair do loop
        if [ -n "$TOKEN" ] && [ "$TOKEN" != "null" ]; then
            break
        fi
    
        ## Aguarda alguns segundos antes de tentar novamente
        echo -e "Tentando gerar token do portainer. Tentativa atual $bege$Tentativa_atual/5$reset"
        sleep 5
    done
    
    if [ $? -eq 0 ]; then
        esconder_senha "$TOKEN"
        echo -e "7/10 - [ OK ] - Pegando token do Portainer: $bege$SENHAOCULTA$reset"
    fi
    

    ### Verifica se o token veio vazio
    #if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    #    echo "Erro: Falha ao obter token. Preencha com suas credenciais do portainer a seguir."
    #    sleep 5
    #    criar_arquivo
    #    #exit 1
    #fi

    ## Salva dados no arquivo do portainer
    echo -e "[ PORTAINER ]\nDominio do portainer: $PORTAINER_URL\n\nUsuario: $USUARIO\n\nSenha: $SENHA\n\nToken: $TOKEN" > "/root/dados_vps/dados_portainer"

    ## Pegando o id do portainer
    ENDPOINT_ID=$(curl -k -s -X GET -H "Authorization: Bearer $TOKEN" https://$PORTAINER_URL/api/endpoints | jq -r '.[] | select(.Name == "primary") | .Id')
    if [ $? -eq 0 ]; then
        echo -e "8/10 - [ OK ] - Pegando ID do Portainer: $bege$ENDPOINT_ID$reset"
    else
        echo "8/10 - [ OFF ] - Erro ao pegar ID do Portainer"
    fi

    ## Definindo id 1 do Portainer
    #ENDPOINT_ID=1
    
    ## Pegando o ID do Swarm
    SWARM_ID=$(curl -k -s -X GET -H "Authorization: Bearer $TOKEN" "https://$PORTAINER_URL/api/endpoints/$ENDPOINT_ID/docker/swarm" | jq -r .ID)
    if [ $? -eq 0 ]; then
        echo -e "9/10 - [ OK ] - Pegando ID do Swarm: $bege$SWARM_ID$reset"
    else
        echo "9/10 - [ OFF ] - Erro ao pegar ID do Swarm"
    fi

    ## Testa o Swarm
    SWARM_STATUS=$(docker info --format '{{.Swarm.LocalNodeState}}')
    if [ "$SWARM_STATUS" != "active" ]; then
        echo "Erro: Docker Swarm nao esta ativo."
        exit 1
    fi

    # Arquivo temporario para capturar a saida de erro e a resposta
    erro_output=$(mktemp)
    response_output=$(mktemp)

    ## Fazendo deploy da stack pelo portainer
    http_code=$(curl -s -o "$response_output" -w "%{http_code}" -k -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -F "Name=$STACK_NAME" \
    -F "file=@$(pwd)/$STACK_NAME.yaml" \
    -F "SwarmID=$SWARM_ID" \
    -F "endpointId=$ENDPOINT_ID" \
    "https://$PORTAINER_URL/api/stacks/create/swarm/file" 2> "$erro_output")

    response_body=$(cat "$response_output")

    if [ "$http_code" -eq 200 ]; then
        # Verifica o conteudo da resposta para garantir que o deploy foi bem-sucedido
        if echo "$response_body" | grep -q "\"Id\""; then
            echo -e "10/10 - [ OK ] - Deploy da stack $bege$STACK_NAME$reset feito com sucesso!"
        else
            echo -e "10/10 - [ OFF ] - Erro, resposta inesperada do servidor ao tentar efetuar deploy da stack $bege$STACK_NAME$reset."
            echo "Resposta do servidor: $(echo "$response_body" | jq .)"
        fi
    else
        echo "10/10 - [ OFF ] - Erro ao efetuar deploy. Resposta HTTP: $http_code"
        echo "Mensagem de erro: $(cat "$erro_output")"
        echo "Detalhes: $(echo "$response_body" | jq .)"
    fi

    echo ""

    # Remove os arquivos temporarios
    rm "$erro_output"
    rm "$response_output"
}

## Funcao para verificar se o arquivo de dados do Portainer existe
verificar_arquivo() {
    sudo apt install jq -y > /dev/null 2>&1
    if [ ! -f "/root/dados_vps/dados_portainer" ]; then
        nome_credenciais
        criar_arquivo
    else
        verificar_campos
    fi
}


## Funcao para criar o arquivo de dados do Portainer
verificar_campos() {
    PORTAINER_URL=$(grep -oP '(?<=Dominio do portainer: ).*' /root/dados_vps/dados_portainer)
    USUARIO=$(grep -oP '(?<=Usuario: ).*' /root/dados_vps/dados_portainer)
    SENHA=$(grep -oP '(?<=Senha: ).*' /root/dados_vps/dados_portainer)

    ## se por acaso nao tiver login nem senha la vem para ca
    if [ -z "$USUARIO" ] || [ -z "$SENHA" ]; then
        
        nome_credenciais
        echo -e "\e[97mPasso$amarelo 1/3\e[0m"
        #echo -e "\e[97mObs: Coloque o https:// antes do link do portainer\e[0m"
        read -p "Digite a Url do Portainer (ex: portainer.example.com): " PORTAINER_URL
        echo ""
    
        echo -e "\e[97mPasso$amarelo 2/3\e[0m"
        read -p "Digite seu Usuario (ex: admin): " USUARIO
        echo ""
    
        echo -e "\e[97mPasso$amarelo 3/3\e[0m"
        echo -e "\e[97mObs: A Senha nao aparecera ao digitar\e[0m"
        read -s -p "Digite a Senha (ex: @Senha123_): " SENHA
        echo ""

        ATUALIZAR="true" ## Verificar se ja existe TOKEN no arquivo
        verificar_token "$PORTAINER_URL" "$USUARIO" "$SENHA" true
    ## Caso o usuario e senha estiver como "Precisa criar dentro do portainer" como o arquivo oficial vem para ca
    elif [ "$USUARIO" == "Precisa criar dentro do portainer" ] || [ "$SENHA" == "Precisa criar dentro do portainer" ]; then
        
        nome_credenciais
        echo -e "\e[97mPasso$amarelo 1/3\e[0m"
        #echo -e "\e[97mObs: Coloque o https:// antes do link do portainer\e[0m"
        read -p "Digite a Url do Portainer (ex: portainer.example.com): " PORTAINER_URL
        echo ""
    
        echo -e "\e[97mPasso$amarelo 2/3\e[0m"
        read -p "Digite seu Usuario (ex: admin): " USUARIO
        echo ""
    
        echo -e "\e[97mPasso$amarelo 3/3\e[0m"
        echo -e "\e[97mObs: A Senha nao aparecera ao digitar\e[0m"
        read -s -p "Digite a Senha (ex: @Senha123_): " NOVA_SENHA
        echo ""

        verificar_token "$PORTAINER_URL" "$NOVO_USUARIO" "$NOVA_SENHA" true
    else
        verificar_token "$PORTAINER_URL" "$USUARIO" "$SENHA" false
    fi
}

## Funcao para verificar se o token e valido
verificar_token() {
    PORTAINER_URL="$1"
    USUARIO="$2"
    SENHA="$3"
    ATUALIZAR="$4"
    TENTATIVAS=0
    MAX_TENTATIVAS=5

    while [ $TENTATIVAS -lt $MAX_TENTATIVAS ]; do
        TENTATIVAS=$((TENTATIVAS+1))

        #echo -e "Dados a serem testados:"
        #echo "Link do Portainer: $PORTAINER_URL"
        #echo "Usuario: $USUARIO"
        #echo "Senha: $SENHA"

        RESPONSE=$(curl -s -w "\n%{http_code}" -k -X POST -H "Content-Type: application/json" -d "{\"username\":\"$USUARIO\",\"password\":\"$SENHA\"}" "https://$PORTAINER_URL/api/auth")
        TOKEN=$(echo "$RESPONSE" | sed '$d' | jq -r '.jwt')
        HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

        if [ "$HTTP_STATUS" -eq 200 ] && [ ! -z "$TOKEN" ]; then
    
            if [ "$ATUALIZAR" == true ]; then
                atualizar_arquivo
            fi

            $APP_FELSEN

            break
        else
            if [ $TENTATIVAS -gt 1 ]; then
                clear
                erro_msg
                echo ""
                echo ""
                echo "              Nao foi possivel autenticar suas credenciais. Por favor tente novamente"
                echo "                                           Tentativa: $TENTATIVAS/$MAX_TENTATIVAS"
    
                sleep 3

            else
                clear
                nome_credenciais
            fi

            if [ $TENTATIVAS -lt $MAX_TENTATIVAS ]; then
                
                nome_credenciais
                echo -e "\e[97mPasso$amarelo 1/3\e[0m"
                #echo -e "\e[97mObs: Coloque o https:// antes do link do portainer\e[0m"
                read -p "Digite a Url do Portainer (ex: portainer.example.com): " PORTAINER_URL
                echo ""
            
                echo -e "\e[97mPasso$amarelo 2/3\e[0m"
                read -p "Digite seu Usuario (ex: admin): " USUARIO
                echo ""
            
                echo -e "\e[97mPasso$amarelo 3/3\e[0m"
                echo -e "\e[97mObs: A Senha nao aparecera ao digitar\e[0m"
                read -s -p "Digite a Senha (ex: @Senha123_): " SENHA
                echo ""
                ATUALIZAR="true"
            else
                clear
                erro_msg

                echo ""
                echo ""
                echo "                         Voce atingiu o limite maximo de tentativas ($TENTATIVAS/$MAX_TENTATIVAS)."
                echo "                         Tente novamente quando lembrar da sua credencial!"
                echo 5
                clear
                break
            fi
        fi
    done
}

## Funcao para atualizar o arquivo de dados do Portainer com o novo usuario e senha
atualizar_arquivo() {
    echo -e "[ PORTAINER ]\nDominio do portainer: $PORTAINER_URL\n\nUsuario: $USUARIO\n\nSenha: $SENHA\n\nToken: $TOKEN" > "/root/dados_vps/dados_portainer"
    echo -e "\nArquivo de dados do Portainer atualizado com sucesso!"
}


## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Verificadores


## Verifica se existe Docker, Portainer e Traefik na VPS
verificar_docker_e_portainer_traefik() {
    ## Verifica se o Docker esta instalado
    if ! command -v docker &> /dev/null; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[1] Traefik e Portainer${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    ## Verifica se o Portainer esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "portainer"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[1] Traefik e Portainer${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    ## Verificar se o Traefik esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "traefik"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[1] Traefik e Portainer${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

## Verifica se existe Minio
verificar_antes_se_tem_minio() {

    ## Verifica se o Portainer esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "minio"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 4 ] - MinIO${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

verificar_antes_se_tem_clickhouse() {
  
  ## Verifica se o Portainer esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "clickhouse"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 58 ] - ClickHouse${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

## Verifica se existe rabbitMQ
verificar_antes_se_tem_rabbitmq() {

    ## Verifica se o Portainer esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "rabbitmq"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 14 ] - RabbitMQ${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

## Verifica se existe Minio RabbitMQ e Chatwoot 
verificar_antes_se_tem_minio_e_rabbitmq_e_chatwoot() {
    ## Verifica se o minio esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "minio"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 4 ] - MinIO${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    ## Verifica se o rabbitmq esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "rabbitmq"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 14 ] - RabbitMQ${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    ## Verificar se o chatwoot esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "chatwoot"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 2 ] - Chatwoot${reset} ou  \e[32m[ 26 ] - Chatwoot Nestor (ft. Francis) ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

## Verifica se existe Minio e Qdrant
verificar_antes_se_tem_minio_e_qdrant() {
    ## Verifica se o minio esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "minio"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 4 ] - MinIO${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    ## Verifica se o rabbitmq esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "qdrant"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 19 ] - Qdrant${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

## Verifica se existe Minio
verificar_antes_se_tem_mongo() {

    ## Verifica se o Portainer esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "mongodb"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 13 ] - MongoDB${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

## Verifica se existe Qdrant
verificar_antes_se_tem_qdrant() {

    ## Verifica se o Portainer esta instalado
    if ! docker ps -a --format "{{.Names}}" | grep -q "qdrant"; then
        clear
        erro_msg
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[ 19 ] - Qdrant${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."

        echo ""
        echo "Voltando ao menu em 5 segundos."
        sleep 5

        nome_menu
        menu_instalador

        return 1
    fi

    return 0
}

## Verificar Container Postgres

verificar_container_postgres() {
    if docker ps -q --filter "name=postgres_postgres.1" | grep -q .; then
        return 0
    else
        return 1
    fi
}

## Verificar Container PgVector

verificar_container_pgvector() {
    if docker ps -q --filter "name=pgvector_pgvector.1" | grep -q .; then
        return 0
    else
        return 1
    fi
}

## Verificar Container Mysql

verificar_container_mysql() {
    if docker ps -q --filter "name=mysql_mysql.1" | grep -q .; then
        return 0
    else
        return 1
    fi
}

## Verificar Container Redis

verificar_container_redis() {
    if docker ps -q --filter "name=redis_redis.1" | grep -q .; then
        return 0
    else
        return 1
    fi
}

## Verificar Container Minio

verificar_container_minio() {
    if docker ps -q --filter "name=minio_minio.1" | grep -q .; then
        return 0
    else
        return 1
    fi
}

## Esperar Postgres estar pronto

wait_for_postgres() {
    dados
    local container_name="postgres_postgres"

    while true; do
        CONTAINER_ID=$(docker ps -q --filter "name=.*$container_name.*")

        if [ -n "$CONTAINER_ID" ]; then

            break
        fi

        sleep 5
    done
}

wait_for_pgvector() {
    dados
    local container_name="pgvector_pgvector.1"

    while true; do
        CONTAINER_ID=$(docker ps -q --filter "name=.*$container_name.*")

        if [ -n "$CONTAINER_ID" ]; then

            break
        fi

        sleep 5
    done
}

## Verificar se o Traefik esta online

wait_30_sec() {
    sleep 30
}

#wait_stack() {
#    echo "Este processo pode demorar um pouco. Se levar mais de 5 minutos, cancele, pois algo deu errado."
#    while true; do
#        # Verifica se o servico trarik esta ativo
#        if docker service ls --filter "name=$1" | grep "1/1"; then
#            sleep 10
#            echo ""
#            break
#        fi
#
#        sleep 5
#    done
#}
wait_stack() {
    echo "Este processo pode demorar um pouco. Se levar mais de 10 minutos, cancele, pois algo deu errado."
    declare -A services_status

    # Inicializa o status de todos os servicos como "pendente"
    for service in "$@"; do
        services_status["$service"]="pendente"
    done

    while true; do
        all_active=true

        for service in "${!services_status[@]}"; do
            if docker service ls --filter "name=$service" | grep -q "1/1"; then
                if [ "${services_status["$service"]}" != "ativo" ]; then
                    echo -e " O servico \e[32m$service\e[0m esta online."
                    services_status["$service"]="ativo"
                fi
            else
                if [ "${services_status["$service"]}" != "pendente" ]; then
                    services_status["$service"]="pendente"
                fi
                all_active=false
            fi
        done

        # Sai do loop quando todos os servicos estiverem ativos
        if $all_active; then
            sleep 1
            break
        fi
        sleep 30
        echo ""
    done
}

#pull() {
#
#    for image in "$@"; do     
#        if docker pull "$image" > /dev/null 2>&1; then
#            sleep 1
#        else
#            echo "*"
#            sleep 1
#        fi
#    done
#}

pull() {
    for image in "$@"; do
        while true; do
            if docker pull "$image" > /dev/null 2>&1; then
                sleep 1
                break
            else
                echo "Erro ao baixar $image. Tentando novamente..."
                
                # Verifica se o erro e relacionado a limite de taxa
                if docker pull "$image" 2>&1 | grep -q "toomanyrequests"; then
                    echo "Limite de taxa atingido no Docker Hub. Faca login para continuar."
                    docker login
                else
                    echo "Erro desconhecido. Tentando novamente em 5s..."
                    sleep 5
                fi
            fi
        done
    done
}

requisitar_outra_instalacao(){
    read -p "Deseja instalar outra aplicacao? (Y/N): " choice
    if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
        return
    else
        cd
        cd
        clear
        exit 1
    fi
}

esconder_senha() {
  local senha="$1"
  local tamanho=${#senha}

  if (( tamanho > 55 )); then
    SENHAOCULTA=$(printf '%*s' 54 '' | tr ' ' '*')
  else
    SENHAOCULTA=$(printf '%*s' "$tamanho" '' | tr ' ' '*')
  fi
}



## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Pegar informacoes


## Pegar senha Postgres

pegar_senha_postgres() {
    while :; do
        if [ -f /root/postgres.yaml ]; then
            senha_postgres=$(grep "POSTGRES_PASSWORD" /root/postgres.yaml | awk -F '=' '{print $2}')
            break
        else
            sleep 5
        fi
    done
}

pegar_senha_pgvector() {
    while :; do
        if [ -f /root/pgvector.yaml ]; then
            senha_pgvector=$(grep "POSTGRES_PASSWORD" /root/pgvector.yaml | awk -F '=' '{print $2}')
            break
        else
            sleep 5
        fi
    done
}

pegar_user_senha_rabbitmq() {
    while :; do
        if [ -f /root/rabbitmq.yaml ]; then
            user_rabbit_mqs=$(grep "RABBITMQ_DEFAULT_USER" /root/rabbitmq.yaml | awk -F ': ' '{print $2}')
            senha_rabbit_mqs=$(grep "RABBITMQ_DEFAULT_PASS" /root/rabbitmq.yaml | awk -F ': ' '{print $2}')
            url_rabbit_mqs=$(grep "traefik.http.routers.rabbitmq.rule" /root/rabbitmq.yaml | awk -F'[`]' '{print $2}')
            break
        else
            sleep 5
            echo "erro"
        fi
    done
}

## Pegar senha Mysql

pegar_senha_mysql() {
    while :; do
        if [ -f /root/mysql.yaml ]; then
            senha_mysql=$(grep "MYSQL_ROOT_PASSWORD" /root/mysql.yaml | awk -F '=' '{print $2}')
            break
        else
            sleep 5
        fi
    done
}

## Pegar senha Minio

pegar_senha_minio() {
    user_minio=$(grep -i "MINIO_ROOT_USER" /root/minio.yaml | head -1 | sed 's/#.*//' | sed 's/.*=//; s/^[[:space:]]*//; s/[[:space:]]*$//')
    senha_minio=$(grep -i "MINIO_ROOT_PASSWORD" /root/minio.yaml | head -1 | sed 's/#.*//' | sed 's/.*=//; s/^[[:space:]]*//; s/[[:space:]]*$//')
    url_minio=$(grep -i "MINIO_BROWSER_REDIRECT_URL" /root/minio.yaml | head -1 | sed 's/#.*//' | sed 's/.*=//; s/^[[:space:]]*//; s/[[:space:]]*$//' | sed 's|https://||')
    url_s3=$(grep -i "MINIO_SERVER_URL" /root/minio.yaml | head -1 | sed 's/#.*//' | sed 's/.*=//; s/^[[:space:]]*//; s/[[:space:]]*$//' | sed 's|https://||')
}

pegar_senha_mongodb() {
  user_mongo=$(grep "MONGO_INITDB_ROOT_USERNAME" /root/mongodb.yaml | awk -F '=' '{print $2}')
  pass_mongo=$(grep "MONGO_INITDB_ROOT_PASSWORD" /root/mongodb.yaml | awk -F '=' '{print $2}')

}

## Pegar link S3
pegar_link_s3() {
    url_s3=$(grep -i "MINIO_SERVER_URL" /root/minio.yaml | head -1 | sed 's/#.*//' | sed 's/.*=//; s/^[[:space:]]*//; s/[[:space:]]*$//' | sed 's|https://||')
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Criadores de banco de dados Postgres
criar_banco_postgres_da_stack() {
    while :; do
        if docker ps -q --filter "name=^postgres_postgres" | grep -q .; then
            CONTAINER_ID=$(docker ps -q --filter "name=^postgres_postgres")

            # Verificar se o banco de dados ja existe
            docker exec "$CONTAINER_ID" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$1"

            if [ $? -eq 0 ]; then
                ## echo ""
                read -p "O banco de dados $1 ja existe. Deseja apagar e criar um novo banco de dados? (Y/N): " resposta
                if [ "$resposta" == "Y" ] || [ "$resposta" == "y" ]; then
                    # Apagar o banco de dados
                    docker exec "$CONTAINER_ID" psql -U postgres -c "DROP DATABASE IF EXISTS $1(force);" > /dev/null 2>&1
                    if [ $? -eq 0 ]; then
                    echo "" ## Sucesso
                    else
                        echo "" ## Erro
                    fi
                    # Criar o banco de dados novamente
                    docker exec "$CONTAINER_ID" psql -U postgres -c "CREATE DATABASE $1;" > /dev/null 2>&1
                else
                    echo ""
                fi
                break
            else
                # Criar o banco de dados
                docker exec "$CONTAINER_ID" psql -U postgres -c "CREATE DATABASE $1;" > /dev/null 2>&1
                
                # Verificar novamente se o banco de dados foi criado com sucesso
                docker exec "$CONTAINER_ID" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$1"

                if [ $? -eq 0 ]; then
                    nada="nada"
                    break
                else
                    echo "Erro ao criar o banco de dados. Tentando novamente..."
                    echo ""
                fi
            fi
        else
            sleep 5
        fi
    done
}

## Criar banco PgVector
criar_banco_pgvector_da_stack() {
    while :; do
        if docker ps -q --filter "name=^pgvector_pgvector" | grep -q .; then
            CONTAINER_PGVECTOR_ID=$(docker ps -q --filter "name=^pgvector_pgvector")

            # Verificar se o banco de dados ja existe
            docker exec "$CONTAINER_PGVECTOR_ID" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$1"

            if [ $? -eq 0 ]; then
                echo ""
                read -p "O banco de dados $1 ja existe. Deseja apagar e criar um novo banco de dados? (Y/N): " resposta
                if [ "$resposta" == "Y" ] || [ "$resposta" == "y" ]; then
                    # Apagar o banco de dados
                    docker exec "$CONTAINER_PGVECTOR_ID" psql -U postgres -c "DROP DATABASE IF EXISTS $1(force);" > /dev/null 2>&1
                    if [ $? -eq 0 ]; then
                    echo "" ## Sucesso
                    else
                        echo "" ## Erro
                    fi
                    # Criar o banco de dados novamente
                    docker exec "$CONTAINER_PGVECTOR_ID" psql -U postgres -c "CREATE DATABASE $1;" > /dev/null 2>&1
                else
                    echo ""
                fi
                break
            else
                # Criar o banco de dados
                docker exec "$CONTAINER_PGVECTOR_ID" psql -U postgres -c "CREATE DATABASE $1;" > /dev/null 2>&1
                
                # Verificar novamente se o banco de dados foi criado com sucesso
                docker exec "$CONTAINER_PGVECTOR_ID" psql -U postgres -lqt | cut -d \| -f 1 | grep -qw "$1"

                if [ $? -eq 0 ]; then
                    nada="nada"
                    break
                else
                    echo "Erro ao criar o banco de dados. Tentando novamente..."
                    echo ""
                fi
            fi
        else
            sleep 5
        fi
    done
}

## Criar banco MySQL
criar_banco_mysql_da_stack() {
    while :; do
        if docker ps -q --filter "name=^mysql_mysql" | grep -q .; then
            CONTAINER_ID=$(docker ps -q --filter "name=^mysql_mysql")

            # Verificar se o banco de dados ja existe
            docker exec -e MYSQL_PWD="$senha_mysql" "$CONTAINER_ID" mysql -u root \
                -e "SHOW DATABASES LIKE '$1';" | grep -qw "$1"

            if [ $? -eq 0 ]; then
                echo ""
                read -p "O banco de dados $1 ja existe. Deseja apagar e criar \
um novo banco de dados? (Y/N): " resposta
                if [ "$resposta" == "Y" ] || [ "$resposta" == "y" ]; then
                    # Apagar o banco de dados
                    docker exec -e MYSQL_PWD="$senha_mysql" "$CONTAINER_ID" mysql -u root \
                        -e "DROP DATABASE IF EXISTS $1;" > /dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        echo "" ## Sucesso
                    else
                        echo "" ## Erro
                    fi
                    # Criar o banco de dados novamente
                    docker exec -e MYSQL_PWD="$senha_mysql" "$CONTAINER_ID" mysql -u root \
                        -e "CREATE DATABASE $1;" > /dev/null 2>&1
                else
                    echo ""
                fi
                break
            else
                # Criar o banco de dados
                docker exec -e MYSQL_PWD="$senha_mysql" "$CONTAINER_ID" mysql -u root \
                    -e "CREATE DATABASE $1;" > /dev/null 2>&1

                # Verificar se o banco foi criado com sucesso
                docker exec -e MYSQL_PWD="$senha_mysql" "$CONTAINER_ID" mysql -u root \
                    -e "SHOW DATABASES LIKE '$1';" | grep -qw "$1"

                if [ $? -eq 0 ]; then
                    nada="nada"
                    break
                else
                    echo "Erro ao criar o banco de dados. Tentando novamente..."
                    echo ""
                fi
            fi
        else
            echo "Container MySQL nao encontrado. Tentando novamente..."
            echo ""
            sleep 5
        fi
    done
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

validar_senha() { 
    senha=$1
    tamanho_minimo=$2
    tem_erro=0
    mensagem_erro=""

    # Verifica comprimento minimo
    if [ ${#senha} -lt $tamanho_minimo ]; then
        mensagem_erro+="\n- Senha precisa ter no minimo $tamanho_minimo caracteres"
        tem_erro=1
    fi

    # Verifica letra maiuscula
    if ! [[ $senha =~ [A-Z] ]]; then
        mensagem_erro+="\n- Falta pelo menos uma letra maiuscula"
        tem_erro=1
    fi

    # Verifica letra minuscula
    if ! [[ $senha =~ [a-z] ]]; then
        mensagem_erro+="\n- Falta pelo menos uma letra minuscula"
        tem_erro=1
    fi

    # Verifica numero
    if ! [[ $senha =~ [0-9] ]]; then
        mensagem_erro+="\n- Falta pelo menos um numero"
        tem_erro=1
    fi

    # Verifica caracteres especiais permitidos
    if ! [[ $senha =~ [@_] ]]; then
        mensagem_erro+="\n- Falta pelo menos um caractere especial (@ ou _)"
        tem_erro=1
    fi

    # Verifica caracteres nao permitidos
    if [[ $senha =~ [^A-Za-z0-9@_] ]]; then
        mensagem_erro+="\n- Contem caracteres especiais nao permitidos (use apenas @ ou _)"
        tem_erro=1
    fi

    # Se houver erro, mostra as mensagens
    if [ $tem_erro -eq 1 ]; then
        echo -e "Senha invalida! Corrija os seguintes problemas:$mensagem_erro"
        return 1
    fi

    return 0
}

## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##
##                                         FELSEN SETUP                                        ##
## // ## // ## // ## // ## // ## // ## // ## //## // ## // ## // ## // ## // ## // ## // ## // ##

## Instalacao das Ferramentas

                                                                                  

                                                           

## ##| #####|   ##|   ##|        ##|   
                                    




armazenamento_livre() {
    df_output=$(df --output=used,avail,size --block-size=1G / | tail -n1)
    used=$(echo "$df_output" | awk '{print $1}')
    avail=$(echo "$df_output" | awk '{print $2}')
    total=$(echo "$df_output" | awk '{print $3}')
    percentage=$((100 * used / total))

    echo "$used $avail $total $percentage"
}

# Funcao principal
