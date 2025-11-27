#!/bin/bash
# shellcheck disable=SC1091
source funciones.bash

function menuGestUser() {
  echo "comprobando/actualizando paquetes necesarios..."
  touch ~/.gestorLinux
  if ! [[ "$(cut -d: -f1 <~/.gestorLinux)" == "OK" ]]; then
    if ! sudo apt update -q; then
      echo "❌ Error: fallo al actualizar los paquetes..."
    else
      echo "OK:" >~/.gestorLinux
    fi
  fi

  if ! estaInstalado "openssl"; then
    echo "instando paquetes necesarios..."
    sudo apt install openssl
    if ! estaInstalado "openssl"; then
      echo "❌ Error: fallo al instalar los paquetes..."
      exit 1
    fi
  fi
    clear
    while true; do
        echo ""
        echo "+-------------------------------------+"
        echo "|                                     |"
        echo "|    1. Creación de usuarios          |"
        echo "|    2. Eliminación de usuarios       |"
        echo "|    3. Permisos a usuario            |"
        echo "|    4. Cambiar contraseña de usuario |"
        echo "|    5. Ver usuarios conectados       |"
        echo "|    6. Ver tamaños del home          |"
        echo "|    7. Ver historial de usuarios     |"
        echo "|    8. Ver permisos de usuario       |"
        echo "|                                     |"
        echo "|    0. Volver                        |"
        echo "+-------------------------------------+"
        echo ""

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
            3)  
                clear
                permisosUsuario
            ;;

            #esto lo he hecho yo

            4) 
                clear 
                cambiarPassUsuario 
            ;;
            5)
                clear 
                verUsuariosConectados 
            ;;
            6)
                clear 
                verTamaniosHome  
            ;;
            7)
                clear 
                verHistorialUsuarios 
            ;;
            8)
                clear 
                verPermisosUsuario 
            ;;
            0) 
                clear
                break
            ;;
            *)
              clear 
              echo "Introduce una opcion valida..."
              break;   
            ;;
        esac
    done
}

function crearUsuario() {

  while true; do
    read -rp "Introduce el nombre del nuevo usuario: " nombreUsuario

    if comprobarCadena "$nombreUsuario"; then
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

    if comprobarCadena "$usuarioPass"; then
      continue
    fi
    break
  done

  while true; do
    echo ""
    read -rp "Quieres que se cree el home del usuario [y/n]: " usuarioHome

    if comprobarCadena "$usuarioHome"; then
      continue
    fi
    if comprobarYesOrNo "$usuarioHome"; then
      continue
    fi
    break
  done

  if YesOrNo "$usuarioHome"; then
    echo "creando home del usuario..."
    sudo useradd -m -p "$(securePass "$usuarioPass")" "$nombreUsuario" &>/dev/null
  else
    sudo useradd -p "$(securePass "$usuarioPass")" "$nombreUsuario" &>/dev/null
  fi

  echo "✅ Proceso de creación para '$nombreUsuario' completado."
}

function eliminarUsuario() {
  while true; do
    read -rp "Introduce el nombre del usuario a eliminar: " nombreUsuario

    if comprobarCadena "$nombreUsuario"; then
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

    if comprobarCadena "$usuarioHome"; then
      continue
    fi
    if comprobarYesOrNo "$usuarioHome"; then
      continue
    fi
    break
  done

  if YesOrNo "$usuarioHome"; then
    echo "eliminando home del usuario..."
    sudo userdel -r "$nombreUsuario" &>/dev/null
  else
    sudo userdel "$nombreUsuario" &>/dev/null
  fi
  echo "✅ Proceso de eliminación para '$nombreUsuario' completado."
}

