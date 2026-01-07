#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuSecurity() {
   while true; do
    echo ""
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Actualizar reglas de firewall  |"
    echo "|   2. Escanear puertos abiertos      |"
    echo "|   3. Revisar usuarios               |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"
    echo ""

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
            if ! command -v nmap > /dev/null 2>&1; then
                echo "ERROR: nmap no está instalado. Instalando..."
                sudo apt update && sudo apt install nmap -y
            fi
            echo "Escaneando puertos abiertos en $destino..."
            if sudo nmap -Pn "$destino"; then
                echo "Escaneo completado."
            else
                echo "ERROR: Falló el escaneo de puertos."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            echo "Usuarios del sistema con UID >= 1000:"
            getent passwd | awk -F: '$3 >= 1000 { print $1 }'
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
