#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

htop() {

    echo ""
    echo "Instalando HTOP"

    # Atualiza o repositorio e instala o htop
    sudo apt-get update -y >/dev/null 2>&1
    sudo apt-get install -y htop >/dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "1/1 - [ OK ] - Instalando HTOP"
        echo ""
        echo "Instalado, digite HTOP fora do nosso Setup para executa-lo a qualquer momento."
    else
        echo "1/1 - [ OFF ] - Instalando HTOP"
        echo "Ops, nao foi possivel instalar o HTOP"
    fi

    echo ""
    sleep 5
}

