#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuSecurity() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Actualizar reglas de firewall  |"
    echo "|   2. Escanear puertos abiertos      |"
    echo "|   3. Revisar usuarios               |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo "Actualizando reglas de firewall (UFW)..."
            sudo ufw reload
            echo "Reglas de firewall actualizadas."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            read -rp "Introduce la IP o dominio a escanear: " destino
            echo "Escaneando puertos abiertos en $destino..."
            sudo nmap -Pn "$destino"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            echo "Usuarios del sistema con UID >= 1000:"
            getent passwd | grep -E "^[^:]*:[^:]*:[1-9][0-9]{3}:" | cut -d: -f1
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
