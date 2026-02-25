#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuSecurity() {
   while true; do
    echo -e ""
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Recargar firewall              ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Escanear puertos abiertos      ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Activar/Desactivar firewall    ${BLUE}|${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opción: " opcSelect

    case $opcSelect in
        1)
        clear
            echo -e "${BLUE}Actualizando reglas de firewall (UFW)...${NC}"
            if sudo ufw reload; then
                echo -e "${GREEN}Reglas de firewall actualizadas correctamente.${NC}"
            else
                echo -e "${RED}ERROR: No se pudieron recargar las reglas.${NC}"
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        2)
        clear
        # Comprobar si ss está instalado
        if ! command -v ss > /dev/null 2>&1; then
            echo "El comando 'ss' no está instalado. Instalando..."
            sudo apt update -q
            sudo apt install iproute2 -y
        fi

        echo "Mostrando puertos abiertos..."
        echo ""

        sudo ss -tulnp
        read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"

            clear
            ;;


        3)
        clear
            estado=$(sudo ufw status | head -n1 | awk '{print $2}')

            if [[ "$estado" == "activo" ]]; then
                echo -e "${YELLOW}El firewall está actualmente ACTIVADO.${NC}"
                read -rp "${BLUE}¿Desea desactivarlo? [Y/n]:${NC} " resp
                if YesOrNo "$resp"; then
                    echo -e "${BLUE}Desactivando firewall...${NC}"
                    sudo ufw disable
                    echo -e "${GREEN}Firewall desactivado.${NC}"
                fi
            else
                echo -e "${YELLOW}El firewall está actualmente DESACTIVADO.${NC}"
                read -rp "${BLUE}¿Desea activarlo? [Y/n]:${NC} " resp
                if YesOrNo "$resp"; then
                    echo -e "${BLUE}Activando firewall...${NC}"
                    sudo ufw enable
                    echo -e "${GREEN}Firewall activado.${NC}"
                fi
            fi

            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;


        0)
            break
            ;;

        *)
        clear
            echo -e "${RED}ERROR: Introduce una opción válida...${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
    esac
done
}

