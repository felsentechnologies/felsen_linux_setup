#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

portainer.restart() {

    echo ""
    echo "Aguarde enquanto reiniciamos o Portainer"
    echo ""
    docker service update --force $(docker service ls --filter name='portainer_agent' -q) > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "1/2 - [ OK ]"
    else
        echo "1/2 - [ OFF ]"
        echo "Nao foi possivel reiniciar o portainer"
    fi
    docker service update --force $(docker service ls --filter name='portainer_portainer' -q) > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "2/2 - [ OK ]"
    else
        echo "2/2 - [ OFF ]"
        echo "Nao foi possivel reiniciar o portainer"
    fi
    sleep 2
    clear
}

