#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

docker.fix2() {
## Detectar SO e codename
OS_ID=$(source /etc/os-release && echo "$ID")
OS_CODENAME=$(source /etc/os-release && echo "$VERSION_CODENAME")

# Instalar dependencias basicas
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release

## Configurar repositorio oficial do Docker
sudo mkdir -p /etc/apt/keyrings
sudo rm -f /etc/apt/keyrings/docker.gpg
curl -fsSL https://download.docker.com/linux/$OS_ID/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS_ID $OS_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

## Versao problematica que queremos evitar
BAD_VERSION="5:28.5.2"

## Buscar versao mais proxima (menor ou igual a BAD_VERSION)
DOCKER_VERSION=$(apt-cache madison docker-ce \
    | awk '{print $3}' \
    | grep -E '^5:28\.5\.[0-1]-' \
    | sort -Vr \
    | head -n1)

if [ -z "$DOCKER_VERSION" ]; then
    echo "Nao foi possivel encontrar uma versao estavel proxima. Instalando a ultima disponivel..."
    sudo apt install -y docker-ce docker-ce-cli containerd.io
else
    echo "Instalando Docker versao estavel proxima: $DOCKER_VERSION"
    sudo apt install --allow-downgrades -y \
        docker-ce=$DOCKER_VERSION \
        docker-ce-cli=$DOCKER_VERSION \
        containerd.io
    # Travar versao
    sudo apt-mark hold docker-ce docker-ce-cli containerd.io
fi

## Verificar instalacao
docker --version

echo ""
echo "Pode ser necessario reiniciar a VPS com o comando 'reboot' para ter efeito"
echo ""
sleep 10
}

# Funcao completa com ajustes de politica para o bucket
