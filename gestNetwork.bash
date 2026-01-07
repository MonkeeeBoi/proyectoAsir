#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

interfaz_seleccionada=""

function mostrar_interfaces() {
    echo ""
    echo "Interfaces de red disponibles:"
    echo "+-------------------------------------+"
    nmcli device status | grep -E "ethernet|wifi" | awk '{print "| " NR ". " $1 " - " $3 " |"}'
    echo "+-------------------------------------+"
    echo ""
}

function seleccionar_interfaz() {
    mostrar_interfaces
    read -rp "Selecciona el número de la interfaz: " num_interfaz
    
    interfaz_seleccionada=$(nmcli device status | grep -E "ethernet|wifi" | awk -v num="$num_interfaz" 'NR==num {print $1}')
    
    if [ -z "$interfaz_seleccionada" ]; then
        echo "ERROR: Selección no válida."
        return 1
    fi
    
    echo "Interfaz seleccionada: $interfaz_seleccionada"
    read -n1 -srp "Presione una tecla para continuar..."
    clear
    return 0
}

function menuGestNetwork() {
   while true; do
    echo ""
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Seleccionar interfaz           |"
    if [ -n "$interfaz_seleccionada" ]; then
        echo "|      (Actual: $interfaz_seleccionada)               |"
    fi
    echo "|   2. Mostrar configuración de red   |"
    echo "|   3. Probar conectividad            |"
    echo "|   4. Reiniciar red                  |"
    echo "|   5. Cambiar configuracion de red   |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"
    echo ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            seleccionar_interfaz
            ;;
        2)
            echo "Configuración de red:"
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
            echo "Reiniciando servicio de red..."
            sudo nmcli networking off && sudo nmcli networking on
            echo "Servicio de red reiniciado."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        5)
            if [ -z "$interfaz_seleccionada" ]; then
                echo "ERROR: Debe seleccionar una interfaz primero (opción 1)."
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
                    echo "Configurando $interfaz con DHCP..."
                    sudo nmcli con modify "$interfaz" ipv4.method auto
                    sudo nmcli con up "$interfaz"
                    echo "Interfaz $interfaz configurada con DHCP."
                    read -n1 -srp "Presione una tecla para continuar..."
                    clear
                else
                    while true; do
                        read -rp "Dirección IP con máscara (ej: 192.168.1.100/24): " ip
                        if ! echo "$ip" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\/[1-9]{1,2}"; then
                            echo "ip no valida..."
                            continue
                        fi
                        break
                    done
                    
                    while true; do
                        read -rp "Gateway (ej: 192.168.1.1): " gateway
                        if ! echo "$gateway" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
                            echo "ip no valida..."
                            continue
                        fi
                        break
                    done
                    
                    while true; do
                        read -rp "Servidores DNS separados por comas (ej: 8.8.8.8,8.8.4.4): " dns
                        if ! echo "$dns" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
                            echo "DNS no válido..."
                            continue
                        fi
                        break
                    done
                    echo "Configurando $interfaz con IP estática..."
                    sudo nmcli con modify "$interfaz" ipv4.method manual ipv4.addresses "$ip" ipv4.gateway "$gateway" ipv4.dns "${dns// /}"
                    sudo nmcli con up "$interfaz"
                    echo "Interfaz $interfaz configurada con IP estática."
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
            echo "Introduce una opcion valida..."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
    esac
done
}