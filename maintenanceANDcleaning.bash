#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuMaintenanceANDcleaning() {
   while true; do
   clear
    echo -e ""
    echo -e "${BLUE}+--------------------------------------+${NC}"
    echo -e "${BLUE}|                                      |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Limpiar caché de apt            ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Eliminar dependencias obsoletas ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Revisar logs del sistema        ${BLUE}|${NC}"
    echo -e "${BLUE}|                                      |${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                          ${BLUE}|${NC}"
    echo -e "${BLUE}+--------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opción: " opcSelect

    case $opcSelect in
        1)
        clear
            echo -e "${BLUE}Limpiando caché de apt...${NC}"
            sudo apt clean
            echo -e "${GREEN}Caché de apt limpiada correctamente.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        2)
        clear
            echo -e "${BLUE}Eliminando dependencias obsoletas...${NC}"
            sudo apt autoremove -y
            echo -e "${GREEN}Dependencias obsoletas eliminadas.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        3)
        clear
            echo -e "${BLUE}Mostrando logs del sistema (últimos 20 registros)...${NC}"
            journalctl -xe | tail -n 20
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
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

