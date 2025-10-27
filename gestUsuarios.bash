# shellcheck disable=SC1091
source funciones.bash

function menuGestUser() {
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|    1. Creación de usuarios          |"
    echo "|    2. Eliminación de usuarios       |"
    echo "|    3. Permisos a usuario            |"
    echo "|    4. Cambiar contraseña de usuario |"
    echo "|    5. Ver usuarios conectados       |"
    echo "|                                     |"
    echo "|    0. Volver                        |"
    echo "+-------------------------------------+"

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1) 
            clear
            crearUsuario
        ;;
        2) ;;
        3) ;;
        4) ;;
        5) ;;
        0) break ;;
        *) echo "Introduce una opcion valida..." ;;
    esac
done
}

function crearUsuario() {

    while true; do
        read -rp "Introduce el nombre del nuevo usuario: " nombre_usuario
        if comprobarVariable "$nombre_usuario"; then
            break;
        fi
    done
}