#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuGestGroups() {
   while true; do
    echo ""
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|   1. Ver grupos de usuario          |"
    echo "|   2. Crear un grupo                 |"
    echo "|   3. Añadir grupo a usuario         |"
    echo "|   4. Quitar grupo a usuario         |"
    echo "|   5. Eliminar un grupo              |"
    echo "|                                     |"
    echo "|   0. Volver                         |"
    echo "+-------------------------------------+"
    echo ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            read -rp "Introduce el nombre del usuario: " usuario
            if id "$usuario" &>/dev/null; then
                echo "El usuario '$usuario' pertenece a los siguientes grupos:"
                groups "$usuario"
            else
                echo "El usuario '$usuario' no existe en el sistema."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        2)
            read -p "Introduce el nombre del grupo a crear: " grupo
            if getent group "$grupo" >/dev/null; then
                echo "El grupo '$grupo' ya existe."
            else
                sudo groupadd "$grupo" && echo "Grupo '$grupo' creado correctamente."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        3)
            read -p "Introduce el nombre del usuario: " usuario
            read -p "Introduce el nombre del grupo: " grupo
            if id "$usuario" &>/dev/null && getent group "$grupo" >/dev/null; then
                sudo usermod -aG "$grupo" "$usuario" && echo "Usuario '$usuario' añadido al grupo '$grupo'."
            else
                echo "Usuario o grupo no existen."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        4)
            read -p "Introduce el nombre del usuario: " usuario
            read -p "Introduce el nombre del grupo: " grupo
            if id "$usuario" &>/dev/null && getent group "$grupo" >/dev/null; then
                sudo gpasswd -d "$usuario" "$grupo" && echo "Usuario '$usuario' eliminado del grupo '$grupo'."
            else
                echo "Usuario o grupo no existen."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            clear
            ;;
        5)
            read -p "Introduce el nombre del grupo a eliminar: " grupo
            if getent group "$grupo" >/dev/null; then
                sudo groupdel "$grupo" && echo "Grupo '$grupo' eliminado correctamente."
            else
                echo "El grupo '$grupo' no existe en el sistema."
            fi
            ;;
        0)
            break
            ;;
        *)
            echo "Introduce una opcion valida..."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
    esac
done
}