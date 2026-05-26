#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ctop() {

    echo ""
    echo "Instalando CTOP"
    sudo wget https://github.com/bcicen/ctop/releases/download/v0.7.7/ctop-0.7.7-linux-amd64 -O /usr/local/bin/ctop
    if [ $? -eq 0 ]; then
        echo "1/2 - [ OK ] - Baixando CTOP"
    else
        echo "1/2 - [ OFF ] - Baixando CTOP"
        echo "Ops, nao foi possivel baixar o CTOP"
    fi

    sudo chmod +x /usr/local/bin/ctop
    if [ $? -eq 0 ]; then
        echo "2/2 - [ OK ] - Dando permissao ao CTOP"
    else
        echo "2/2 - [ OFF ] - Dando permissao ao CTOP"
        echo "Ops, nao foi possivel dar permissao ao CTOP"
    fi
    echo ""
    echo "Instalado, digite CTOP fora do nosso Setup oara executa-lo a qualquer momento."
    echo ""
    sleep 5

}

