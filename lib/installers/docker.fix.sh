#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

docker.fix(){

echo ""
echo "Iniciando a correcao no Docker"
echo ""

sudo mkdir -p /etc/systemd/system/docker.service.d
if [ $? -eq 0 ]; then
    echo "1/6 - [ OK ] - Criando diretorio de configuracao do Docker"
else
    echo "1/6 - [ OFF ] - Criando diretorio de configuracao do Docker"
fi

sudo bash -c 'cat > /etc/systemd/system/docker.service.d/override.conf <<__FELSEN_MANAGED_FILE__
[Service]
Environment=DOCKER_MIN_API_VERSION=1.24
__FELSEN_MANAGED_FILE__'
if [ $? -eq 0 ]; then
    echo "2/6 - [ OK ] - Criando arquivo de configuracao do Docker"
else
    echo "2/6 - [ OFF ] - Criando arquivo de configuracao do Docker"
fi

sudo systemctl daemon-reexec > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "3/6 - [ OK ] - Aplicando override no systemd do Docker"
else
    echo "3/6 - [ OFF ] - Aplicando override no systemd do Docker"
fi
sudo systemctl daemon-reload > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "4/6 - [ OK ] - Recarregando as configuracoes do systemd"
else
    echo "4/6 - [ OFF ] - Recarregando as configuracoes do systemd"
fi
sudo systemctl restart docker > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "5/6 - [ OK ] - Reiniciando o servico Docker"
else
    echo "5/6 - [ OFF ] - Reiniciando o servico Docker"
fi

ENV_VALUE=$(systemctl show --property=Environment docker | grep -o "DOCKER_MIN_API_VERSION=1.24" || true)
if [ "$ENV_VALUE" == "DOCKER_MIN_API_VERSION=1.24" ]; then
    echo "6/6 - [ OK ] - Correcao aplicada"
    sleep 5
else
    echo "6/6 - [ OFF ] - Correcao NAO aplicada"
    sleep 5
fi

### Detectar SO e codename
#OS_ID=$(source /etc/os-release && echo "$ID")
#OS_CODENAME=$(source /etc/os-release && echo "$VERSION_CODENAME")
#
## Instalar dependencias basicas
#sudo apt update
#sudo apt install -y ca-certificates curl gnupg lsb-release
#
### Configurar repositorio oficial do Docker
#sudo mkdir -p /etc/apt/keyrings
#sudo rm -f /etc/apt/keyrings/docker.gpg
#curl -fsSL https://download.docker.com/linux/$OS_ID/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
#echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_ID $OS_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
#
#sudo apt update
#
### Versao problematica que queremos evitar
#BAD_VERSION="5:28.5.2"
#
### Buscar versao mais proxima (menor ou igual a BAD_VERSION)
#DOCKER_VERSION=$(apt-cache madison docker-ce \
#    | awk '{print $3}' \
#    | grep -E '^5:28\.5\.[0-1]-' \
#    | sort -Vr \
#    | head -n1)
#
#if [ -z "$DOCKER_VERSION" ]; then
#    echo "Nao foi possivel encontrar uma versao estavel proxima. Instalando a ultima disponivel..."
#    sudo apt install -y docker-ce docker-ce-cli containerd.io
#else
#    echo "Instalando Docker versao estavel proxima: $DOCKER_VERSION"
#    sudo apt install --allow-downgrades -y \
#        docker-ce=$DOCKER_VERSION \
#        docker-ce-cli=$DOCKER_VERSION \
#        containerd.io
#    # Travar versao
#    sudo apt-mark hold docker-ce docker-ce-cli containerd.io
#fi
#
### Verificar instalacao
#docker --version
#
#echo ""
#echo "Pode ser necessario reiniciar a VPS com o comando 'reboot' para ter efeito"
#echo ""
#sleep 10
}

