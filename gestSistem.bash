# shellcheck disable=SC1091
source funciones.bash

function menuGestSistem() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Ver uso de disco               |"
    echo "|   2. Ver uso de memoria             |"
    echo "|   3. Monitorear procesos            |"
    echo "|   4. Ver información del sistema    |"
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