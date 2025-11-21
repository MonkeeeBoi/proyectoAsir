#!/bin/bash
# Proyecto

#librerias
# shellcheck disable=SC1091
source gestUsuarios.bash
source gestSistem.bash
source gestPacks.bash
source gestNetwork.bash
source servicesANDprocesses.bash
source maintenanceANDcleaning.bash
source backups.bash
source security.bash
source disks-partitions-raid.bash
# Menu

while true; do
  clear
  echo ""
  echo "+------------------------------------+"
  echo "|                                    |"
  echo "|    1. Gestión de Usuarios          |"
  echo "|    2. Gestión de paquetes          |"
  echo "|    3. Gestión del sistema          |"
  echo "|    4. Gestión de RED               |"
  echo "|    5. Servicios y procesos         |"
  echo "|    6. Mantenimiento y limpieza     |"
  echo "|    7. Copias de seguridad          |"
  echo "|    8. Seguridad                    |"
  echo "|    9. Discos, particiones y RAID   |"
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
            menuGestPacks
        ;;
        3) 
            clear
            menuGestSistem
        ;;
        4) 
            clear
            menuGestNetwork 
        ;;
        5) 
            clear
            menuServicesANDprocesses
        ;;
        6) 
            clear
            menuMaintenanceANDcleaning
        ;;
        7) 
            clear
            menuBackups
        ;;
        8) 
            clear
            menuSecurity
        ;;
        9) 
            clear
            disks-partitions-raid
        ;; 
        0) exit 0 ;;
        *) 
        echo "Introduce una opcion valida..." 
        read -n1 -srp "Presione una tecla para continuar..."
        ;;
    esac
done
