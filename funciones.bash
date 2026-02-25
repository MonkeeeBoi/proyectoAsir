#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
function comprobarCadena() {
    if [[ -z "$1" ]]; then
        clear
        echo -e "${RED}ERROR: la cadena introducida no puede ser vacia...${NC}"
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
    case "$1" in
        y|Y|yes|YES|Yes|n|N|no|NO|No)
            return 0   # Entrada válida
            ;;
        *)
            echo -e "${RED}ERROR: Opción no válida...${NC}"
            return 1   # Entrada inválida
            ;;
    esac
}

function YesOrNo() {
    case "$1" in
        y|Y|yes|YES|Yes)
            return 0   # Sí
            ;;
        n|N|no|NO|No)
            return 1   # No
            ;;
    esac
}


function securePass() {
    printf '%s\n' "$1" | openssl passwd -6 -stdin 2>/dev/null || echo -e "${RED}ERROR: No se pudo generar hash de contraseña${NC}"
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
    dependenciasNecesarias="openssl inxi btop fastfetch nmcli docker"
    dependenciasNoInstaladas=""
    echo -e "${BLUE}SYSTEM: comprobando/actualizando paquetes necesarios...${NC}"
    echo -e "${BLUE}SYSTEM: Actualizando paquetes...${NC}"

    if sudo apt update -q; then
        echo -e "${BLUE}SYSTEM: se ha realizado la actualizacion de repositorios correctamente...${NC}"
    else
        echo -e "${RED}ERROR: fallo al actualizar los paquetes...${NC}"
    fi
    for cmd in ${dependenciasNecesarias}; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            dependenciasNoInstaladas+="$cmd "
        fi
    done
    echo -e "${YELLOW}Se necesitan los paquetes:${NC} [$dependenciasNoInstaladas]"
    # Si no hay paquetes que instalar, continuar
    if [[ -z "${dependenciasNoInstaladas// }" ]]; then
        return 0
    fi
    
    while true; do
        read -rp "${BLUE}¿Quiere continuar? [Y/n]:${NC} " respuesta
        if comprobarYesOrNo "$respuesta"; then
            if YesOrNo "$respuesta"; then
                break
            else
                exit 0
            fi
        else
            echo -e "${RED}ERROR: Introduce un respuesta valida...${NC}"  
            sleep 1
        fi
    done
    for cmd in ${dependenciasNoInstaladas}; do
        echo -e "${BLUE}SYSTEM: Instalando la dependencia${NC} ${YELLOW}$cmd${NC}"
        if [ "$cmd" == "fastfetch" ]; then
            if ! command -v fastfetch > /dev/null 2>&1; then
                sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
                sudo apt update
                sudo apt install fastfetch -y
            fi
        elif [ "$cmd" == "nmcli" ]; then
            if ! command -v nmcli > /dev/null 2>&1; then
                sudo apt install network-manager
            fi
        elif [ "$cmd" == "docker" ]; then
            if ! command -v docker > /dev/null 2>&1; then
                sudo apt install docker.io
            fi
        fi
        if ! command -v "$cmd" > /dev/null 2>&1; then
            sudo apt install "$cmd"
        fi
    done

    for cmd in ${dependenciasNoInstaladas}; do
        if ! command -v "$cmd" > /dev/null 2>&1; then
            echo -e "${RED}ERROR: Falta el comando '$cmd'. Saliendo...${NC}"
            exit 1
        fi
    done
}