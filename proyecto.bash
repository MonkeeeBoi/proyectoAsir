#!/bin/bash
# Proyecto

#librerias
# shellcheck disable=SC1091
source gestUsuarios.bash
source gestGrupos.bash
source gestSistem.bash
source gestPacks.bash
source gestNetwork.bash
source servicesANDprocesses.bash
source maintenanceANDcleaning.bash
source backups.bash
source security.bash
source disks-partitions-raid.bash

# librerias necesarias
echo "SYSTEM: comprobando/actualizando paquetes necesarios..."
echo "SYSTEM: Actualizando paquetes..."
if sudo apt update -q; then
    echo "SYSTEM: se ha realiazado la actualizacion de repositorios correctamente..."
else
    echo "ERROR: fallo al actualizar los paquetes..."
fi

echo "Se necesitan los paquetes \"openssl, inxi, btop, fastfetch\""

while true; do
    read -rp "quiere continuar [Y/n]: " respuesta
    if comprobarYesOrNo "$respuesta"; then
        if YesOrNo; then
            break
        else
            exit 0
        fi
    else
        echo "ERROR: Introduce un respuesta valida..."  
    fi
done

echo "instando paquetes necesarios..."
if ! estaInstalado "openssl"; then
    sudo apt install openssl -y
    if ! estaInstalado "openssl"; then
        echo "ERROR: fallo al instalar los paquetes..."
        exit 1
    fi
fi
if ! estaInstalado "inxi"; then
    sudo apt install inxi -y
    if ! estaInstalado "inxi"; then
        echo "ERROR: fallo al instalar los paquetes..."
        exit 1
    fi
fi

if ! estaInstalado "btop"; then
    sudo apt install btop -y
    if ! estaInstalado "btop"; then
        echo "ERROR: fallo al instalar los paquetes..."
        exit 1
    fi
fi

if ! estaInstalado "fastfetch"; then
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
    sudo apt update
    sudo apt install fastfetch -y
    if ! estaInstalado "fastfetch"; then
        echo "ERROR: fallo al instalar los paquetes..."
        exit 1
    fi
fi
clear
# Menu
while true; do
  clear
  echo ""
  echo "+------------------------------------+"
  echo "|                                    |"
  echo "|    1. Gestión de usuarios          |"
  echo "|    2. Gestión de grupos            |"
  echo "|    3. Gestión de paquetes          |"
  echo "|    4. Gestión del sistema          |"
  echo "|    5. Gestión de RED               |"
  echo "|    6. Servicios y procesos         |"
  echo "|    7. Mantenimiento y limpieza     |"
  echo "|    8. Copias de seguridad          |"
  echo "|    9. Seguridad                    |"
  echo "|    10. Discos, particiones y RAID  |"
  echo "|    11. LDAP                        |"
  echo "|                                    |"
  echo "|    0. Salir                        |"
  echo "+------------------------------------+"
  echo ""

  read -rp "Introduce una opcion: " opcSelect
    
    case $opcSelect in
        1)  
            clear
            menuGestUser 
        ;;
        2) 
            clear
            menuGestGroups
        ;;
        3) 
            clear
            menuGestPacks
        ;;
        4) 
            clear
            menuGestSistem
        ;;
        5) 
            clear
            menuGestNetwork 
        ;;
        6) 
            clear
            menuServicesANDprocesses
        ;;
        7) 
            clear
            menuMaintenanceANDcleaning
        ;;
        8) 
            clear
            menuBackups
        ;;
        9) 
            clear
            menuSecurity
        ;;
        10) 
            clear
            disks-partitions-raid
        ;;
        11)
            clear 
        ;;
        0) exit 0 ;;
        *) 
        echo "Introduce una opcion valida..." 
        read -n1 -srp "Presione una tecla para continuar..."
        ;;
    esac
done
