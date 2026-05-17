#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

interfaz_seleccionada=""

function mostrar_interfaces() {
    echo -e ""
    echo -e "${BLUE}Interfaces de red disponibles:${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    nmcli device status | grep -E "ethernet|wifi" | awk '{print "| " NR ". " $1 " - " $3 " |"}'
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""
}

function seleccionar_interfaz() {
    mostrar_interfaces
    read -rp "${BLUE}Selecciona el número de la interfaz:${NC} " num_interfaz
    
    interfaz_seleccionada=$(nmcli device status | grep -E "ethernet|wifi" | awk -v num="$num_interfaz" 'NR==num {print $1}')
    
    if [ -z "$interfaz_seleccionada" ]; then
        echo -e "${RED}ERROR: Selección no válida.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Interfaz seleccionada:${NC} ${YELLOW}$interfaz_seleccionada${NC}"
    read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
    clear
    return 0
}

function menuGestNetwork() {
   while true; do
    echo -e ""
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Seleccionar interfaz           ${BLUE}|${NC}"
    if [ -n "$interfaz_seleccionada" ]; then
        echo -e "${BLUE}|${NC}      (Actual: $interfaz_seleccionada)               ${BLUE}|${NC}"
    fi
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Mostrar configuración de red   ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Probar conectividad            ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}4.${NC} Reiniciar red                  ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}5.${NC} Cambiar configuracion de red   ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}                                     ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
        clear
            seleccionar_interfaz
        read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        2)
        clear
            echo -e "${BLUE}Configuración de red:${NC}"
            if [ -n "$interfaz_seleccionada" ]; then
                nmcli device show "$interfaz_seleccionada"
            else
                nmcli device show
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        3)
        clear
            read -rp "${BLUE}Introduce una IP o dominio para probar conectividad:${NC} " destino
            ping -c 4 "$destino"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        4)
        clear
            echo -e "${BLUE}Reiniciando servicio de red...${NC}"
            sudo nmcli networking off && sudo nmcli networking on
            echo -e "${GREEN}Servicio de red reiniciado.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        5)
function configurarRed() {
    clear
    read -rp "Introduce la interfaz de red a configurar (ejemplo: enp0s3): " interfaz_seleccionada

    # Obtener la conexión asociada
    conexion=$(nmcli -t -f NAME,DEVICE con show --active | grep ":$interfaz_seleccionada$" | cut -d: -f1)
    if [[ -z "$conexion" ]]; then
        conexion="$interfaz_seleccionada"
        sudo nmcli con add type ethernet ifname "$interfaz_seleccionada" con-name "$conexion"
    fi

    read -rp "¿Quieres DHCP? [Y/n]: " yesOrNo
    yesOrNo=${yesOrNo,,}

    if [[ "$yesOrNo" == "y" || "$yesOrNo" == "" ]]; then
        echo "Configurando $interfaz_seleccionada con DHCP..."
        sudo nmcli con modify "$conexion" ipv4.method auto
        sudo nmcli con up "$conexion"
        echo "Interfaz $interfaz_seleccionada configurada con DHCP."
    else
        read -rp "IP con máscara (ej: 192.168.1.100/24): " ip
        read -rp "Gateway: " gateway
        read -rp "DNS (separados por comas): " dns

        sudo nmcli con modify "$conexion" ipv4.method manual ipv4.addresses "$ip" ipv4.gateway "$gateway" ipv4.dns "$dns"
        sudo nmcli con up "$conexion" --ask 2>/dev/null
        echo "Interfaz $interfaz_seleccionada configurada con IP estática."
    fi
    read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
}

# --- Ejecutar función ---
configurarRed
            
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