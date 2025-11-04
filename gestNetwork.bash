# shellcheck disable=SC1091
source funciones.bash

function menuGestNetwork() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Mostrar configuración de red   |"
    echo "|   2. Probar conectividad            |"
    echo "|   3. Reiniciar red                  |"
    echo "|   4. Ver IP                         |"
    echo "|   5. Cambiar IP                     |"
    echo "|   6. Cambiar DNS                    |"
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