
function menuGestUser() {
    opcSelect=0
   while true; do
    echo "+-------------------------------------+"
    echo "|                                     |"
    echo "|    1. Creación de usuarios          |"
    echo "|    2. Eliminación de usuarios       |"
    echo "|    3. Permisos a usuario            |"
    echo "|    4. Cambiar contraseña de usuario |"
    echo "|    5. Ver usuarios conectados       |"
    echo "|                                     |"
    echo "|    0. Menu                          |"
    echo "+-------------------------------------+"

    case $opcSelect in
        1) ;;
        2) ;;
        3) ;;
        4) ;;
        5) ;;
        0) break ;;
        *) echo "Introduce una opcion valida..." ;;
    esac
done
}