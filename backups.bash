#!/bin/bash

# FUNCIONANDO

# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuBackups() {
   while true; do
    echo -e ""
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Crear backup de directorio     ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Restaurar backup               ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}                                     ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
        clear
        read -rp "${BLUE}Introduce ruta a respaldar:${NC} " ruta

        if [[ -e "$ruta" ]]; then
            fecha=$(date +%Y%m%d_%H%M%S)
            nombre=$(basename "$ruta")
            backup="/copias_de_seguridad/backup_${nombre}_$fecha.tar.gz"

            # Crear carpeta si no existe
            sudo mkdir -p /copias_de_seguridad

            echo -e "${BLUE}Creando backup...${NC}"
            if sudo tar -czf "$backup" "$ruta"; then
                echo -e "${GREEN}Backup creado correctamente:${NC} $backup"
            else
                echo -e "${RED}ERROR: No se pudo crear el backup.${NC}"
            fi
        else
            echo -e "${RED}La ruta no existe.${NC}"
        fi

        read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
        clear
        ;;


        2)
       
# Directorio donde están los backups
backup_dir="/copias_de_seguridad"

clear

# Mostrar los backups disponibles
echo -e "${YELLOW}Backups disponibles:${NC}"
ls "$backup_dir"
echo

# Pedir el nombre del archivo
read -rp "$(echo -e "${BLUE}Introduce el nombre del archivo de backup (.tar.gz): ${NC}")" archivo

# Construir la ruta completa
archivo="$backup_dir/$archivo"

echo -e "${YELLOW}Buscando archivo en:${NC} $archivo"

if [[ -f "$archivo" ]]; then
    # Pedir directorio destino
    read -rp "$(echo -e "${BLUE}Introduce el directorio destino para restaurar: ${NC}")" destino

    mkdir -p "$destino"

    tar -xzf "$archivo" -C "$destino"

    echo -e "${GREEN}Backup restaurado en: $destino${NC}"
else
    echo -e "${RED}El archivo no existe.${NC}"
fi

read -n1 -srp "$(echo -e "${YELLOW}Presione una tecla para continuar...${NC}")"
clear
            ;;
        0)
            break
            ;;
        *)
        clear
            echo -e "${RED}Introduce una opción válida...${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
    esac
done
}
