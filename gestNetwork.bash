#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuGestNetwork() {
   while true; do
    echo ""
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
    echo ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo "Configuración de red:"
            ip a
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        2)
            read -rp "Introduce una IP o dominio para probar conectividad: " destino
            ping -c 4 "$destino"
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        3)
            echo "Reiniciando servicio de red..."
            sudo systemctl restart NetworkManager || sudo systemctl restart networking
            echo "Servicio de red reiniciado."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        4)
            ip_actual=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n1)
            echo "IP actual: $ip_actual"
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        5)
            # Pedir datos de configuración
            read -p "Nombre de la interfaz de red (ej: eth0): " interfaz
            read -p "Dirección IP con máscara (ej: 192.168.1.100/24): " ip
            read -p "Gateway (ej: 192.168.1.1): " gateway
            read -p "Servidores DNS separados por comas (ej: 8.8.8.8,8.8.4.4): " dns

            NETPLAN_DIR="/etc/netplan/$interfaz.yaml"
            # Crear configuración en el fichero YAML
            sudo tee $NETPLAN_DIR > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $interfaz:
      dhcp4: no
      addresses: [$ip]
      gateway4: $gateway
      nameservers:
        addresses: [${dns// /}]
EOF

            echo "Fichero Netplan configurado en $NETPLAN_DIR"
            echo "Aplicando configuración..."
            sudo netplan apply
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        6)
            read -rp "Introduce la nueva IP de DNS (ej: 8.8.8.8): " nuevo_dns
            echo "nameserver $nuevo_dns" | sudo tee /etc/resolv.conf > /dev/null
            echo "DNS cambiado a $nuevo_dns"
            read -n1 -srp "Presione una tecla para continuar..."
            clear
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