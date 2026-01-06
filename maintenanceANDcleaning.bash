#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuMaintenanceANDcleaning() {
   while true; do
    echo ""
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|  1. Limpiar caché de apt            |"
    echo "|  2. Eliminar dependencias obsoletas |"
    echo "|  3. Revisar logs del sistema        |"
    echo "|                                     |"
    echo "|  0. Volver                          |"
    echo "+-------------------------------------+"
    echo ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo "Limpiando caché de apt..."
            sudo apt clean
            echo "Caché de apt limpiada correctamente."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            echo "Eliminando dependencias obsoletas..."
            sudo apt autoremove -y
            echo "Dependencias obsoletas eliminadas."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            echo "Mostrando logs del sistema (últimos 20 registros)..."
            journalctl -xe | tail -n 20
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
