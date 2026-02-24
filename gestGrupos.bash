#!/bin/bash
# shellcheck disable=SC1091
source colores.bash
source funciones.bash

function menuGestGroups() {
   while true; do
    echo -e ""
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}1.${NC} Ver grupos de usuario          ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}2.${NC} Crear un grupo                 ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}3.${NC} Añadir grupo a usuario         ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}4.${NC} Quitar grupo a usuario         ${BLUE}|${NC}"
    echo -e "${BLUE}|${NC}   ${GREEN}5.${NC} Eliminar un grupo              ${BLUE}|${NC}"
    echo -e "${BLUE}|                                     |${NC}"
    echo -e "${BLUE}|${NC}   ${RED}0.${NC} Volver                         ${BLUE}|${NC}"
    echo -e "${BLUE}+-------------------------------------+${NC}"
    echo -e ""

    read -rp "Introduce una opcion: " opcSelect

    case $opcSelect in
        1)
            read -rp "${BLUE}Introduce el nombre del usuario:${NC} " usuario
            if id "$usuario" &>/dev/null; then
                echo -e "${BLUE}El usuario '${NC}$usuario${BLUE}' pertenece a los siguientes grupos:${NC}"
                groups "$usuario"
            else
                echo -e "${RED}El usuario '$usuario' no existe en el sistema.${NC}"
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        2)
            read -rp "${BLUE}Introduce el nombre del grupo a crear:${NC} " grupo
            if getent group "$grupo" >/dev/null; then
                echo -e "${RED}El grupo '$grupo' ya existe.${NC}"
            else
                sudo groupadd "$grupo" && echo -e "${GREEN}Grupo '$grupo' creado correctamente.${NC}"
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        3)
            read -rp "${BLUE}Introduce el nombre del usuario:${NC} " usuario
            read -rp "${BLUE}Introduce el nombre del grupo:${NC} " grupo
            if id "$usuario" &>/dev/null && getent group "$grupo" >/dev/null; then
                sudo usermod -aG "$grupo" "$usuario" && echo -e "${GREEN}Usuario '$usuario' añadido al grupo '$grupo'.${NC}"
            else
                echo -e "${RED}Usuario o grupo no existen.${NC}"
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        4)
            read -rp "${BLUE}Introduce el nombre del usuario:${NC} " usuario
            read -rp "${BLUE}Introduce el nombre del grupo:${NC} " grupo
            if id "$usuario" &>/dev/null && getent group "$grupo" >/dev/null; then
                sudo gpasswd -d "$usuario" "$grupo" && echo -e "${GREEN}Usuario '$usuario' eliminado del grupo '$grupo'.${NC}"
            else
                echo -e "${RED}Usuario o grupo no existen.${NC}"
            fi
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            clear
            ;;
        5)
            read -rp "${BLUE}Introduce el nombre del grupo a eliminar:${NC} " grupo
            if getent group "$grupo" >/dev/null; then
                sudo groupdel "$grupo" && echo -e "${GREEN}Grupo '$grupo' eliminado correctamente.${NC}"
            else
                echo -e "${RED}El grupo '$grupo' no existe en el sistema.${NC}"
            fi
            clear
            ;;
        0)
            break
            ;;
        *)
            echo -e "${RED}Introduce una opción válida...${NC}"
            read -n1 -srp "${YELLOW}Presione una tecla para continuar...${NC}"
            ;;
    esac
done
}