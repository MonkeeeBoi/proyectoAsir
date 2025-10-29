function comprobarVariable() {
    if [[ -z "$1" ]]; then
        echo "❌ Error: la cadena introducida no puede ser vacia..."
        return 1
    else
        return 0
    fi
}

function comprobarUsuario() {
    if id "$1" &> /dev/null; then
        echo "❌ Error: El usuario existe en el sistema..."
        return 1
    else
        return 0
    fi
}

function comprobarYesOrNo() {
    if ! [[ "$1" == "y" || "$1" == "yes" || "$1" == "YES" ||  "$1" == "Y" ]]; then
        return 0
    elif ! [[  "$1" == "n" || "$1" == "no" || "$1" == "NO" ||  "$1" == "N"  ]]; then
        return 0
    else
        echo "❌ Error: Opcion no valida..."
        return 1
    fi
}

function YesOrNo() {
    if ! [[ "$1" == "y" || "$1" == "yes" || "$1" == "YES" ||  "$1" == "Y" ]]; then
        return 0
    elif ! [[  "$1" == "n" || "$1" == "no" || "$1" == "NO" ||  "$1" == "N"  ]]; then
        return 1
    fi
}

function securePass() {
    (echo "$1" | openssl passwd -6 -stdin)
}