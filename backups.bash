#!/bin/bash

# FUNCIONANDO

# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuBackups() {
   while true; do
    echo -e ""
    echo -e "+-------------------------------------+"
    echo -e "|                                     |"
    echo -e "|   1. Crear backup de directorio     |"
    echo -e "|   2. Restaurar backup               |"
    echo -e "|                                     |"
    echo -e "|   0. Volver                         |"
    echo -e "+-------------------------------------+"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            read -rp "Introduce el directorio a respaldar: " dir
            if [[ -d "$dir" ]]
            then
                fecha=$(date +%Y%m%d_%H%M%S)
                nombre=$(basename "$dir")
                backup="backup_${nombre}_$fecha.tar.gz"
                if tar -czf "$backup" "$dir"; then
                    echo -e "Backup creado: $backup"
                else
                    echo -e "ERROR: No se pudo crear el backup."
                fi
            else
                echo -e "El directorio no existe."
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
                echo -e "Backup restaurado en: $destino"
            else
                echo -e "El archivo no existe."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo -e "Introduce una opcion valida..."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
    esac
done
}
