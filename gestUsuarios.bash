#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuGestUser() {
    clear
    while true; do
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
            0) break ;;
            *) 
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

    # AHORA SÍ: validar correctamente
    if ! comprobarYesOrNo "$usuarioHome"; then
      continue
    fi

    break
  done

  # Crear usuario según respuesta
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

    # VALIDACIÓN CORRECTA
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
    read -rp "${BLUE}Introduce el NOMBRE DEL USUARIO cuyos archivos quieres modificar:${NC} " nombreUsuario

    if comprobarCadena "$nombreUsuario"; then
      continue
    fi

    if comprobarUsuario "$nombreUsuario"; then
      clear
      echo -e "${RED}Error: El usuario '$nombreUsuario' no existe en el sistema.${NC}"
      continue
    fi

    break
  done

  clear

  # --- Permisos para archivos ---
  while true; do
    read -rp "${BLUE}Introduce los NUEVOS PERMISOS en octal para los ARCHIVOS (644, 755):${NC} " permisosArchivos

    if comprobarCadena "$permisosArchivos" || soloNumerosPermisos "$permisosArchivos"; then
      clear
      echo -e "${RED}Error: entrada no aceptada...${NC}"
      echo -e "${YELLOW}Introduce de nuevo los permisos para los archivos.${NC} '$permisosArchivos'."
      continue
    fi
    break
  done

  # --- Permisos para directorios ---
  while true; do
    read -rp "${BLUE}Introduce los NUEVOS PERMISOS en octal para los DIRECTORIOS (644, 755):${NC} " permisosDirectorios

    if comprobarCadena "$permisosDirectorios" || soloNumerosPermisos "$permisosDirectorios"; then
      clear
      echo -e "${RED}Error: entrada no aceptada...${NC}"
      echo -e "${YELLOW}Introduce de nuevo los permisos para los directorios del usuario ${NC} '$permisosDirectorios'."
      continue
    fi
    break
  done


  # --- Confirmación ---
  while true; do
    echo -e ""
    echo -e "${YELLOW}ADVERTENCIA: Esta operación buscará y modificará los permisos de todos los archivos${NC}"
    echo -e "${YELLOW}y directorios propiedad de '$nombreUsuario' en el sistema.${NC}"
    read -rp "${BLUE}¿Estás seguro de continuar y aplicar permisos $permisosArchivos para los archivos y $permisosDirectorios para los directorios? [Y/n]:${NC}" confirmacion

    if comprobarYesOrNo "$confirmacion"; then
      continue
    fi

    if ! YesOrNo "$confirmacion"; then
      echo -e "${RED}Operación cancelada.${NC}\n"
      break
    fi

    # --- Ejecución de cambios ---
    echo -e "${BLUE}Iniciando búsqueda y cambio de permisos...${NC}\n"

    # Cambiar permisos de archivos
    echo -e "\n${YELLOW}Cambiando permisos de archivos...${NC}\n"
    echo -e "${YELLOW}Esto puede tardar unos minutos...${NC}\n"
    sudo find / -user "$nombreUsuario" -type f -exec chmod "$permisosArchivos" {} \; 2> /dev/null
    archivos_result=$?

        echo -e "${YELLOW}Cambiando permisos de directorios...${NC}"
        sudo find / -user "$nombreUsuario" -type d -exec chmod "$permisosDirectorios" {} \; 2>/dev/null
        directorios_result=$?

        if [[ $archivos_result -eq 0 && $directorios_result -eq 0 ]]; then
          echo -e "${GREEN}Permisos de ARCHIVOS cambiados a '$permisosArchivos' y DIRECTORIOS a '$permisosDirectorios' al usuario '$nombreUsuario'${NC}"
        else
          echo -e "${RED}Error al intentar ejecutar el comando de cambio de permisos.${NC}"
        fi
    break
  done
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
            continue
        fi
        break
    done

    echo -e "${BLUE}Buscando archivos y directorios propiedad de '$nombreUsuario'...${NC}"
    sudo find / -user "$nombreUsuario" -exec ls -ld {} \; 2>/dev/null | head -n 100

    echo -e "${GREEN}Mostrando hasta 100 resultados con permisos.${NC}"
}

