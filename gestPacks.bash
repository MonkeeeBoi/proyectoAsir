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
    echo "|   6. Desinstalar un paquete         |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo "Actualizando lista de paquetes..."
            sudo apt update
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        2)
            echo "Actualizando el sistema..."
            sudo apt upgrade -y
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        3)
            echo "Eliminando paquetes innecesarios..."
            sudo apt autoremove -y
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        4)
            read -rp "Introduce el nombre del paquete a buscar: " paquete
            resultado=$(apt search "$paquete" )
            if [[ $resultado != "" ]]
            then
                echo "Paquete encontrado:"
                echo "$resultado"
            else
                echo "No se encontró el paquete '$paquete'."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        5)
            read -rp "Introduce el nombre del paquete a instalar: " paquete
            sudo apt install "$paquete" -y
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        6)
            read -rp "Introduce el nombre del paquete a desinstalar: " paquete
            sudo apt remove "$paquete" -y
            read -n1 -s -r -p "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo "Introduce una opción válida..."
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
    esac
done
}
