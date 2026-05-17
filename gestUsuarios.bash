#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuGestUser() {
    while true; do
    clear
        echo -e ""
        echo -e "${BLUE}+-------------------------------------+${NC}"
        echo -e "${BLUE}|                                     |${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}1.${NC} Creación de usuarios          ${BLUE}|${NC} "
        echo -e "${BLUE}|${NC}    ${GREEN}2.${NC} Eliminación de usuarios       ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}3.${NC} Permisos a usuario            ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}4.${NC} Cambiar contraseña de usuario ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}5.${NC} Ver usuarios conectados       ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}6.${NC} Ver tamaños del home          ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}7.${NC} Ver historial de usuarios     ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}8.${NC} Ver permisos de usuario       ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${GREEN}9.${NC} Revisar usuarios              ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}                                     ${BLUE}|${NC}"
        echo -e "${BLUE}|${NC}    ${RED}0.${NC} Volver                        ${BLUE}|${NC}"
        echo -e "${BLUE}+-------------------------------------+${NC}"
        echo -e ""

    read -rp "Introduce una opcion: " opcSelect

        case $opcSelect in
            1) 
                clear
                crearUsuario
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            2) 
                clear
                eliminarUsuario
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            3)  
                clear
                permisosUsuario
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;

            4) 
                clear 
                cambiarPassUsuario 
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            5)
                clear 
                verUsuariosConectados 
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            6)
                clear 
                verTamaniosHome  
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            7)
                clear 
                verHistorialUsuarios 
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            8)
                clear 
                verPermisosUsuario 
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            9)
                clear
                echo -e "${BLUE}Usuarios del sistema con UID >= 1000:${NC}"
                getent passwd | awk -F: '$3 >= 1000 { print " - " $1 }'
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
            0) break ;;
            *) 
                clear
                echo -e "${RED}Introduce una opción válida...${NC}" 
                read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
                clear
            ;;
        esac
    done
}

function crearUsuario() {

  # Pedir nombre de usuario
  while true; do
    read -rp "${BLUE}Introduce el nombre del nuevo usuario:${NC} " nombreUsuario

    if comprobarCadena "$nombreUsuario"; then
      continue
    fi

    if ! comprobarUsuario "$nombreUsuario"; then
      echo -e "${RED}Error: El usuario existe en el sistema...${NC}"
      continue
    fi

    break
  done

  # Pedir contraseña
  while true; do
    read -rsp "${BLUE}Introduce la contraseña para el usuario:${NC} " usuarioPass
    echo ""

    if comprobarCadena "$usuarioPass"; then
      continue
    fi

    break
  done

  # Preguntar si quiere home
  while true; do
    echo ""
    read -rp "${BLUE}¿Quieres que se cree el home del usuario? [y/n]:${NC} " usuarioHome

    if comprobarCadena "$usuarioHome"; then
      continue
    fi

    # Validación
    if ! comprobarYesOrNo "$usuarioHome"; then
      continue
    fi

    break
  done

  # Crear usuario
  if YesOrNo "$usuarioHome"; then
    echo -e "${BLUE}Creando home del usuario...${NC}"
    sudo useradd -m -p "$(securePass "$usuarioPass")" "$nombreUsuario" &>/dev/null
  else
    echo -e "${BLUE}Creando usuario sin home...${NC}"
    sudo useradd -p "$(securePass "$usuarioPass")" "$nombreUsuario" &>/dev/null
  fi

  echo -e "${GREEN}Proceso de creación para '$nombreUsuario' completado.${NC}"
}


function eliminarUsuario() {
  while true; do
    read -rp "${BLUE}Introduce el nombre del usuario a eliminar:${NC} " nombreUsuario

    if comprobarCadena "$nombreUsuario"; then
      continue
    fi

    if comprobarUsuario "$nombreUsuario"; then
      echo -e "${RED}Error: El usuario no existe en el sistema...${NC}"
      continue
    fi

    break
  done

  while true; do
    read -rp "${BLUE}¿Quieres que se elimine el home del usuario? [y/n]:${NC} " usuarioHome

    if comprobarCadena "$usuarioHome"; then
      continue
    fi

    # VALIDACIÓN
    if ! comprobarYesOrNo "$usuarioHome"; then
      continue
    fi

    break
  done

  if YesOrNo "$usuarioHome"; then
    echo -e "${BLUE}Eliminando home del usuario y usuario...${NC}"
    sudo userdel -r "$nombreUsuario" &>/dev/null
  else
    echo -e "${BLUE}Eliminando usuario...${NC}"
    sudo userdel "$nombreUsuario" &>/dev/null
  fi

  echo -e "${GREEN}Proceso de eliminación para '$nombreUsuario' completado.${NC}"
}


