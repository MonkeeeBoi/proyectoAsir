function comprobarVariable() {
    if [[ -z "$1" ]]; then
        echo "❌ Error: la cadena introducida no puede ser vacia..."
        return 1
    else
        return 0
    fi
}