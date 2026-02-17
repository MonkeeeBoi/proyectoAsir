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
  echo -e "${BLUE}+------------------------------------+${NC}"
  echo -e "${BLUE}|                                    |${NC}"
  echo -e "${BLUE}|${NC}        GESTOR DE FUNCIONES         ${BLUE}|${NC}"
  echo -e "${BLUE}|                                    |${NC}"
  echo -e "${BLUE}+------------------------------------+${NC}"
  echo -e "${BLUE}|                                    |${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}1.${NC} Gestión de usuarios          ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}2.${NC} Gestión de grupos            ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}3.${NC} Gestión de paquetes          ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}4.${NC} Gestión del sistema          ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}5.${NC} Gestión de RED               ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}6.${NC} Servicios y procesos         ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}7.${NC} Mantenimiento y limpieza     ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}8.${NC} Copias de seguridad          ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}9.${NC} Seguridad                    ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}10.${NC} Discos, particiones y RAID  ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${GREEN}11.${NC} Docker                      ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}                                    ${BLUE}|${NC}"
  echo -e "${BLUE}|${NC}    ${RED}0.${NC} Salir                        ${BLUE}|${NC}"
  echo -e "${BLUE}+------------------------------------+${NC}"
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
        0) exit 0 ;;
        *) 
        echo -e "${RED}Introduce una opción válida...${NC}" 
        read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
        clear
        ;;
    esac
done
