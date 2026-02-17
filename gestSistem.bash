#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuGestSistem() {
   while true; do
    clear
    echo -e ""
    echo -e "${BLUE}+------------------------------------------------+${NC}"
    echo -e "${BLUE}|                                                |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Información completa del sistema (inxi)   ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Hardware y componentes (inxi)             ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Uso de disco detallado (inxi)             ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}4.${NC} Información de memoria (inxi)             ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}5.${NC} Información de red (inxi)                 ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}6.${NC} Monitor de procesos en tiempo real (btop) ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}7.${NC} Temperaturas y sensores (inxi)            ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}8.${NC} Información de batería (inxi)             ${BLUE}|${NC}"
    echo -e "${BLUE}|                                                |${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                                    ${BLUE}|${NC}"
    echo -e "${BLUE}+------------------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            clear
            echo -e "${BLUE}=== INFORMACIÓN COMPLETA DEL SISTEMA ===${NC}"
            inxi -F
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        2)
            clear
            echo -e "${BLUE}=== HARDWARE Y COMPONENTES ===${NC}"
            inxi -c0 -D
            echo -e ""
            inxi -c0 -C
            echo -e ""
            inxi -c0 -G
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        3)
            clear
            echo -e "${BLUE}=== USO DE DISCO DETALLADO ===${NC}"
            inxi -c0 -D
            echo -e ""
            echo -e "${BLUE}=== ESPACIO EN PARTICIONES ===${NC}"
            df -h | grep -E "^/dev|^Filesystem"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        4)
            clear
            echo -e "${BLUE}=== INFORMACIÓN DE MEMORIA ===${NC}"
            inxi -c0 -m
            echo -e ""
            echo -e "${BLUE}=== MEMORIA LIBRE ===${NC}"
            free -h
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        5)
            clear
            echo -e "${BLUE}=== INFORMACIÓN DE RED ===${NC}"
            inxi -c0 -n
            echo -e ""
            echo -e "${BLUE}=== INTERFACES DE RED ACTIVAS ===${NC}"
            ip addr show
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        6)
            clear
            echo -e "${BLUE}=== MONITOR DE PROCESOS EN TIEMPO REAL ===${NC}"
            echo -e "${YELLOW}Iniciando btop... Para salir una vez iniciado btop presionar${NC} ${RED}'q'${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            btop
            ;;
        7)
            clear
            echo -e "${BLUE}=== TEMPERATURAS Y SENSORES ===${NC}"
            inxi -c0 -s
            echo -e ""
            echo -e "${BLUE}=== SENSORES DETALLADOS ===${NC}"
            if command -v sensors > /dev/null 2>&1; then
                sensors
            else
                echo -e "${RED}Comando 'sensors' no disponible${NC}"
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        8)
            clear
            echo -e "${BLUE}=== INFORMACIÓN DE BATERÍA ===${NC}"
            inxi -c0 -B
            echo -e ""
            echo -e "${BLUE}=== ESTADO DE ENERGÍA ===${NC}"
            upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null || echo -e "${RED}Batería no detectada o upower no disponible${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
        0)
            break
            ;;
        *) 
            echo -e "${RED}Introduce una opción válida...${NC}" 
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
    esac
done
}