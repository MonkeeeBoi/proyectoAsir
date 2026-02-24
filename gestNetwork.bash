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
    echo -e "${BLUE}|${NC}   1. Seleccionar interfaz           ${BLUE}|${NC}"
    if [ -n "$interfaz_seleccionada" ]; then
        echo -e "${BLUE}|${NC}      (Actual: $interfaz_seleccionada)               ${BLUE}|${NC}"
    fi
    echo -e "${BLUE}|${NC}   2. Mostrar configuración de red   ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   3. Probar conectividad            ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   4. Reiniciar red                  ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   5. Cambiar configuracion de red   ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}                                     ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   0. Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            seleccionar_interfaz
            ;;
        2)
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
            read -rp "${BLUE}Introduce una IP o dominio para probar conectividad:${NC} " destino
            ping -c 4 "$destino"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        4)
            echo -e "${BLUE}Reiniciando servicio de red...${NC}"
            sudo nmcli networking off && sudo nmcli networking on
            echo -e "${GREEN}Servicio de red reiniciado.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        5)
            if [ -z "$interfaz_seleccionada" ]; then
                echo -e "${RED}ERROR: Debe seleccionar una interfaz primero (opción 1).${NC}"
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
                continue
            fi
            interfaz="$interfaz_seleccionada"
            NETPLAN_DIR="/etc/netplan/$interfaz.yaml"
            while true; do 
                read -rp "${BLUE}¿Quieres que sea DHCP? [Y/n]:${NC} " yesOrNo
                if comprobarYesOrNo "$yesOrNo"; then
                    continue
                fi
                if YesOrNo "$yesOrNo"; then
                    echo -e "${BLUE}Configurando $interfaz con DHCP...${NC}"
                    sudo nmcli con modify "$interfaz" ipv4.method auto
                    sudo nmcli con up "$interfaz"
                    echo -e "${GREEN}Interfaz $interfaz configurada con DHCP.${NC}"
                    read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                    clear
                else
                    while true; do
                        read -rp "${BLUE}Dirección IP con máscara (ej: 192.168.1.100/24):${NC} " ip
                        if ! echo -e "$ip" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[1-9]{1,2}"; then
                            echo -e "${RED}ip no valida...${NC}"
                            continue
                        fi
                        break
                    done
                    
                    while true; do
                        read -rp "${BLUE}Gateway (ej: 192.168.1.1):${NC} " gateway
                        if ! echo -e "$gateway" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
                            echo -e "${RED}ip no valida...${NC}"
                            continue
                        fi
                        break
                    done
                    
                    while true; do
                        read -rp "${BLUE}Servidores DNS separados por comas (ej: 8.8.8.8,8.8.4.4):${NC} " dns
                        if ! echo -e "$dns" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
                            echo -e "${RED}DNS no válido...${NC}"
                            continue
                        fi
                        break
                    done
                    echo -e "${BLUE}Configurando $interfaz con IP estática...${NC}"
                    sudo nmcli con modify "$interfaz" ipv4.method manual ipv4.addresses "$ip" ipv4.gateway "$gateway" ipv4.dns "${dns// /}"
                    sudo nmcli con up "$interfaz"
                    echo -e "${GREEN}Interfaz $interfaz configurada con IP estática.${NC}"
                    read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                    clear
                fi
                break
            done
            
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