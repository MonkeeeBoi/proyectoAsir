#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuGestSistem() {
   while true; do
    clear
    echo ""
    echo "+-----------------------------------------------+"
    echo "|                                               |"
    echo "|   1. Información completa del sistema (inxi)   |"
    echo "|   2. Hardware y componentes (inxi)             |"
    echo "|   3. Uso de disco detallado (inxi)            |"
    echo "|   4. Información de memoria (inxi)             |"
    echo "|   5. Información de red (inxi)                 |"
    echo "|   6. Monitor de procesos en tiempo real (btop) |"
    echo "|   7. Temperaturas y sensores (inxi)           |"
    echo "|   8. Información de batería (inxi)             |"
    echo "|                                               |"
    echo "|   0. Volver                                   |"
    echo "+-----------------------------------------------+"
    echo ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            clear
            echo "=== INFORMACIÓN COMPLETA DEL SISTEMA ==="
            inxi -F
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            clear
            echo "=== HARDWARE Y COMPONENTES ==="
            inxi -c0 -D
            echo ""
            inxi -c0 -C
            echo ""
            inxi -c0 -G
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            clear
            echo "=== USO DE DISCO DETALLADO ==="
            inxi -c0 -D
            echo ""
            echo "=== ESPACIO EN PARTICIONES ==="
            df -h | grep -E "^/dev|^Filesystem"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        4)
            clear
            echo "=== INFORMACIÓN DE MEMORIA ==="
            inxi -c0 -m
            echo ""
            echo "=== MEMORIA LIBRE ==="
            free -h
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        5)
            clear
            echo "=== INFORMACIÓN DE RED ==="
            inxi -c0 -n
            echo ""
            echo "=== INTERFACES DE RED ACTIVAS ==="
            ip addr show
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        6)
            clear
            echo "=== MONITOR DE PROCESOS EN TIEMPO REAL ==="
            echo "Iniciando btop... Presione 'q' para salir"
            btop
            ;;
        7)
            clear
            echo "=== TEMPERATURAS Y SENSORES ==="
            inxi -c0 -s
            echo ""
            echo "=== SENSORES DETALLADOS ==="
            if command -v sensors > /dev/null 2>&1; then
                sensors
            else
                echo "Comando 'sensors' no disponible"
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        8)
            clear
            echo "=== INFORMACIÓN DE BATERÍA ==="
            inxi -c0 -B
            echo ""
            echo "=== ESTADO DE ENERGÍA ==="
            upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null || echo "Batería no detectada o upower no disponible"
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