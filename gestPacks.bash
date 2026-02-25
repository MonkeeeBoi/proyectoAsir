#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuGestPacks() {
   while true; do
    echo -e ""
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Actualizar lista de paquetes   ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Actualizar el sistema          ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Eliminar paquetes innecesarios ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}4.${NC} Buscar un paquete              ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}5.${NC} Instalar un paquete            ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}6.${NC} Desinstalar un paquete         ${BLUE}|${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
        clear
            echo -e "${BLUE}Actualizando lista de paquetes...${NC}"
            sudo apt update
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        2)
        clear
            echo -e "${BLUE}Actualizando el sistema...${NC}"
            sudo apt upgrade -y
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        3)
        clear
            echo -e "${BLUE}Eliminando paquetes innecesarios...${NC}"
            sudo apt autoremove -y
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        4)
        clear
            read -rp "${BLUE}Introduce el nombre del paquete a buscar:${NC} " paquete
            resultado=$(apt search "$paquete" )
            if [[ $resultado != "" ]]
            then
                echo -e "${GREEN}Paquete encontrado:${NC}"
                echo -e "$resultado"
            else
                echo -e "${RED}No se encontró el paquete '$paquete'.${NC}"
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        5)
        clear
            read -rp "${BLUE}Introduce el nombre del paquete a instalar:${NC} " paquete
            sudo apt install "$paquete" -y
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        6)
        clear
            read -rp "${BLUE}Introduce el nombre del paquete a desinstalar:${NC} " paquete
            sudo apt remove "$paquete" -y
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        0)
            break
            ;;
        *)
        clear
            echo -e "${RED}Introduce una opción válida...${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
    esac
done
}
