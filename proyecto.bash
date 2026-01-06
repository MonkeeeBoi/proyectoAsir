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
source montarDocker.sh

# librerias necesarias
comprobar_dependencias
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
  echo "|    11. Docker                       |"
  echo "|    12. LDAP                        |"
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
            menuDisksPartitionsRaid
        ;;
        11)
            clear
            main
        ;;
        12)
            clear 
        ;;
        0) exit 0 ;;
        *) 
        echo "Introduce una opcion valida..." 
        read -n1 -srp "Presione una tecla para continuar..."
        ;;
    esac
done
