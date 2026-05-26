#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

quepasa.setup.off(){
    echo ""
    echo "Desativando painel /setup do quepasa"
    mv /var/lib/docker/volumes/quepasa_volume/_data/views/setup.tmpl /var/lib/docker/volumes/quepasa_volume/_data/views/setup.old
    if [ $? -eq 0 ]; then
        echo "1/1 - [ OK ] - Painel /setup Desativado"
    else
        echo "1/1 - [ OFF ] - Erro ao desativar painel"
        echo "Tente novamente mais tarde ou verifique se voce tem Quepasa instalado."
    fi
    echo ""
    echo "Voltando ao menu de ferramentas..."
    sleep 5
}

