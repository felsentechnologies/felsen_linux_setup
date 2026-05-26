#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

chatwoot.mail() {

    echo ""
    echo "Aguarde enquanto trocamos os emails..."
    echo ""

    #cd /var/lib/docker/volumes/chatwoot_mailer/_data/app/views/devise/mailer/
    cd /var/lib/docker/volumes/chatwoot_mailer/_data/

    # Renomeia os arquivos
    mv password_change.html.erb password_change.html.erb.old > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "1/9 - [ OK ]"
    else
        echo "1/9 - [ OFF ]"
        echo "Nao foi possivel mudar email."
    fi
    mv confirmation_instructions.html.erb confirmation_instructions.html.erb.old > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "2/9 - [ OK ]"
    else
        echo "2/9 - [ OFF ]"
        echo "Nao foi possivel mudar email."
    fi
    mv reset_password_instructions.html.erb reset_password_instructions.html.erb.old > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "3/9 - [ OK ]"
    else
        echo "3/9 - [ OFF ]"
        echo "Nao foi possivel mudar email."
    fi
    mv unlock_instructions.html.erb unlock_instructions.html.erb.old > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "4/9 - [ OK ]"
    else
        echo "4/9 - [ OFF ]"
        echo "Nao foi possivel mudar email."
    fi
    
    # Baixa os novos arquivos
    wget -O confirmation_instructions.html.erb https://github.com/felsen-labs/linux-setup/raw/main/Extras/Chatwoot/emails/confirmation_instructions.html.erb > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "5/9 - [ OK ]"
    else
        echo "5/9 - [ OFF ]"
        echo "Nao foi possivel baixar email."
    fi
    wget -O password_change.html.erb https://github.com/felsen-labs/linux-setup/raw/main/Extras/Chatwoot/emails/password_change.html.erb > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "6/9 - [ OK ]"
    else
        echo "6/9 - [ OFF ]"
        echo "Nao foi possivel baixar email."
    fi
    wget -O reset_password_instructions.html.erb https://github.com/felsen-labs/linux-setup/raw/main/Extras/Chatwoot/emails/reset_password_instructions.html.erb > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "7/9 - [ OK ]"
    else
        echo "7/9 - [ OFF ]"
        echo "Nao foi possivel baixar email."
    fi
    wget -O unlock_instructions.html.erb https://github.com/felsen-labs/linux-setup/raw/main/Extras/Chatwoot/emails/unlock_instructions.html.erb > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "8/9 - [ OK ]"
    else
        echo "8/9 - [ OFF ]"
        echo "Nao foi possivel baixar email."
    fi
    
    cd
    cd

    # Deleta os containers do Chatwoot
    docker rm -f $(docker ps -a | grep 'chatwoot' | awk '{print $1}') > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo "9/9 - [ OK ]"
    else
        echo "9/9 - [ OFF ]"
        echo "Nao foi possivel deletar containers."
    fi

    echo ""
    echo "Esperando containers subir..."
    wait_30_sec

    echo ""
    echo "Concluido!"
    sleep 2
}

