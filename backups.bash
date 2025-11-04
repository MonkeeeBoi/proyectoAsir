# shellcheck disable=SC1091
source funciones.bash

function menuBackups() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Crear backup de directorio     |"
    echo "|   2. Restaurar backup               |"
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
        0) break ;;
        *) echo "Introduce una opcion valida..." ;;
    esac
done
}