#!/usr/bin/env bash
# Felsen installer module. Loaded by lib/bootstrap.sh.

limpar() {
    clear
    nome_expurgando
    echo -e "\e[97maEUR VERIFICANDO ESPAAO DISPONAVEL \e[33m[1/3]\e[0m"
    echo ""
    sleep 1
    read used_before avail_before total_before percent_before <<<"$(armazenamento_livre)"
    echo -e "Espaco usado: \e[33m${used_before}Gb\e[0m (\e[33m${percent_before}%\e[0m usado)"
    echo -e "Espaco livre: \e[33m${avail_before}Gb\e[0m de \e[33m${total_before}Gb\e[0m"
    echo ""

    echo -e "\e[97m- LIMPANDO RECURSOS NAO UTILIZADOS DO DOCKER \e[33m[2/3]\e[0m"
    echo ""
    sleep 1
    docker system prune -af > /dev/null
    truncate -s 0 /var/lib/docker/containers/*/*-json.log > /dev/null
    sleep 1

    echo -e "\e[97maEUR LIMPEZA CONCLUADA \e[33m[3/3]\e[0m"
    echo ""
    read used_after avail_after total_after percent_after <<<"$(armazenamento_livre)"
    echo -e "Espaco usado: \e[33m${used_after}Gb\e[0m (\e[33m${percent_after}%\e[0m usado)"
    echo -e "Espaco livre: \e[33m${avail_after}Gb\e[0m de \e[33m${total_after}Gb\e[0m"

    # Calcular espaco liberado
    space_freed=$((used_before - used_after))
    echo -e "Foi liberado: \e[33m${space_freed}Gb\e[0m do seu servidor"
    echo ""
    echo -e "\e[97mVoltando ao menu principal em 10 segundos...\e[0m"
    sleep 10
}

