# shellcheck disable=SC1091
source funciones.bash

function menuSecurity() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Actualizar reglas de firewall  |"
    echo "|   2. Escanear puertos abiertos      |"
    echo "|   3. Revisar usuarios               |"
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