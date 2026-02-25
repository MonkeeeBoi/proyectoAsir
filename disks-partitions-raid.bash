#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuDisksPartitionsRaid() {
   while true; do
    echo -e ""
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Ver discos y particiones       ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Crear partición                ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Crear sistema de archivos      ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}4.${NC} Montar y desmontar particiones ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}5.${NC} Añadir al fstab                ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}6.${NC} Crear RAID                     ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}7.${NC} Guardar configuración RAID     ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}8.${NC} Comprobar estado RAID          ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}9.${NC} Crear volumen LVM              ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}10.${NC} Formatear disco duro          ${BLUE}|${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "${BLUE}Introduce una opción:${NC} " opcSelect

    case $opcSelect in
        1)
            clear
            echo -e "${BLUE}Discos y particiones:${NC}"
            lsblk
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        2)
            clear
            read -rp "${BLUE}Introduce el disco (ej: /dev/sdb):${NC} " disco
            echo -e "${BLUE}Lanzando fdisk para crear partición...${NC}"
            sudo fdisk "$disco"
            echo -e "${GREEN}Partición creada (si completaste el proceso en fdisk).${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        3)
            clear
            read -rp "${BLUE}Introduce la partición (ej: /dev/sdb1):${NC} " particion
            read -rp "${BLUE}Introduce el tipo de sistema de archivos (ej: ext4):${NC} " tipo
            sudo mkfs -t "$tipo" "$particion"
            echo -e "${GREEN}Sistema de archivos '$tipo' creado en $particion.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;

        4)
            clear
            read -rp "${BLUE}¿Montar (m) o desmontar (d)?:${NC} " accion
            if [[ $accion == "m" ]]; then
                read -rp "${BLUE}Introduce la partición (ej: /dev/sdb1):${NC} " particion
                read -rp "${BLUE}Introduce el punto de montaje (ej: /mnt/datos):${NC} " punto
                sudo mkdir -p "$punto"
                sudo mount "$particion" "$punto"
                echo -e "${GREEN}Partición montada en $punto.${NC}"
            elif [[ $accion == "d" ]]; then
                read -rp "${BLUE}Introduce el punto de montaje a desmontar:${NC} " punto
                sudo umount "$punto"
                echo -e "${GREEN}Partición desmontada de $punto.${NC}"
            else
                echo -e "${RED}ERROR:${NC} Opción inválida."
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        5)
            clear
            read -rp "${BLUE}Introduce la partición (ej: /dev/sdb1):${NC} " particion
            read -rp "${BLUE}Introduce el punto de montaje (ej: /mnt/datos):${NC} " punto
            read -rp "${BLUE}Introduce el tipo de sistema de archivos (ej: ext4):${NC} " tipo
            echo -e "$particion $punto $tipo defaults 0 2" | sudo tee -a /etc/fstab > /dev/null
            echo -e "${GREEN}Entrada añadida a /etc/fstab.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        6)
            clear
            read -rp "${BLUE}Introduce los dispositivos para RAID separados por espacio:${NC} " dispositivos
            read -rp "${BLUE}Introduce el nombre del RAID (ej: /dev/md0):${NC} " nombre
            read -rp "${BLUE}Introduce el nivel RAID (ej: 1):${NC} " nivel

            if sudo mdadm --create "$nombre" --level="$nivel" --raid-devices="$(echo "$dispositivos" | wc -w)" $dispositivos; then
                echo -e "${GREEN}RAID creado como $nombre.${NC}"
            else
                echo -e "${RED}ERROR:${NC} No se pudo crear el RAID."
            fi

            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        7)
            clear
            sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf > /dev/null
            echo -e "${GREEN}Configuración RAID guardada en /etc/mdadm/mdadm.conf.${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        8)
            clear
            sudo mdadm --detail /dev/md0
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;

        9)
            clear
            read -rp "${BLUE}Introduce el volumen físico (ej: /dev/sdb1):${NC} " pv
            read -rp "${BLUE}Introduce el nombre del grupo de volumen:${NC} " vg
            read -rp "${BLUE}Introduce el nombre del volumen lógico:${NC} " lv
            read -rp "${BLUE}Introduce el tamaño (ej: 5G):${NC} " tam

            sudo pvcreate "$pv"
            sudo vgcreate "$vg" "$pv"
            sudo lvcreate -L "$tam" -n "$lv" "$vg"

            echo -e "${GREEN}Volumen LVM creado: /dev/$vg/$lv${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        10)
            clear
# Mostrar discos disponibles
echo "Discos detectados:"
lsblk -d -o NAME,SIZE,MODEL
echo ""

# Pedir disco
read -rp "Introduce el disco a formatear (ej: /dev/sdb): " disco

# Comprobar que existe
if [ ! -b "$disco" ]; then
    echo "ERROR: El disco no existe."
    exit 1
fi

echo ""
echo "Has seleccionado el disco: $disco"
lsblk "$disco"
echo ""

# Primera confirmación
read -rp "¿Seguro que quieres formatear este disco? (yes/no): " conf1
if [[ "$conf1" != "yes" ]]; then
    echo "Operación cancelada."
    exit 0
fi

# Segunda confirmación
read -rp "ESTO BORRARÁ TODO. Escribe: FORMATEAR $disco : " conf2
if [[ "$conf2" != "FORMATEAR $disco" ]]; then
    echo "Operación cancelada."
    exit 0
fi

# Elegir sistema de archivos
echo ""
read -rp "Introduce el sistema de archivos (ext4, xfs, etc.): " fs

echo ""
echo "Formateando $disco como $fs..."
sudo mkfs -t "$fs" "$disco"

echo ""
echo "Disco formateado correctamente."
read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear


        0)
            break
            ;;

        *)
            clear
            echo -e "${RED}ERROR:${NC} Introduce una opción válida..."
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
    esac
done
}

