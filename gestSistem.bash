#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuGestSistem() {
   while true; do
    clear
    echo ""
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Ver uso de disco               |"
    echo "|   2. Ver uso de memoria             |"
    echo "|   3. Monitorear procesos            |"
    echo "|   4. Ver información del sistema    |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"
    echo ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            clear
            echo "=== USO DE DISCO ==="
            df -h | grep -E "^/dev|^Filesystem"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            clear
            echo "=== USO DE MEMORIA ==="
            free -h
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            clear
            echo "=== PROCESOS ACTIVOS ==="
            ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 10
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        4)
            clear
            echo "=== INFORMACIÓN DEL SISTEMA ==="
            echo "Hostname: $(hostname)"
            echo "Kernel: $(uname -r)"
            echo "Arquitectura: $(uname -m)"
            echo "Sistema operativo: $(uname -o)"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo "Introduce una opción válida..."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
    esac
done
}