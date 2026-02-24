#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuServicesANDprocesses() {
   while true; do
    echo -e ""
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Ver servicios activos          ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Iniciar un servicio            ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Detener un servicio            ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}4.${NC} Habilitar al inicio            ${BLUE}|${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opción: " opcSelect

    case $opcSelect in
        1)
            echo -e "${BLUE}Servicios activos:${NC}"
            systemctl list-units --type=service --state=running
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        2)
            read -rp "${BLUE}Introduce el nombre del servicio a iniciar (ej: cron):${NC} " servicio
            sudo systemctl start "$servicio"
            echo -e "${GREEN}Servicio '$servicio' iniciado.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        3)
            read -rp "${BLUE}Introduce el nombre del servicio a detener (ej: cron):${NC} " servicio
            sudo systemctl stop "$servicio"
            echo -e "${GREEN}Servicio '$servicio' detenido.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        4)
            read -rp "${BLUE}Introduce el nombre del servicio a habilitar al inicio (ej: cron):${NC} " servicio
            sudo systemctl enable "$servicio"
            echo -e "${GREEN}Servicio '$servicio' habilitado para iniciar con el sistema.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        0)
            break
            ;;
        *)
            echo -e "${RED}Introduce una opción válida...${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
    esac
done
}
