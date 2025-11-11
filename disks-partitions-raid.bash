#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function disks-partitions-raid() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Ver discos y particiones       |"
    echo "|   2. Crear partición                |"
    echo "|   3. Crear sistema de archivos      |"
    echo "|   4. Montar y desmontar particiones |"
    echo "|   5. Añadir al fstab                |"
    echo "|   6. Crear RAID                     |"
    echo "|   7. Guardar configuración RAID     |"
    echo "|   8. Comprobar estado RAID          |"
    echo "|   9. Crear volumen LVM              |"
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
        8) ;;
        9) ;;
        0) break ;;
        *) echo "Introduce una opcion valida..." ;;
    esac
done
}