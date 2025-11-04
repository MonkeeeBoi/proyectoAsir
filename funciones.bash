function comprobarCadena() {
    if [[ -z "$1" ]]; then
        clear
        echo "❌ Error: la cadena introducida no puede ser vacia..."
        return 0
    else
        return 1
    fi
}

function comprobarUsuario() {
    if id "$1" &> /dev/null; then
        return 1
    else
        return 0
    fi
}

function comprobarYesOrNo() {
    if [[ "$1" == "y" || "$1" == "yes" || "$1" == "YES" ||  "$1" == "Y" ]]; then
        return 1
    elif [[  "$1" == "n" || "$1" == "no" || "$1" == "NO" ||  "$1" == "N"  ]]; then
        return 1
    else
        echo "❌ Error: Opcion no valida..."
        return 0
    fi
}

function YesOrNo() {
    if  [[ "$1" == "y" || "$1" == "yes" || "$1" == "YES" ||  "$1" == "Y" ]]; then
        return 0
    elif [[  "$1" == "n" || "$1" == "no" || "$1" == "NO" ||  "$1" == "N"  ]]; then
        return 1
    fi
}

function securePass() {
    (echo "$1" | openssl passwd -6 -stdin)
}

function estaInstalado() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "ok installed"
}

function soloNumerosPermisos() {
    if [[ "$1" =~ ^[0-9]{3}$ ]]; then
        return 1
    else
        return 0
    fi
}

function soloNumeros(){
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        return 1
    else
        return 0
    fi
}