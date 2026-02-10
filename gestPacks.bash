#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuGestPacks() {
   while true; do
    echo -e ""
    echo -e "+-------------------------------------+"
    echo -e "|                                     |"
    echo -e "|   1. Actualizar lista de paquetes   |"
    echo -e "|   2. Actualizar el sistema          |"
    echo -e "|   3. Eliminar paquetes innecesarios |"
    echo -e "|   4. Buscar un paquete              |"
    echo -e "|   5. Instalar un paquete            |"
    echo -e "|   6. Desinstalar un paquete         |"
    echo -e "|                                     |"
    echo -e "|   0. Volver                         |"
    echo -e "+-------------------------------------+"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo -e "Actualizando lista de paquetes..."
            sudo apt update
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        2)
            echo -e "Actualizando el sistema..."
            sudo apt upgrade -y
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        3)
            echo -e "Eliminando paquetes innecesarios..."
            sudo apt autoremove -y
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        4)
            read -rp "Introduce el nombre del paquete a buscar: " paquete
            resultado=$(apt search "$paquete" )
            if [[ $resultado != "" ]]
            then
                echo -e "Paquete encontrado:"
                echo -e "$resultado"
            else
                echo -e "No se encontró el paquete '$paquete'."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        5)
            read -rp "Introduce el nombre del paquete a instalar: " paquete
            sudo apt install "$paquete" -y
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        6)
            read -rp "Introduce el nombre del paquete a desinstalar: " paquete
            sudo apt remove "$paquete" -y
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo -e "Introduce una opción válida..."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
    esac
done
}
