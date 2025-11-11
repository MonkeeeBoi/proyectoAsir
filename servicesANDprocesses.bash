#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuServicesANDprocesses() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Ver servicios activos          |"
    echo "|   2. Iniciar un servicio            |"
    echo "|   3. Detener un servicio            |"
    echo "|   4. Habilitar al inicio            |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1) ;;
        2) ;;
        3) ;;
        4) ;;
        5) ;;
        6) ;;
        7) ;;
        0) break ;;
        *) echo "Introduce una opcion valida..." ;;
    esac
done
}