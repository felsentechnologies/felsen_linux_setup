#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

criar_arquivo() {
    if [ -f "/root/dados_vps/dados_portainer" ]; then
        rm "/root/dados_vps/dados_portainer"
        echo "Arquivo existente removido."
    fi

    ## Caso nao exista o arquivo ele vai pedir os dados para criar.
    nome_credenciais
    echo -e "\e[97mPasso$amarelo 1/3\e[0m"
    #echo -e "\e[97mObs: Coloque o https:// antes do link do portainer\e[0m"
    read -p "Digite a Url do Portainer (ex: portainer.example.com): " PORTAINER_URL
    echo ""

    echo -e "\e[97mPasso$amarelo 2/3\e[0m"
    read -p "Digite seu Usuario (ex: admin): " USUARIO
    echo ""

    echo -e "\e[97mPasso$amarelo 3/3\e[0m"
    echo -e "\e[97mObs: A Senha nao aparecera ao digitar\e[0m"
    read -s -p "Digite a Senha (ex: @Senha123_): " SENHA
    echo ""

    verificar_token "$PORTAINER_URL" "$USUARIO" "$SENHA" true
}


## Funcao para verificar os campos do arquivo de dados do Portainer