function permisosUsuario() {

  # --- Selección del usuario ---
  while true; do
    read -rp "${BLUE}Introduce el NOMBRE DEL USUARIO:${NC} " nombreUsuario

    if comprobarCadena "$nombreUsuario"; then
      continue
    fi

    if comprobarUsuario "$nombreUsuario"; then
      clear
      echo -e "${RED}Error: El usuario '$nombreUsuario' no existe.${NC}"
      continue
    fi

    break
  done

  clear

  # --- Ruta del archivo o directorio ---
  while true; do
    read -rp "${BLUE}Introduce la RUTA COMPLETA del archivo o directorio:${NC} " ruta

    if comprobarCadena "$ruta"; then
      continue
    fi

    if [[ ! -e "$ruta" ]]; then
      echo -e "${RED}Error: La ruta no existe.${NC}"
      continue
    fi

    break
  done

  clear

  # --- Permisos ---
  while true; do
    read -rp "${BLUE}Introduce los NUEVOS PERMISOS en octal (644, 755, etc.):${NC} " permisos

    if [[ ! "$permisos" =~ ^[0-7]{3}$ ]]; then
      clear
      echo -e "${RED}Error: permisos inválidos.${NC}"
      continue
    fi

    break
  done

  clear

  # --- Confirmación ---
  echo -e "${YELLOW}Vas a cambiar los permisos de:${NC}"
  echo -e "${BLUE}$ruta${NC}"
  echo -e "${YELLOW}Nuevos permisos:${NC} $permisos"

  read -rp "${BLUE}¿Continuar? [Y/n]: ${NC}" confirmacion
  confirmacion=${confirmacion,,}

  if [[ "$confirmacion" != "y" && "$confirmacion" != "" ]]; then
    echo -e "${RED}Operación cancelada.${NC}"
    return 1
  fi

  # --- Cambio de permisos ---
  sudo chmod "$permisos" "$ruta"

  if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}Permisos cambiados correctamente.${NC}"
    ls -l "$ruta"
  else
    echo -e "${RED}Error al cambiar permisos.${NC}"
  fi
}


function cambiarPassUsuario() {
    while true; do
        read -rp "${BLUE}Introduce el nombre del usuario para cambiar la contraseña:${NC} " nombreUsuario

        if comprobarCadena "$nombreUsuario"; then
            continue
        fi
        if comprobarUsuario "$nombreUsuario"; then
            echo -e "${RED}Error: El usuario no existe en el sistema...${NC}"
            continue
        fi
        break
    done

    while true; do
        read -rsp "${BLUE}Introduce la nueva contraseña:${NC} " nuevaPass
        echo -e ""
        if comprobarCadena "$nuevaPass"; then
            continue
        fi
        break
    done

    if echo -e "$nombreUsuario:$(securePass "$nuevaPass")" | sudo chpasswd -e; then
        echo -e "${GREEN}Contraseña actualizada para el usuario '$nombreUsuario'.${NC}"
    else
        echo -e "${RED}ERROR: No se pudo actualizar la contraseña.${NC}"
    fi
}

function verUsuariosConectados() {
    echo -e "${BLUE}Usuarios actualmente conectados:${NC}"
    who
    echo -e "${GREEN}Fin de listado.${NC}"
}

function verTamaniosHome() {
    echo -e "${BLUE}Tamaños de los directorios home de usuarios reales:${NC}"
    lista_usuarios=$(cat /etc/passwd | grep -E "^[^:]*:[^:]*:[0-9]{4}:")
    IFS=$'\n'
    for linea in $lista_usuarios
    do
        usuario=$(echo -e "$linea" | cut -d: -f1)
        homeUsuario=$(echo -e "$linea" | cut -d: -f6)
        if [[ -d "$homeUsuario" ]]; then
            tamanio=$(sudo du -sh "$homeUsuario" 2>/dev/null | cut -f1)
            echo -e "${YELLOW}Usuario:${NC} $usuario. ${YELLOW}Home:${NC} $homeUsuario. ${YELLOW}Tamaño:${NC} $tamanio"
        fi
    done
    echo -e "${GREEN}Fin de listado.${NC}"
}

function verHistorialUsuarios() {
    echo -e "${BLUE}Historial de inicio de sesión de usuarios:${NC}"
    last | grep -E "^[a-zA-Z0-9_]+"
    echo -e "${GREEN}Fin de historial.${NC}"
}

function verPermisosUsuario() {
    while true; do
        read -rp "${BLUE}Introduce el nombre del usuario para ver sus permisos:${NC} " nombreUsuario

        if comprobarCadena "$nombreUsuario"; then
            continue
        fi
        if comprobarUsuario "$nombreUsuario"; then
            echo -e "${RED}Error: El usuario '$nombreUsuario' no existe en el sistema...${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            continue
        fi
        break
    done

    echo -e "\n${BLUE}===== INFORMACIÓN DEL USUARIO =====${NC}"
    id "$nombreUsuario"

    echo -e "\n${BLUE}===== GRUPOS DEL USUARIO =====${NC}"
    groups "$nombreUsuario"

    echo -e "\n${BLUE}===== VERIFICANDO PERMISOS SUDO =====${NC}"
    if sudo -l -U "$nombreUsuario" &>/dev/null; then
        echo -e "${GREEN}El usuario '$nombreUsuario' tiene permisos sudo.${NC}"
        sudo -l -U "$nombreUsuario"
    else
        echo -e "${RED}El usuario '$nombreUsuario' NO tiene permisos sudo o no está en sudoers.${NC}"
    fi

    echo -e "\n${GREEN}Proceso finalizado.${NC}"
}
