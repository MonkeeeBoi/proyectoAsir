#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuGestSistem() {
   while true; do
    clear
    echo -e ""
    echo -e "+-----------------------------------------------+"
    echo -e "|                                               |"
    echo -e "|   1. Información completa del sistema (inxi)   |"
    echo -e "|   2. Hardware y componentes (inxi)             |"
    echo -e "|   3. Uso de disco detallado (inxi)            |"
    echo -e "|   4. Información de memoria (inxi)             |"
    echo -e "|   5. Información de red (inxi)                 |"
    echo -e "|   6. Monitor de procesos en tiempo real (btop) |"
    echo -e "|   7. Temperaturas y sensores (inxi)           |"
    echo -e "|   8. Información de batería (inxi)             |"
    echo -e "|                                               |"
    echo -e "|   0. Volver                                   |"
    echo -e "+-----------------------------------------------+"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            clear
            echo -e "=== INFORMACIÓN COMPLETA DEL SISTEMA ==="
            inxi -F
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            clear
            echo -e "=== HARDWARE Y COMPONENTES ==="
            inxi -c0 -D
            echo -e ""
            inxi -c0 -C
            echo -e ""
            inxi -c0 -G
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            clear
            echo -e "=== USO DE DISCO DETALLADO ==="
            inxi -c0 -D
            echo -e ""
            echo -e "=== ESPACIO EN PARTICIONES ==="
            df -h | grep -E "^/dev|^Filesystem"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        4)
            clear
            echo -e "=== INFORMACIÓN DE MEMORIA ==="
            inxi -c0 -m
            echo -e ""
            echo -e "=== MEMORIA LIBRE ==="
            free -h
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        5)
            clear
            echo -e "=== INFORMACIÓN DE RED ==="
            inxi -c0 -n
            echo -e ""
            echo -e "=== INTERFACES DE RED ACTIVAS ==="
            ip addr show
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        6)
            clear
            echo -e "=== MONITOR DE PROCESOS EN TIEMPO REAL ==="
            echo -e "Iniciando btop... Presione 'q' para salir"
            btop
            ;;
        7)
            clear
            echo -e "=== TEMPERATURAS Y SENSORES ==="
            inxi -c0 -s
            echo -e ""
            echo -e "=== SENSORES DETALLADOS ==="
            if command -v sensors > /dev/null 2>&1; then
                sensors
            else
                echo -e "Comando 'sensors' no disponible"
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        8)
            clear
            echo -e "=== INFORMACIÓN DE BATERÍA ==="
            inxi -c0 -B
            echo -e ""
            echo -e "=== ESTADO DE ENERGÍA ==="
            upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null || echo -e "Batería no detectada o upower no disponible"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo -e "Introduce una opción válida..."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
    esac
done
}