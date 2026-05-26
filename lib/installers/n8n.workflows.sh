#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

n8n.workflows(){
while true; do
    if docker ps -q --filter "name=n8n_quepasa_n8n_quepasa_editor" | grep -q .; then
        # Capturar o ID do container
        container_id=$(docker ps --filter "name=n8n_quepasa_n8n_quepasa_editor" --format "{{.ID}}")

        # Verificar se o ID do container foi capturado corretamente
        if [ -z "$container_id" ]; then
            echo "Erro: Nao foi possivel encontrar o ID do conteiner."
            exit 1
        fi

        # Executar o codigo no conteiner apenas se ele estiver em execucao
        docker exec "$container_id" /bin/sh -c '
            # Criando diretorio temporario
            temp_dir=$(mktemp -d)

            # Entrando no diretorio temporario
            cd "$temp_dir"

            # Baixando workflows

            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/ChatwootExtra.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/ChatwootProfileUpdate.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/ChatwootToQuepasa.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/GetChatwootContacts.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/GetValidConversation.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/MsgRejectCall.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/PostToChatwoot.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/PostToWebCallBack.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaAutomatic.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaChatControl.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaContactsImport.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaInboxControl.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaInboxControl+soc.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaInboxControl+typebot.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaInboxControl+webhook.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaQrcode.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/QuepasaToChatwoot.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/ToChatwootTranscriptViaOpenAI.json"
            wget "https://raw.githubusercontent.com/DeividMs/QP_Setup_FELSEN/main/workflows/latest/ToTypeBot.json"

            # Subindo workflows
            n8n import:workflow --input="$temp_dir" --separate

            # Verificando se os workflows foram importados com sucesso
            if [ $? -eq 0 ]; then
                echo "Workflows importados com sucesso"
            else
                echo "Erro ao importar workflows"
                exit 1
            fi

            # Ativando os workflows
            
            n8n update:workflow --id 1008 --active=true && echo "Fluxo ChatwootToQuepasa ativado" || echo "Erro ao ativar fluxo ChatwootToQuepasa"
            n8n update:workflow --id 1009 --active=true && echo "Fluxo QuepasaToChatwoot ativado" || echo "Erro ao ativar fluxo QuepasaToChatwoot"
            n8n update:workflow --id 1011 --active=true && echo "Fluxo QuepasaAutomatic ativado" || echo "Erro ao ativar QuepasaAutomatic 1011"
            n8n update:workflow --id z7iqKYC8r5nPRRHt --active=true && echo "Fluxo QuepasaQrcode ativado" || echo "Erro ao ativar fluxo QuepasaQrcode"
            n8n update:workflow --id GIPTrjgdT9vuOSlN --active=true && echo "Fluxo MsgRejectCall ativado" || echo "Erro ao ativar fluxo MsgRejectCall"


        '
        break
    else
        clear
        erro_msg
        echo ""
        echo -e "Ops, parece que voce nao instalou a opcao \e[32m[28] N8N + Nodes Quepasa${reset} ${branco}do nosso instalador.${reset}"
        echo "Instale antes de tentar instalar esta aplicacao."
        echo ""
        echo "Pressione CTRL C para sair do instalador."
        sleep 5
        exit
    fi
done

}

