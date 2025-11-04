# shellcheck disable=SC1091
source funciones.bash

function menuMaintenanceANDcleaning() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|  1. Limpiar caché de apt            |"
    echo "|  2. Eliminar dependencias obsoletas |"
    echo "|  3. Revisar logs del sistema        |"
    echo "|                                     |"
    echo "|  0. Volver                          |"
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