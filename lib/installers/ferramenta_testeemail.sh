#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

ferramenta_testeemail() {
    clear
    dados
    nome_testeemail
    preencha_as_info

    while true; do
        echo -e "\e[97mPasso${amarelo} 1/5\e[0m"
        echo -en "\e[33mDigite o endereco de Email (ex: contato@example.com): \e[0m"
        read -r email_teste
        echo ""

        echo -e "\e[97mPasso${amarelo} 2/5\e[0m"
        echo -e "${amarelo}--> Caso nao tiver um usuario do email, use o proprio email abaixo"
        echo -en "\e[33mDigite o usuario de Email (ex: Felsen ou contato@example.com): \e[0m"
        read -r user_teste
        echo ""

        echo -e "\e[97mPasso${amarelo} 3/5\e[0m"
        echo -e "${amarelo}--> Sem caracteres especiais: !#$ | Se estiver usando Gmail, use a senha de app"
        echo -en "\e[33mDigite a Senha do email (ex: @Senha123_): \e[0m"
        read -r senha_teste
        echo ""

        echo -e "\e[97mPasso${amarelo} 4/5\e[0m"
        echo -en "\e[33mDigite o Host SMTP (ex: smtp.hostinger.com): \e[0m"
        read -r host_teste
        echo ""

        echo -e "\e[97mPasso${amarelo} 5/5\e[0m"
        echo -en "\e[33mDigite a Porta SMTP (ex: 465): \e[0m"
        read -r porta_teste
        echo ""

        clear
        nome_testeemail
        conferindo_as_info

        echo -e "\e[33mEmail SMTP: \e[97m$email_teste\e[0m"
        echo ""
        echo -e "\e[33mUsuario SMTP: \e[97m$user_teste\e[0m"
        echo ""
        echo -e "\e[33mSenha SMTP: \e[97m$senha_teste\e[0m"
        echo ""
        echo -e "\e[33mHost SMTP: \e[97m$host_teste\e[0m"
        echo ""
        echo -e "\e[33mPorta SMTP: \e[97m$porta_teste\e[0m"
        echo ""

        read -p "As respostas estao corretas? (Y/N): " confirmacao
        if [[ "$confirmacao" =~ ^[Yy]$ ]]; then
            clear
            nome_testando
            break
        else
            clear
            nome_testeemail
            preencha_as_info
        fi
    done

    # Mensagem de Inicio
    echo -e "\e[97m- INICIANDO VERIFICACAO \e[33m[1/3]\e[0m"
    echo ""

    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install swaks -y > /dev/null 2>&1

    msg="Se voce esta lendo isso, o seu SMTP esta funcionando =D.
By: Felsen"

    if swaks --to "$email_teste" --from "$email_teste" \
             --server "$host_teste" --port "$porta_teste" \
             --auth LOGIN --auth-user "$user_teste" \
             --auth-password "$senha_teste" --tls \
             --header "Subject:  Teste de SMTP - Felsen" \
             --header "Content-Type: text/plain; charset=UTF-8" \
             --body "$msg"; then

        sleep 2
        clear
        nome_testeemail
        echo -e "\e[32m[Resultado do Teste SMTP]\e[0m"
        echo ""
        echo -e "\e[33mOs dados informados \e[92mestao funcionando corretamente\e[33m.\e[0m"

    else
        sleep 2
        clear
        nome_testeemail
        echo -e "\e[32m[Resultado do Teste SMTP]\e[0m"
        echo ""
        echo -e "\e[33mOs dados informados \e[91mNAO estao funcionando corretamente\e[33m. Por favor, verifique os dados e tente novamente.\e[0m"
    fi
        echo ""
        echo -e "\e[33mEmail SMTP: \e[97m$email_teste\e[0m"
        echo ""
        echo -e "\e[33mUsuario SMTP: \e[97m$user_teste\e[0m"
        echo ""
        echo -e "\e[33mSenha SMTP: \e[97m$senha_teste\e[0m"
        echo ""
        echo -e "\e[33mHost SMTP: \e[97m$host_teste\e[0m"
        echo ""
        echo -e "\e[33mPorta SMTP: \e[97m$porta_teste\e[0m"

    creditos_msg

    read -p "Deseja instalar outra aplicacao? (Y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        return
    else
        cd || exit
        clear
        exit 1
    fi
}

##   ################  ###### ######################  ###    ########     
##   a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-'a-a-a-' a-a-a-"a-    a-a-a-"a-a-a-a-a-     
##      a-a-a-'   a-a-a-a-a-a-a-"a-a-a-a-a-a-a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a--  a-a-a-'a-a-a-a-a-a-"a-     a-a-a-a-a-a--       
##      a-a-a-'   a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-  a-a-a-'a-a-a-"a-a-a-a--     a-a-a-"a-a-a-       
##      ##|   ##|  ##|##|  ##|##########|     ##|##|  ###    ########     
##      a-a-a-   a-a-a-  a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-     a-a-a-a-a-a-  a-a-a-    a-a-a-a-a-a-a-a-     
##                                                                        
## #######  ####### ####### ######### ###### #######   ################## 
## a-a-a-"a-a-a-a-a--a-a-a-"a-a-a-a-a-a--a-a-a-"a-a-a-a-a--a-a-a-a-a-a-"a-a-a-a-a-a-"a-a-a-a-a--a-a-a-'a-a-a-a-a--  a-a-a-'a-a-a-"a-a-a-a-a-a-a-a-"a-a-a-a-a--
## a-a-a-a-a-a-a-"a-a-a-a-'   a-a-a-'a-a-a-a-a-a-a-"a-   a-a-a-'   a-a-a-a-a-a-a-a-'a-a-a-'a-a-a-"a-a-a-- a-a-a-'a-a-a-a-a-a--  a-a-a-a-a-a-a-"a-
## a-a-a-"a-a-a-a- a-a-a-'   a-a-a-'a-a-a-"a-a-a-a-a--   a-a-a-'   a-a-a-"a-a-a-a-a-'a-a-a-'a-a-a-'a-a-a-a--a-a-a-'a-a-a-"a-a-a-  a-a-a-"a-a-a-a-a--
## a-a-a-'     a-a-a-a-a-a-a-a-"a-a-a-a-'  a-a-a-'   a-a-a-'   a-a-a-'  a-a-a-'a-a-a-'a-a-a-' a-a-a-a-a-a-'a-a-a-a-a-a-a-a--a-a-a-'  a-a-a-'
## a-a-a-      a-a-a-a-a-a-a- a-a-a-  a-a-a-   a-a-a-   a-a-a-  a-a-a-a-a-a-a-a-a-  a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-a-  a-a-a-