function permisosUsuario() {
  # --- Selección del usuario ---
  while true; do
    read -rp "Introduce el NOMBRE DEL USUARIO cuyos archivos quieres modificar: " nombreUsuario

    if comprobarCadena "$nombreUsuario"; then
      continue
    fi

    if comprobarUsuario "$nombreUsuario"; then
      clear
      printf "❌ Error: El usuario '%s' no existe en el sistema.\n" "$nombreUsuario"
      continue
    fi

    break
  done

  clear

  # --- Permisos para archivos ---
  while true; do
    read -rp "Introduce los NUEVOS PERMISOS en octal para los ARCHIVOS (644, 755): " permisosArchivos

    if comprobarCadena "$permisosArchivos" || soloNumerosPermisos "$permisosArchivos"; then
      clear
      printf "❌ Error: entrada no aceptada...\nIntroduce de nuevo los permisos para los archivos.\n"
      continue
    fi
    break
  done

  # --- Permisos para directorios ---
  while true; do
    read -rp "Introduce los NUEVOS PERMISOS en octal para los DIRECTORIOS (644, 755): " permisosDirectorios

    if comprobarCadena "$permisosDirectorios" || soloNumerosPermisos "$permisosDirectorios"; then
      clear
      printf "❌ Error: entrada no aceptada...\nIntroduce de nuevo los permisos para los directorios.\n"
      continue
    fi
    break
  done


  # --- Confirmación ---
  while true; do
    printf "\n⚠️ ADVERTENCIA: Esta operación buscará y modificará los archivos accesibles\n"
    printf "y directorios accesibles propiedad de '%s' en el sistema.\n\n" "$nombreUsuario"

    read -rp "¿Aplicar permisos $permisosArchivos (archivos) y $permisosDirectorios (directorios)? [Y/n]: " confirmacion

    if comprobarYesOrNo "$confirmacion"; then
      continue
    fi

    if ! YesOrNo "$confirmacion"; then
      printf "Operación cancelada.\n"
      break
    fi

    # --- Ejecución de cambios ---
    printf "Iniciando búsqueda y cambio de permisos...\n"

    # Cambiar permisos de archivos
    printf "\nCambiando permisos de archivos...\n"
    printf "⚠️ Esto puede tardar unos minutos...\n"
    sudo find / -user "$nombreUsuario" -type f -exec chmod "$permisosArchivos" {} \; 2> /dev/null

    # Cambiar permisos de directorios
    printf "\nCambiando permisos de directorios...\n"
    sudo find / -user "$nombreUsuario" -type d -exec chmod "$permisosDirectorios" {} \; 2> /dev/null

    # --- Resultado final ---
    printf "✅ Se han cambiado los permisos de los archivos y directorios accesibles."
    break
  done
}


#esto lo he hecho yo

function cambiarPassUsuario() {
    while true; do
        read -rp "Introduce el nombre del usuario para cambiar la contraseña: " nombreUsuario

        if comprobarCadena "$nombreUsuario"; then
            continue
        fi
        if comprobarUsuario "$nombreUsuario"; then
            echo "❌ Error: El usuario no existe en el sistema..."
            continue
        fi
        break
    done

    while true; do
        read -rsp "Introduce la nueva contraseña: " nuevaPass
        echo ""
        if comprobarCadena "$nuevaPass"; then
            continue
        fi
        break
    done

    echo "$nombreUsuario:$(securePass "$nuevaPass")" | sudo chpasswd -e
    echo "✅ Contraseña actualizada para el usuario '$nombreUsuario'."
}

function verUsuariosConectados() {
    echo "Usuarios actualmente conectados:"
    who
    echo "✅ Fin de listado."
}

function verTamaniosHome() {
    echo "Tamaños de los directorios home de usuarios reales:"
    lista_usuarios=$(cat /etc/passwd | grep -E "^[^:]*:[^:]*:[0-9]{4}:")
    IFS=$'\n'
    for linea in $lista_usuarios
    do
        usuario=$(echo "$linea" | cut -d: -f1)
        homeUsuario=$(echo "$linea" | cut -d: -f6)
        if [[ -d "$homeUsuario" ]]; then
            tamanio=$(sudo du -sh "$homeUsuario" 2>/dev/null | cut -f1)
            echo "Usuario: $usuario. Home: $homeUsuario. Tamaño: $tamanio"
        fi
    done
    echo "✅ Fin de listado."
}

function verHistorialUsuarios() {
    echo "Historial de inicio de sesión de usuarios:"
    last | grep -E "^[a-zA-Z0-9_]+"
    echo "✅ Fin de historial."
}
function verPermisosUsuario() {
    while true; do
        read -rp "Introduce el nombre del usuario para ver sus permisos: " nombreUsuario

        if comprobarCadena "$nombreUsuario"; then
            continue
        fi
        if comprobarUsuario "$nombreUsuario"; then
            echo "❌ Error: El usuario '$nombreUsuario' no existe en el sistema..."
            continue
        fi
        break
    done

    echo "Buscando archivos y directorios propiedad de '$nombreUsuario'..."
    sudo find / -user "$nombreUsuario" -exec ls -ld {} \; 2>/dev/null | head -n 100

    echo "✅ Mostrando hasta 100 resultados con permisos. Puedes ajustar el límite si lo deseas."
}
