#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuGestNetwork() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Mostrar configuración de red   |"
    echo "|   2. Probar conectividad            |"
    echo "|   3. Reiniciar red                  |"
    echo "|   4. Ver IP                         |"
    echo "|   5. Cambiar IP                     |"
    echo "|   6. Cambiar DNS                    |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo "Configuración de red:"
            ip a
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            read -rp "Introduce una IP o dominio para probar conectividad: " destino
            ping -c 4 "$destino"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            echo "Reiniciando servicio de red..."
            sudo systemctl restart NetworkManager || sudo systemctl restart networking
            echo "Servicio de red reiniciado."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        4)
            ip_actual=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
            echo "IP actual: $ip_actual"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        5)
            read -rp "Introduce el nombre de la interfaz (ej: eth0): " interfaz
            read -rp "Introduce la nueva IP (ej: 192.168.1.100/24): " nueva_ip
            sudo ip addr flush dev "$interfaz"
            sudo ip addr add "$nueva_ip" dev "$interfaz"
            sudo ip link set "$interfaz" up
            echo "IP cambiada en la interfaz $interfaz."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        6)
            read -rp "Introduce la nueva IP de DNS (ej: 8.8.8.8): " nuevo_dns
            echo "nameserver $nuevo_dns" | sudo tee /etc/resolv.conf > /dev/null
            echo "DNS cambiado a $nuevo_dns"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo "Introduce una opcion valida..."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
    esac
done
}