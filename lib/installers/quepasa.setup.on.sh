#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

quepasa.setup.on(){
    echo ""
    echo "Ativando painel /setup do quepasa"
    mv /var/lib/docker/volumes/quepasa_volume/_data/views/setup.old /var/lib/docker/volumes/quepasa_volume/_data/views/setup.tmpl
    if [ $? -eq 0 ]; then
        echo "1/1 - [ OK ] - Painel /setup Ativado"
    else
        echo "1/1 - [ OFF ] - Erro ao Ativar painel"
        echo "Tente novamente mais tarde ou verifique se voce tem Quepasa instalado."
    fi
    echo ""
    echo "Voltando ao menu de ferramentas..."
    sleep 5
}

# Funcao para calcular espaco de disco
