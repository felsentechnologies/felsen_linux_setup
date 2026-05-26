#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

portainer.update() {

    echo ""
    echo "Atualizando Portainer..."

    # Passo 1: Executa o deploy com --prune e --resolve-image always
    docker stack deploy --prune --resolve-image always -c portainer.yaml portainer
    if [ $? -eq 0 ]; then
        echo "1/2 - [ OK ] - Comando de atualizacao enviado"
    else
        echo "1/2 - [ OFF ] - Erro ao atualizar o Portainer"
        echo "Verifique se o arquivo 'portainer.yaml' existe e esta correto."
        return 1
    fi

    # Passo 2: Espera a stack ficar online
    if wait_stack "portainer"; then
        sleep 20
        echo "2/2 - [ OK ] - Portainer esta online"
    else
        echo "2/2 - [ OFF ] - Portainer nao ficou online"
        echo "Verifique os logs para mais detalhes."
        return 1
    fi

    echo ""
    echo "Atualizacao concluida. Acesse o Portainer normalmente."
    echo ""
    sleep 3
}

