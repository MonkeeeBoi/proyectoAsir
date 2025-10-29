# shellcheck disable=SC1091
source funciones.bash

function menuGestUser() {
    echo "comprobando paquetes necesario..."
    if ! apt update &> /dev/null; then
        echo "❌ Error: fallo al actualizar los paquetes..."
        exit 1
    fi
    if ! estaInstalado "openssl"; then
        echo "instando paquetes necesarios..."
        apt install openssl
    fi
    clear
    while true; do
        echo "+-------------------------------------+"
        echo "|                                     |"
        echo "|    1. Creación de usuarios          |"
        echo "|    2. Eliminación de usuarios       |"
        echo "|    3. Permisos a usuario            |"
        echo "|    4. Cambiar contraseña de usuario |"
        echo "|    5. Ver usuarios conectados       |"
        echo "|    6. Ver tamaños del home          |"
        echo "|    7. Ver historial de usuarios     |"
        echo "|                                     |"
        echo "|    0. Volver                        |"
        echo "+-------------------------------------+"

        read -rp "Introduce una opcion: " opcSelect

        case $opcSelect in
            1) 
                clear
                crearUsuario
            ;;
            2) 
                clear
                eliminarUsuario
            ;;
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

function crearUsuario() {

    while true; do
        read -rp "Introduce el nombre del nuevo usuario: " nombreUsuario

        if ! comprobarVariable "$nombreUsuario"; then
            continue
        fi
        if ! comprobarUsuario "$nombreUsuario"; then
            echo "❌ Error: El usuario existe en el sistema..."
            continue
        fi
        break
    done

    while true; do
        read -rsp "Introduce la contraseña para el usuario: " usuarioPass

        if ! comprobarVariable "$usuarioPass"; then
            continue
        fi
        break
    done

    while true; do
        echo ""
        read -rp "Quieres que se cree el home del usuario [y/n]: " usuarioHome

        if ! comprobarVariable "$usuarioHome"; then
            continue
        fi
        if ! comprobarYesOrNo "$usuarioHome"; then
            continue
        fi
        break
    done

    if YesOrNo "$usuarioHome"; then
        echo "creando home del usuario..."
        useradd -m -p "$(securePass "$usuarioPass")" "$nombreUsuario" &> /dev/null
    else
        useradd -p "$(securePass "$usuarioPass")" "$nombreUsuario" &> /dev/null
    fi
    
    echo "✅ Proceso de creación para '$nombreUsuario' completado."
}

function eliminarUsuario() {
    while true; do
        read -rp "Introduce el nombre del usuario a eliminar: " nombreUsuario

        if ! comprobarVariable "$nombreUsuario"; then
            continue
        fi
        if comprobarUsuario "$nombreUsuario"; then
            echo "❌ Error: El usuario no existe en el sistema..."
            continue
        fi
        break
    done

    while true; do
        read -rp "Quieres que se elimine el home del usuario [y/n]: " usuarioHome

        if ! comprobarVariable "$usuarioHome"; then
            continue
        fi
        if ! comprobarYesOrNo "$usuarioHome"; then
            continue
        fi
        break
    done

    if YesOrNo "$usuarioHome"; then
        echo "eliminando home del usuario..."
        userdel -r "$nombreUsuario" &> /dev/null
    else
        userdel "$nombreUsuario" &> /dev/null
    fi
    echo "✅ Proceso de eliminación para '$nombreUsuario' completado."
}