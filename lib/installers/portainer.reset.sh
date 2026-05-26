#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

portainer.reset() {
    cd
    clear
    nome_portainer.reset
    echo "Aguarde enquanto reseto a senha do portainer..."
    echo ""

    docker service scale portainer_portainer=0 > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "1/7 - [ OK ]"
    else
        echo "1/7 - [ OFF ]"
        echo "Ops, nao foi possivel derrubar o servico do portainer"
    fi

    docker pull portainer/helper-reset-password > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "2/7 - [ OK ]"
    else
        echo "2/7 - [ OFF ]"
        echo "Ops, nao foi possivel super o servico de reset password do portainer"
    fi

    script -c "docker run --rm -v /var/lib/docker/volumes/portainer_data/_data:/data portainer/helper-reset-password" output.txt > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "3/7 - [ OK ]"
    else
        echo "3/7 - [ OFF ]"
        echo "Ops, nao foi possivel resetar a senha do portainer"
    fi

    cd
    #STACK_NAME="portainer"
    #stack_editavel > /dev/null 2>&1
    docker stack deploy --prune --resolve-image always -c portainer.yaml portainer > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "4/7 - [ OK ]"
    else
        echo "4/7 - [ OFF ]"
        echo "Ops, nao foi possivel subir a stack do portainer"
    fi

    USER=$(grep -oP 'user: \K[^,]*' output.txt)
    if [ $? -eq 0 ]; then
        echo "5/7 - [ OK ]"
    else
        echo "5/7 - [ OFF ]"
        echo "Ops, nao foi possivel pegar o usuario do portainer"
    fi

    PASSWORD=$(grep -oP 'login: \K.*' output.txt)
    if [ $? -eq 0 ]; then
        echo "6/7 - [ OK ]"
    else
        echo "6/7 - [ OFF ]"
        echo "Ops, nao foi possivel pegar a senha do portainer"
    fi

    rm output.txt
    if [ $? -eq 0 ]; then
        echo "7/7 - [ OK ]"
    else
        echo "7/7 - [ OFF ]"
        echo "Ops, nao foi possivel remover o arquivo output. txt ou ele nao existe"
    fi

    echo ""
    sleep 3
    clear
    nome_portainer.reset
    echo -e "\e[32m[ PORTAINER ]\e[0m"
    echo ""
    
    echo -e "\e[97mUsuario:\e[33m $USER\e[0m"
    echo ""
    
    echo -e "\e[97mNova Senha:\e[33m $PASSWORD\e[0m"
    
    ## Creditos do instalador
    creditos_msg

    read -p "Deseja voltar ao menu principal? (Y/N): " choice
    if [ "$choice" = "Y" ] || [ "$choice" = "y" ]; then
        return
    else
        cd
        cd
        clear
        exit 1
    fi
}

