#!/bin/bash
# Proyecto

#librerias
# shellcheck disable=SC1091
source colores.bash
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
  echo -e ""
  echo -e "+------------------------------------+"
  echo -e "|                                    |"
  echo -e "|        GESTOR DE FUNCIONES         |"
  echo -e "|                                    |"
  echo -e "+------------------------------------+"
  echo -e "|                                    |"
  echo -e "|    1. Gestión de usuarios          |"
  echo -e "|    2. Gestión de grupos            |"
  echo -e "|    3. Gestión de paquetes          |"
  echo -e "|    4. Gestión del sistema          |"
  echo -e "|    5. Gestión de RED               |"
  echo -e "|    6. Servicios y procesos         |"
  echo -e "|    7. Mantenimiento y limpieza     |"
  echo -e "|    8. Copias de seguridad          |"
  echo -e "|    9. Seguridad                    |"
  echo -e "|    10. Discos, particiones y RAID  |"
  echo -e "|    11. Docker                      |"
  echo -e "|    12. LDAP                        |"
  echo -e "|                                    |"
  echo -e "|    0. Salir                        |"
  echo -e "+------------------------------------+"
  echo -e ""

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
            menuDocker
        ;;
        12)
            clear 
        ;;
        0) exit 0 ;;
        *) 
        echo -e "Introduce una opcion valida..." 
        read -n1 -srp "Presione una tecla para continuar..."
        ;;
    esac
done
