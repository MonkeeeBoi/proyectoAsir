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
    echo "|   4. Cambiar configuracion de red   |"
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
            read -rp "Nombre de la interfaz de red (ej: eth0): " interfaz
            while true; do
                if ! ip a | grep -E "$interfaz:"; then
                    echo "La Interfaz no existe en el dispositivo..."
                    continue
                fi
                break
            done
            NETPLAN_DIR="/etc/netplan/$interfaz.yaml"
            while true; do 
                read -rp "Quires que sea dhcp [Y/n]: " yesOrNo
                if comprobarYesOrNo "$yesOrNo"; then
                    continue
                fi
                if YesOrNo "$yesOrNo"; then
                    sudo tee "$NETPLAN_DIR" > /dev/null <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    $interfaz:
        dhcp4: yes

EOF
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
                        if ! echo "$gateway" | grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}"; then
                            echo "ip no valida..."
                            continue
                        fi
                        break
                    done
                    sudo tee "$NETPLAN_DIR" > /dev/null <<EOF
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    $interfaz:
      dhcp4: no
      addresses: [$ip]
      routes:
        - to: default
          via: $gateway
      nameservers:
        addresses: [${dns// /}]
EOF
                    sudo chmod 600 "$NETPLAN_DIR"
                    echo "Fichero Netplan configurado en $NETPLAN_DIR"
                    echo "Aplicando configuración..."
                    sudo netplan apply
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