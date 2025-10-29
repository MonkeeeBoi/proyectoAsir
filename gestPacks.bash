# shellcheck disable=SC1091
source funciones.bash

function menuGestPacks() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Actualizar lista de paquetes   |"
    echo "|   2. Actualizar el sistema          |"
    echo "|   3. Eliminar paquetes innecesarios |"
    echo "|   4. Buscar un paquete              |"
    echo "|   5. Instalar un paquete            |"
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