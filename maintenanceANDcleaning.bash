#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuMaintenanceANDcleaning() {
   while true; do
    echo -e ""
    echo -e "+-------------------------------------+"
    echo -e "|                                     |"
    echo -e "|  1. Limpiar caché de apt            |"
    echo -e "|  2. Eliminar dependencias obsoletas |"
    echo -e "|  3. Revisar logs del sistema        |"
    echo -e "|                                     |"
    echo -e "|  0. Volver                          |"
    echo -e "+-------------------------------------+"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo -e "${BLUE}Limpiando caché de apt...${NC}"
            sudo apt clean
            echo -e "${GREEN}Caché de apt limpiada correctamente.${NC}"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            echo -e "${BLUE}Eliminando dependencias obsoletas...${NC}"
            sudo apt autoremove -y
            echo -e "${GREEN}Dependencias obsoletas eliminadas.${NC}"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            echo -e "${BLUE}Mostrando logs del sistema (últimos 20 registros)...${NC}"
            journalctl -xe | tail -n 20
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo -e "${RED}Introduce una opción válida...${NC}"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
    esac
done
}
