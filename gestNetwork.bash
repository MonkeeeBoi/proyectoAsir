#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

interfaz_seleccionada=""

function mostrar_interfaces() {
    echo -e ""
    echo -e "Interfaces de red disponibles:"
    echo -e "+-------------------------------------+"
    nmcli device status | grep -E "ethernet|wifi" | awk '{print "| " NR ". " $1 " - " $3 " |"}'
    echo -e "+-------------------------------------+"
    echo -e ""
}

function seleccionar_interfaz() {
    mostrar_interfaces
    read -rp "Selecciona el número de la interfaz: " num_interfaz
    
    interfaz_seleccionada=$(nmcli device status | grep -E "ethernet|wifi" | awk -v num="$num_interfaz" 'NR==num {print $1}')
    
    if [ -z "$interfaz_seleccionada" ]; then
        echo -e "ERROR: Selección no válida."
        return 1
    fi
    
    echo -e "Interfaz seleccionada: $interfaz_seleccionada"
    read -n1 -srp "Presione una tecla para continuar..."
    clear
    return 0
}

function menuGestNetwork() {
   while true; do
    echo -e ""
    echo -e "+-------------------------------------+"
    echo -e "|                                     |"
    echo -e "|   1. Seleccionar interfaz           |"
    if [ -n "$interfaz_seleccionada" ]; then
        echo -e "|      (Actual: $interfaz_seleccionada)               |"
    fi
    echo -e "|   2. Mostrar configuración de red   |"
    echo -e "|   3. Probar conectividad            |"
    echo -e "|   4. Reiniciar red                  |"
    echo -e "|   5. Cambiar configuracion de red   |"
    echo -e "|                                     |"
    echo -e "|   0. Volver                         |"
    echo -e "+-------------------------------------+"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            seleccionar_interfaz
            ;;
        2)
            echo -e "Configuración de red:"
            if [ -n "$interfaz_seleccionada" ]; then
                nmcli device show "$interfaz_seleccionada"
            else
                nmcli device show
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        3)
            read -rp "Introduce una IP o dominio para probar conectividad: " destino
            ping -c 4 "$destino"
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        4)
            echo -e "Reiniciando servicio de red..."
            sudo nmcli networking off && sudo nmcli networking on
            echo -e "Servicio de red reiniciado."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        5)
            if [ -z "$interfaz_seleccionada" ]; then
                echo -e "ERROR: Debe seleccionar una interfaz primero (opción 1)."
                read -n1 -srp "Presione una tecla para continuar..."
                clear
                continue
            fi
            interfaz="$interfaz_seleccionada"
            NETPLAN_DIR="/etc/netplan/$interfaz.yaml"
            while true; do 
                read -rp "Quires que sea dhcp [Y/n]: " yesOrNo
                if comprobarYesOrNo "$yesOrNo"; then
                    continue
                fi
                if YesOrNo "$yesOrNo"; then
                    echo -e "Configurando $interfaz con DHCP..."
                    sudo nmcli con modify "$interfaz" ipv4.method auto
                    sudo nmcli con up "$interfaz"
                    echo -e "Interfaz $interfaz configurada con DHCP."
                    read -n1 -srp "Presione una tecla para continuar..."
                    clear
                else
                    while true; do
                        read -rp "Dirección IP con máscara (ej: 192.168.1.100/24): " ip
                        if ! echo -e "$ip" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[1-9]{1,2}"; then
                            echo -e "ip no valida..."
                            continue
                        fi
                        break
                    done
                    
                    while true; do
                        read -rp "Gateway (ej: 192.168.1.1): " gateway
                        if ! echo -e "$gateway" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
                            echo -e "ip no valida..."
                            continue
                        fi
                        break
                    done
                    
                    while true; do
                        read -rp "Servidores DNS separados por comas (ej: 8.8.8.8,8.8.4.4): " dns
                        if ! echo -e "$dns" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
                            echo -e "DNS no válido..."
                            continue
                        fi
                        break
                    done
                    echo -e "Configurando $interfaz con IP estática..."
                    sudo nmcli con modify "$interfaz" ipv4.method manual ipv4.addresses "$ip" ipv4.gateway "$gateway" ipv4.dns "${dns// /}"
                    sudo nmcli con up "$interfaz"
                    echo -e "Interfaz $interfaz configurada con IP estática."
                    read -n1 -srp "Presione una tecla para continuar..."
                    clear
                    read -n1 -srp "Presione una tecla para continuar..."
                    clear
                fi
                break
            done
            
            ;;
        0)
            break
            ;;
        *)
            echo -e "Introduce una opcion valida..."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
    esac
done
}