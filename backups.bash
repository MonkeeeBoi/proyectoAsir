#!/bin/bash

# FUNCIONANDO

# shellcheck disable=SC1091
source funciones.bash

function menuBackups() {
   while true; do
    echo ""
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Crear backup de directorio     |"
    echo "|   2. Restaurar backup               |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            read -rp "Introduce el directorio a respaldar: " dir
            if [[ -d "$dir" ]]
            then
                fecha=$(date +%Y%m%d_%H%M%S)
                nombre=$(basename "$dir")
                backup="backup_${nombre}_$fecha.tar.gz"
                tar -czf "$backup" "$dir"
                echo "Backup creado: $backup"
            else
                echo "El directorio no existe."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            read -rp "Introduce el nombre del archivo de backup (.tar.gz): " archivo
            if [[ -f "$archivo" ]]
            then
                read -rp "Introduce el directorio destino para restaurar: " destino
                mkdir -p "$destino"
                tar -xzf "$archivo" -C "$destino"
                echo "Backup restaurado en: $destino"
            else
                echo "El archivo no existe."
            fi
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
