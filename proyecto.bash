# Proyecto

#librerias
# shellcheck disable=SC1091
source gestUsuarios.bash
source gestSistem.bash
# Menu

while true; do
    clear
    echo "+------------------------------------+"
    echo "|                                    |"
    echo "|    1. Gestión de Usuarios          |"
    echo "|    2. Gestión de paquetes          |"
    echo "|    3. Gestión del sistema          |"
    echo "|    4. Gestión de RED               |"
    echo "|    5. Servicios y procesos         |"
    echo "|    6. Mantenimiento y limpieza     |"
    echo "|    7. Copias de seguridad          |"
    echo "|    8. Seguridad                    |"
    echo "|    9. Discos, particiones y RAID   |"
    echo "|                                    |"
    echo "|    0. Salir                        |"
    echo "+------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect
    
    case $opcSelect in
        1)  
            clear
            menuGestUser 
        ;;
        2) ;;
        3) 
            clear
            menuGestSistem
        ;;
        4) ;;
        5) ;;
        0) exit 0 ;;
        *) 
        echo "Introduce una opcion valida..." 
        read -n1 -s -r -p "Presione una tecla para continuar..."
        ;;
    esac
done