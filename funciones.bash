#!/bin/bash
function comprobarCadena() {
    if [[ -z "$1" ]]; then
        clear
        echo "ERROR: la cadena introducida no puede ser vacia..."
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
        echo "ERROR: Opcion no valida..."
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

comprobar_dependencias() {
    dependenciasNecesarias="openssl inxi btop fastfetch"
    dependenciasNoInstaladas=""
    echo "SYSTEM: comprobando/actualizando paquetes necesarios..."
    echo "SYSTEM: Actualizando paquetes..."

    if sudo apt update -q; then
        echo "SYSTEM: se ha realiazado la actualizacion de repositorios correctamente..."
    else
        echo "ERROR: fallo al actualizar los paquetes..."
    fi
    for cmd in $dependenciasNecesarias; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            dependenciasNoInstaladas+="$cmd "
        fi
    done
    echo "Se necesitan los paquetes [$dependenciasNoInstaladas]"
    while true; do
        read -rp "quiere continuar [Y/n]: " respuesta
        if comprobarYesOrNo "$respuesta"; then
            if YesOrNo "$respuesta"; then
                break
            else
                exit 0
            fi
        else
            echo "ERROR: Introduce un respuesta valida..."  
        fi
    done
    for cmd in $dependenciasNoInstaladas; do
        echo "SYSTEM: Instalando la dependencia $cmd"
        if ! command -v fastfetch > /dev/null 2>&1; then
            sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
            sudo apt update
            sudo apt install fastfetch -y
        elif ! command -v "$cmd" > /dev/null 2>&1; then
            sudo apt install "$cmd"
        fi
    done

    for cmd in $dependenciasNoInstaladas; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            echo "ERROR: Falta el comando '$cmd'. Saliendo..."
            exit 1
        fi
    done
}