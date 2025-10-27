# Proyecto

#librerias
# shellcheck disable=SC1091
source gestUsuarios.bash

# Menu

while true; do
    echo "+------------------------------------+"
    echo "|                                    |"
    echo "|    1. Gestión de Usuarios          |"
    echo "|    2. Gestión de paquetes          |"
    echo "|    3. Gestión del sistema          |"
    echo "|    4. Gestión de RED               |"
    echo "|    5. Servicios y procesos         |"
    echo "|                                    |"
    echo "|    0. Salir                        |"
    echo "+------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect
    
    case $opcSelect in
        1) menuGestUser ;;
        2) ;;
        3) ;;
        4) ;;
        5) ;;
        0) exit 0 ;;
        *) echo "Introduce una opcion valida..." ;;
    esac
done