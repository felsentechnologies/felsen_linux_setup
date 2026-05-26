#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_traefik_e_portainer() {

## Verifica os recursos
recursos 1 1 || return

## Limpa o terminal
clear

## Mostra o nome da aplicacao
nome_traefik_e_portainer

## Mostra mensagem para preencher informacoes
preencha_as_info

## Inicia um Loop ate os dados estarem certos
while true; do

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 1/6\e[0m"
    echo -en "\e[33mDigite o Dominio para o Portainer (ex: portainer.example.com): \e[0m" && read -r url_portainer
    echo ""

    ##Pergunta o Dominio para aplicacao
    echo -e "\e[97mPasso$amarelo 2/6\e[0m"
    echo -en "\e[33mDigite um usuario para o Portainer (ex: admin): \e[0m" && read -r user_portainer
    echo ""

    ##Pergunta o Dominio para aplicacao
    while true; do
      echo -e "\e[97mPasso$amarelo 3/6\e[0m"
      echo -e "$amarelo--> Minimo 12 caracteres. Use Letras MAIUSCULAS e minusculas, numero e um caractere especial @ ou _"
      echo -e "$amarelo--> Evite os caracteres especiais como: \!#$"
      echo -en "\e[33mDigite uma senha para o Portainer (ex: @Senha123456_): \e[0m" && read -r pass_portainer
      echo ""

      if validar_senha "$pass_portainer" 12; then
          break
      fi
      echo ""
    done

    ## Pergunta o Nome do Servidor
    echo -e "\e[97mPasso$amarelo 4/6\e[0m"
    echo -e "$amarelo--> Nao pode conter Espacos e/ou cartacteres especiais"
    echo -en "\e[33mEscolha um nome para o seu servidor (ex: Felsen): \e[0m" && read -r nome_servidor
    echo ""
    
    ## Pergunta o nome da Rede Interna
    echo -e "\e[97mPasso$amarelo 5/6\e[0m"
    echo -e "$amarelo--> Nao pode conter Espacos e/ou cartacteres especiais."
    echo -en "\e[33mDigite um nome para sua rede interna (ex: FELSENNet): \e[0m" && read -r nome_rede_interna
    echo ""
    
    ## Pergunta o Email para informacoes sobre o certificado
    echo -e "\e[97mPasso$amarelo 6/6\e[0m"
    echo -en "\e[33mDigite um endereco de Email valido (ex: contato@example.com): \e[0m" && read -r email_ssl
    echo ""

    ## Limpa o termianl
    clear

    ## Mostra o nome da aplicacao
    nome_traefik_e_portainer

    ## Mostra mensagem para verificar as informacoes
    conferindo_as_info

    ## Informacao sobre URL
    echo -e "\e[33mLink do Portainer:\e[97m $url_portainer\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mUsuario do Portainer:\e[97m $user_portainer\e[0m"
    echo ""

    ## Informacao sobre URL
    echo -e "\e[33mSenha do Portainer:\e[97m $pass_portainer\e[0m"
    echo ""

    ## Informacao sobre Nome do Servidor
    echo -e "\e[33mNome do Servidor:\e[97m $nome_servidor\e[0m"
    echo ""

    ## Informacao sobre Nome da Rede interna
    echo -e "\e[33mRede interna:\e[97m $nome_rede_interna\e[0m"
    echo ""

    ## Informacao sobre Email
    echo -e "\e[33mEmail:\e[97m $email_ssl\e[0m"
    echo ""
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
        nome_traefik_e_portainer

        ## Mostra mensagem para preencher informacoes
        preencha_as_info

    ## Volta para o inicio do loop com as perguntas
    fi
done

## Mensagem de Passo
echo -e "\e[97m- INICIANDO A INSTALACAO DO TRAEFIK \e[33m[1/9]\e[0m"
echo ""
sleep 1

## Neste passo vamos estar salvando os dados preenchidos anteriormente para que o instalador possa usar posteriormente na instalacao de qualquer ferramenta.

## Garante que o usuario esteja no /root/
cd
cd

## Verifica se ja nao existe uma pasta chamada "dados_vps", se existir ele ignora e se nao existir ele cria uma
## Esta foi uma PR que veio do usuario Fabio => https://github.com/hipnologo

if [ ! -d "dados_vps" ]; then
    mkdir dados_vps
fi

## Fim da PR

## Abre a pasta dados_vps
cd dados_vps

## Cria um arquivo chamado "dados_vps" com: "nome do servidor", "nome da rede interna", "email", "link do portainer"
cat > dados_vps <<__FELSEN_MANAGED_FILE__
[DADOS DA VPS]

Estes dados foram preenchidos na hora que voce foi instalar o Traefik e Portainer e
serao utilizados para realizar as instalacoes no do Felsen Linux Setup v.2

Nome do Servidor: $nome_servidor

Rede interna: $nome_rede_interna

Email para SSL: $email_ssl

Link do Portainer: $url_portainer

Obrigado por utilizar nosso AutoInstalador.
Caso esse conteudo foi util, nao deixe de apoiar nosso projeto.



Bebam agua!
__FELSEN_MANAGED_FILE__
## Volta para /root/
cd
cd

## Ativa a funcao dados para pegar os dados da vps
dados

## Mensagem de Passo
echo -e "\e[97m- ATUALIZANDO E CONFIGURANDO A VPS \e[33m[2/9]\e[0m"
echo ""
sleep 1

## Neste passo vamos estar Atualizando e configurando a vps para conseguir rodar nosso setup

## Todos os passo que estao com "> /dev/null 2>&1" Sao para nao mostrar os logs.

## Fiz isso com o intuito de melhorar a visualizacao deixando o terminal apenas com os passos pre descritos

## Vou adicionar uma verificacao com echo e o passo caso der algum problema para verificar.

sudo apt-get update > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/9 - [ OK ] - Update"
else
    echo "1/9 - [ OFF ] - Update"
fi
sudo apt upgrade -y > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "2/9 - [ OK ] - Upgrade"
else
    echo "2/9 - [ OFF ] - Upgrade"
fi
sudo timedatectl set-timezone America/Sao_Paulo > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "3/9 - [ OK ] - Timezone"
else
    echo "3/9 - [ OFF ] - Timezone"
fi
sudo apt-get install -y apt-utils > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "4/9 - [ OK ] - Apt-Utils"
else
    echo "4/9 - [ OFF ] - Apt-Utils"
fi
sudo apt-get update > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "5/9 - [ OK ] - Update"
else
    echo "5/9 - [ OFF ] - Update"
fi
hostnamectl set-hostname $nome_servidor > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "6/9 - [ OK ] - Set Hostname"
else
    echo "6/9 - [ OFF ] - Set Hostname"
fi
sudo sed -i "s/127.0.0.1[[:space:]]localhost/127.0.0.1 $nome_servidor/g" /etc/hosts > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "7/9 - [ OK ] - Adicionando nome do servidor em etc/hosts"
else
    echo "7/9 - [ OFF ] - Adicionando nome do servidor em etc/hosts"
fi
sudo apt-get update > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "8/9 - [ OK ] - Update"
else
    echo "8/9 - [ OFF ] - Update"
fi
sudo apt-get install -y apparmor-utils > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "9/9 - [ OK ] - Apparmor-Utils"
else
    echo "9/9 - [ OFF ] - Apparmor-Utils"
fi
echo ""

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO DOCKER SWARM \e[33m[3/9]\e[0m"
echo ""
sleep 1


## Nesse passo vamos estar instalando docker no modo swarm


# IP publico externo removido por privacidade
read -r ip _ <<< "$(hostname -I | tr ' ' '\n' | grep -v '^127\.0\.0\.1' | grep -v '^10\.0\.0\.' | tr '\n' ' ')"
if [ $? -eq 0 ]; then
    echo "1/4 - [ OK ] - Pegando IP $ip"
else
    echo "1/4 - [ OFF ] - Pegando IP $ip"
fi

## Tentando instalar Docker com get.docker.com
curl -fsSL https://get.docker.com | bash > /dev/null 2>&1
systemctl enable docker > /dev/null 2>&1
systemctl start docker > /dev/null 2>&1

if docker --version > /dev/null 2>&1; then
    echo "2/4 - [ OK ] - Baixando e Instalando Docker"
else
    #echo "2/4 - [ OFF ] - Falha ao instalar Docker"
    #echo "Tentando instalacao manual do Docker..."

    ## Instala dependencias
    sudo apt-get install -y ca-certificates curl gnupg lsb-release > /dev/null 2>&1

    ## Adiciona chave GPG
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    ## Adiciona repositorio do Docker
    echo \
      "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      focal stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    ## Atualiza pacotes
    sudo apt-get update > /dev/null 2>&1

    ## Instala Docker
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin > /dev/null 2>&1
    systemctl enable docker > /dev/null 2>&1
    systemctl start docker > /dev/null 2>&1

    if docker --version > /dev/null 2>&1; then
        echo "2/4 - [ OK ] - Baixando e Instalando Docker"
    else
        echo "2/4 - [ OFF ] - Falha ao instalar Docker"
        exit 1
    fi
fi

sleep 5

## Inicializando Docker Swarm
max_attempts=3
attempt=0

while [ $attempt -le $max_attempts ]; do
    docker swarm init --advertise-addr $ip > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "3/4 - [ OK ] - Iniciando Swarm"
        break
    else
        echo "3/4 - [ OFF ] - Iniciando Swarm"
        echo "Ops, nao foi possivel iniciar o Swarm, tentativa $attempt de $max_attempts"
        attempt=$((attempt + 1))
        sleep 5
    fi
done

if [ $attempt -gt $max_attempts ]; then
    echo "4/4 - [ FAIL ] - Nao foi possivel iniciar o Swarm apos $max_attempts tentativas..."
    echo "Recomendo formatar a VPS e tentar novamente"
    echo "Lembre-se que o primeiro requisito e estar usando uma VPS Vazia."
    sleep 10
    exit 1
else
    echo "4/4 - [ OK ] - Docker e Swarm configurados com sucesso!"
fi

echo ""

docker.fix > /dev/null 2>&1


## Mensagem de Passo
echo -e "\e[97m- CRIANDO REDE INTERNA \e[33m[4/9]\e[0m"
echo ""
sleep 1

## Neste passo vamos criar a rede interna para utilizar nas demais aplicacoes

docker network create --driver=overlay $nome_rede_interna > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1/1 - [ OK ] - Rede Interna"
else
    echo "1/1 - [ OFF ] - Rede Interna"
fi
echo ""

## Mensagem de Passo
echo -e "\e[97m- INSTALANDO TRAEFIK \e[33m[5/9]\e[0m"
echo ""
sleep 1


## Neste passo vamos estar criando a Stack yaml do traefik na pasta /root/
## Isso possibilitara que o usuario consiga edita-lo posteriormente

## Depois vamos instalar o traefik e verificar se esta tudo certo.

## Criando a stack traefik.yaml
cat > traefik.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  traefik:
    image: traefik:v3.5.3
    command:
      - "--api.dashboard=true"
      - "--providers.swarm=true"
      - "--providers.docker.endpoint=unix:///var/run/docker.sock"
      - "--providers.docker.exposedbydefault=false"
      - "--providers.docker.network=$nome_rede_interna" ## Nome da rede interna
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      - "--entrypoints.web.http.redirections.entrypoint.permanent=true"
      - "--entrypoints.websecure.address=:443"
      - "--entrypoints.web.transport.respondingTimeouts.idleTimeout=3600"
      - "--certificatesresolvers.letsencryptresolver.acme.httpchallenge=true"
      - "--certificatesresolvers.letsencryptresolver.acme.httpchallenge.entrypoint=web"
      - "--certificatesresolvers.letsencryptresolver.acme.storage=/etc/traefik/letsencrypt/acme.json"
      - "--certificatesresolvers.letsencryptresolver.acme.email=$email_ssl" ## Email para receber as notificacoes
      - "--log.level=DEBUG"
      - "--log.format=common"
      - "--log.filePath=/var/log/traefik/traefik.log"
      - "--accesslog=true"
      - "--accesslog.filepath=/var/log/traefik/access-log"

    volumes:
      - "vol_certificates:/etc/traefik/letsencrypt"
      - "/var/run/docker.sock:/var/run/docker.sock:ro"

    networks:
      - $nome_rede_interna ## Nome da rede interna

    ports:
      - target: 80
        published: 80
        mode: host
      - target: 443
        published: 443
        mode: host

    deploy:
      placement:
        constraints:
          - node.role == manager
      labels:
        - "traefik.enable=true"
        - "traefik.http.middlewares.redirect-https.redirectscheme.scheme=https"
        - "traefik.http.middlewares.redirect-https.redirectscheme.permanent=true"
        - "traefik.http.routers.http-catchall.rule=Host(\`{host:.+}\`)"
        - "traefik.http.routers.http-catchall.entrypoints=web"
        - "traefik.http.routers.http-catchall.middlewares=redirect-https@docker"
        - "traefik.http.routers.http-catchall.priority=1"

## --------------------------- FELSEN --------------------------- ##

volumes:
  vol_shared:
    external: true
    name: volume_swarm_shared
  vol_certificates:
    external: true
    name: volume_swarm_certificates

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    attachable: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/2 - [ OK ] - Criando Stack"
else
    echo "1/2 - [ OFF ] - Criando Stack"
    echo "Ops, nao foi possivel criar a stack do Traefik"
fi

docker stack deploy --prune --resolve-image always -c traefik.yaml traefik > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "2/2 - [ OK ] - Deploy Stack"
else
    echo "2/2 - [ OFF ] - Deploy Stack"
    echo "Ops, nao foi possivel subir o Traefik."
fi

echo ""
## Mensagem de Passo
echo -e "\e[97m- ESPERANDO O TRAEFIK ESTAR ONLINE \e[33m[6/9]\e[0m"
echo ""
sleep 1

## Em teste contra Rate Limit do Docker Hub
pull ghcr.io/traefik/traefik:v3.5.3

docker tag ghcr.io/traefik/traefik:v3.5.3 traefik/traefik:v3.5.3

## Usa o servico wait_stack "traefik" para verificar se o servico esta online
wait_stack "traefik"

## Espera 30 segundos
wait_30_sec
echo ""
## Mensagem de Passo
echo -e "\e[97m- INSTALANDO PORTAINER \e[33m[7/9]\e[0m"
echo ""
sleep 1


## Neste passo vamos estar criando a Stack yaml do Portainer na pasta /root/
## Isso possibilitara que o usuario consiga edita-lo posteriormente

## Depois vamos instalar o Portainer e verificar se esta tudo certo.

## Criando a stack portainer.yaml
cat > portainer.yaml <<__FELSEN_MANAGED_FILE__
version: "3.7"
services:

## --------------------------- FELSEN --------------------------- ##

  agent:
    image: portainer/agent:latest ## Versao Agent do Portainer

    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes

    networks:
      - $nome_rede_interna ## Nome da rede interna

    deploy:
      mode: global
      placement:
        constraints: [node.platform.os == linux]

## --------------------------- FELSEN --------------------------- ##

  portainer:
    image: portainer/portainer-ce:latest ## Versao do Portainer
    command: -H tcp://tasks.agent:9001 --tlsskipverify

    volumes:
      - portainer_data:/data

    networks:
      - $nome_rede_interna ## Nome da rede interna

    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.role == manager]
      labels:
        - "traefik.enable=true"
        - "traefik.http.routers.portainer.rule=Host(\`$url_portainer\`)" ## Dominio do Portainer
        - "traefik.http.services.portainer.loadbalancer.server.port=9000"
        - "traefik.http.routers.portainer.tls.certresolver=letsencryptresolver"
        - "traefik.http.routers.portainer.service=portainer"
        - "traefik.docker.network=$nome_rede_interna" ## Nome da rede interna
        - "traefik.http.routers.portainer.entrypoints=websecure"
        - "traefik.http.routers.portainer.priority=1"

## --------------------------- FELSEN --------------------------- ##

volumes:
  portainer_data:
    external: true
    name: portainer_data

networks:
  $nome_rede_interna: ## Nome da rede interna
    external: true
    attachable: true
    name: $nome_rede_interna ## Nome da rede interna
__FELSEN_MANAGED_FILE__
if [ $? -eq 0 ]; then
    echo "1/2 - [ OK ] - Criando Stack"
else
    echo "1/2 - [ OFF ] - Criando Stack"
    echo "Ops, nao foi possivel criar a stack do Portainer"
fi

docker stack deploy --prune --resolve-image always -c portainer.yaml portainer > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "2/2 - [ OK ] - Deploy Stack"
else
    echo "2/2 - [ OFF ] - Deploy Stack"
    echo "Ops, nao foi possivel Subir a stack do Portainer"
fi

echo ""
## Mensagem de Passo
echo -e "\e[97m- ESPERANDO O PORTAINER ESTAR ONLINE \e[33m[8/9]\e[0m"
echo ""
sleep 1

pull portainer/agent:latest portainer/portainer-ce:latest

## Usa o servico wait_portainer para verificar se o servico esta online
wait_stack "portainer"

sleep 5


echo ""
## Mensagem de Passo
echo -e "\e[97m- CRIANDO CONTA NO PORTAINER \e[33m[9/9]\e[0m"
echo ""
sleep 30

## Tenta criar usuario no Portainer ate 4 vezes
MAX_RETRIES=4
DELAY=15  # Delay de 15 segundos entre as tentativas
CONTA_CRIADA=false

for i in $(seq 1 $MAX_RETRIES); do
  RESPONSE=$(curl -k -s -X POST "https://$url_portainer/api/users/admin/init" \
    -H "Content-Type: application/json" \
    -d "{\"Username\": \"$user_portainer\", \"Password\": \"$pass_portainer\"}")

  # Verificar se o campo "Username" existe na resposta
  if echo "$RESPONSE" | grep -q "\"Username\":\"$user_portainer\""; then
    echo "1/2 - [ OK ] - Conta de administrador criada com sucesso!"
    CONTA_CRIADA=true
    break
  else
    echo "Tentando criar conta no Portainer $i/4."
    # Se for a ultima tentativa, exibe mensagem de erro final
    if [ $i -eq $MAX_RETRIES ]; then
      echo "1/2 - [ OFF ] - Nao foi possivel criar a conta de administrador apos $MAX_RETRIES tentativas."
      echo "Erro retornado: $RESPONSE"
      echo -e "\e[33mApos a conclusao da instalacao, por favor, crie uma conta acessando o link do seu Portainer"
      CONTA_CRIADA=false
      sleep 10
    fi
    sleep $DELAY
  fi
done

# So tenta criar o token se a conta foi criada com sucesso
if [ "$CONTA_CRIADA" = true ]; then
  sleep 5
  ## Cria primeiro token do Portainer
  token=$(curl -k -s -X POST "https://$url_portainer/api/auth" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$user_portainer\",\"password\":\"$pass_portainer\"}" | jq -r .jwt)
  
  # Verifica se o token foi gerado com sucesso
  if [ -n "$token" ] && [ "$token" != "null" ]; then
    echo "2/2 - [ OK ] - Gerando primeiro token"
  else
    echo "2/2 - [ OFF ] - Falha ao gerar o token"
    exit 1
  fi
fi

sleep 5
## Salvando informacoes da instalacao dentro de /dados_vps/
cd dados_vps

if [ "$CONTA_CRIADA" = true ]; then
  cat > dados_portainer <<__FELSEN_MANAGED_FILE__
[ PORTAINER ]

Dominio do portainer: https://$url_portainer

Usuario: $user_portainer

Senha: $pass_portainer

Token: $token
__FELSEN_MANAGED_FILE__
else
  cat > dados_portainer <<__FELSEN_MANAGED_FILE__
[ PORTAINER ]

Dominio do portainer: https://$url_portainer

Usuario: Precisa criar dentro do portainer

Senha: Precisa criar dentro do portainer
__FELSEN_MANAGED_FILE__
fi

cd
cd

## Espera 30 segundos
wait_30_sec

## Mensagem de finalizado
instalado_msg

## Mensagem de Guarde os Dados
guarde_os_dados_msg

## Dados da Aplicacao:
echo -e "\e[32m[ PORTAINER ]\e[0m"
echo ""

echo -e "\e[97mDominio do portainer:\e[33m https://$url_portainer\e[0m"
echo ""

if [ "$CONTA_CRIADA" = true ]; then
  echo -e "\e[97mUsuario:\e[33m $user_portainer\e[0m"
  echo ""
  echo -e "\e[97mSenha:\e[33m $pass_portainer\e[0m"
else
  echo -e "\e[97mUsuario:\e[33m Precisa criar dentro do portainer\e[0m"
  echo ""
  echo -e "\e[97mSenha:\e[33m Precisa criar dentro do portainer\e[0m"
  echo ""
  echo -e "\e[97mObservacao:\e[33m Voce tem menos de 5 minutos para criar uma conta no Portainer, caso\e[0m"
  echo -e "\e[33mexceda esse tempo, voce precisara de voltar no menu anterior (digitando: Y)\e[0m"
  echo -e "\e[33me no menu de ferramentas digitar: \e[97mportainer.restart\e[0m"
fi
#echo ""

#echo -e "\e[97mObservacao:\e[33m Voce tem menos de 5 minutos para criar uma conta no Portainer, caso\e[0m"
#echo -e "\e[33mexceda esse tempo, voce precisara de voltar no menu anterior (digitando: Y)\e[0m"
#echo -e "\e[33me no menu de ferramentas digitar: \e[97mportainer.restart\e[0m"

## Creditos do instalador
creditos_msg

## Pergunta se deseja instalar outra aplicacao
requisitar_outra_instalacao
}

## #######  ####### ################# ####### ####### ################
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a- a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-
## a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a--   a-a-a-'   a-a-a-'  a-a-a-a--a-a-a-a-a-a-a-"a-a-a-a-a-a-a--  a-a-a-a-a-a-a-a--
## a-a-a-"a-a-a-a- a-a-a-'   a-a-a-'a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-  a-a-a-a-a-a-a-a-'
## a-a-a-'     a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'   a-a-a-'   a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'a-a-a-a-a-a-a-a--a-a-a-a-a-a-a-a-'
## a-a-a-      a-a-a-a-a-a-a- a-a-a-a-a-a-a-a-   a-a-a-    a-a-a-a-a-a-a- a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-

