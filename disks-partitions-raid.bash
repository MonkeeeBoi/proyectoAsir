#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuDisksPartitionsRaid() {
   while true; do
    echo -e ""
    echo -e "+-------------------------------------+"
    echo -e "|                                     |"
    echo -e "|   1. Ver discos y particiones       |"
    echo -e "|   2. Crear partición                |"
    echo -e "|   3. Crear sistema de archivos      |"
    echo -e "|   4. Montar y desmontar particiones |"
    echo -e "|   5. Añadir al fstab                |"
    echo -e "|   6. Crear RAID                     |"
    echo -e "|   7. Guardar configuración RAID     |"
    echo -e "|   8. Comprobar estado RAID          |"
    echo -e "|   9. Crear volumen LVM              |"
    echo -e "|                                     |"
    echo -e "|   0. Volver                         |"
    echo -e "+-------------------------------------+"
    echo -e ""
    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            echo -e "Discos y particiones:"
            lsblk
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        2)
            read -rp "Introduce el disco (ej: /dev/sdb): " disco
            echo -e "Lanzando fdisk para crear partición..."
            sudo fdisk "$disco"
            echo -e "Partición creada (si completaste el proceso en fdisk)."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        3)
            read -rp "Introduce la partición (ej: /dev/sdb1): " particion
            read -rp "Introduce el tipo de sistema de archivos (ej: ext4): " tipo
            sudo mkfs -t "$tipo" "$particion"
            echo -e "Sistema de archivos '$tipo' creado en $particion."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        4)
            read -rp "¿Montar (m) o desmontar (d)?: " accion
            if [[ $accion == "m" ]]
            then
                read -rp "Introduce la partición (ej: /dev/sdb1): " particion
                read -rp "Introduce el punto de montaje (ej: /mnt/datos): " punto
                sudo mkdir -p "$punto"
                sudo mount "$particion" "$punto"
                echo -e "Partición montada en $punto."
            elif [[ $accion == "d" ]]
            then
                read -rp "Introduce el punto de montaje a desmontar: " punto
                sudo umount "$punto"
                echo -e "Partición desmontada de $punto."
            else
                echo -e "Opción inválida."
            fi
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        5)
            read -rp "Introduce la partición (ej: /dev/sdb1): " particion
            read -rp "Introduce el punto de montaje (ej: /mnt/datos): " punto
            read -rp "Introduce el tipo de sistema de archivos (ej: ext4): " tipo
            echo -e "$particion $punto $tipo defaults 0 2" | sudo tee -a /etc/fstab > /dev/null
            echo -e "Entrada añadida a /etc/fstab."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        6)
            read -rp "Introduce los dispositivos para RAID separados por espacio (ej: /dev/sdb1 /dev/sdc1): " dispositivos
            read -rp "Introduce el nombre del RAID (ej: /dev/md0): " nombre
            read -rp "Introduce el nivel RAID (ej: 1): " nivel
            if sudo mdadm --create "$nombre" --level="$nivel" --raid-devices="$(echo -e "$dispositivos" | wc -w)" $dispositivos; then
                echo -e "RAID creado como $nombre."
            else
                echo -e "ERROR: No se pudo crear el RAID."
            fi
            echo -e "RAID creado como $nombre."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        7)
            sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf > /dev/null
            echo -e "Configuración RAID guardada en /etc/mdadm/mdadm.conf."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        8)
            sudo mdadm --detail /dev/md0
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        9)
            read -rp "Introduce el nombre del volumen físico (ej: /dev/sdb1): " pv
            read -rp "Introduce el nombre del grupo de volumen: " vg
            read -rp "Introduce el nombre del volumen lógico: " lv
            read -rp "Introduce el tamaño (ej: 5G): " tam
            sudo pvcreate "$pv"
            sudo vgcreate "$vg" "$pv"
            sudo lvcreate -L "$tam" -n "$lv" "$vg"
            echo -e "Volumen LVM creado: /dev/$vg/$lv"
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
        0)
            break
            ;;
        *)
            echo -e "Introduce una opcion valida..."
            read -n1 -srp "Presione una tecla para continuar..."
            ;;
    esac
done
}
