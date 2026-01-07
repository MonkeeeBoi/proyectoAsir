#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuServicesANDprocesses() {
   while true; do
    echo ""
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Ver servicios activos          |"
    echo "|   2. Iniciar un servicio            |"
    echo "|   3. Detener un servicio            |"
    echo "|   4. Habilitar al inicio            |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"
    echo ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo "Servicios activos:"
            systemctl list-units --type=service --state=running
            read -n1 -srsp "Presione una tecla para continuar..."
            ;;
        2)
            read -rp "Introduce el nombre del servicio a iniciar (ej: apache2): " servicio
            sudo systemctl start "$servicio"
            echo "Servicio '$servicio' iniciado."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            read -rp "Introduce el nombre del servicio a detener (ej: apache2): " servicio
            sudo systemctl stop "$servicio"
            echo "Servicio '$servicio' detenido."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        4)
            read -rp "Introduce el nombre del servicio a habilitar al inicio (ej: apache2): " servicio
            sudo systemctl enable "$servicio"
            echo "Servicio '$servicio' habilitado para iniciar con el sistema."
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
