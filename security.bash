#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuSecurity() {
   while true; do
    echo -e ""
    echo -e "+-------------------------------------+"
    echo -e "|                                     |"
    echo -e "|   1. Recargar  firewall             |"
    echo -e "|   2. Escanear puertos abiertos      |"
    echo -e "|   3. Revisar usuarios               |"
    echo -e "|                                     |"
    echo -e "|   0. Volver                         |"
    echo -e "+-------------------------------------+"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo -e "Actualizando reglas de firewall (UFW)..."
            sudo ufw reload
            echo -e "Reglas de firewall actualizadas."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        2)
            read -rp "Introduce la IP o dominio a escanear: " destino
            if ! command -v nmap > /dev/null 2>&1; then
                echo -e "ERROR: nmap no está instalado. Instalando..."
                sudo apt update && sudo apt install nmap -y
            fi
            echo -e "Escaneando puertos abiertos en $destino..."
            if sudo nmap -Pn "$destino"; then
                echo -e "Escaneo completado."
            else
                echo -e "ERROR: Falló el escaneo de puertos."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        3)
            echo -e "Usuarios del sistema con UID >= 1000:"
            getent passwd | awk -F: '$3 >= 1000 { print $1 }'
            read -n1 -srp "Presione una tecla para continuar..."
            clear
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
