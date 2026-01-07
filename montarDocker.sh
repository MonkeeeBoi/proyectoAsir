#!/bin/bash

# Script para montar contenedores Docker con selección de imagen y carpeta compartida
# shellcheck disable=SC1091
source colores.bash

# Función para mostrar el uso
mostrar_uso() {
    echo -e "${BLUE}Uso: $0 [opciones]${NC}"
    echo "Opciones:"
    echo "  -h, --help     Muestra esta ayuda"
    echo "  -v, --verbose  Modo verbose"
    echo ""
    echo "El script te permitirá:"
    echo "1. Montar contenedor interactivo con imagen seleccionada"
    echo "2. Crear nuevo contenedor con configuración personalizada"
    echo "3. Lanzar contenedor existente de forma interactiva"
    echo "4. Eliminar contenedores existentes"
    echo "5. Obtener nuevas imágenes Docker desde Docker Hub"
    echo "6. Eliminar imágenes Docker locales"
    echo "7. Mostrar imágenes Docker disponibles"
    echo "8. Mostrar contenedores activos y detenidos"
    echo ""
    echo "Características:"
    echo "- Descarga de imágenes desde Docker Hub"
    echo "- Lanzamiento interactivo con tty (-t) para terminal completa"
    echo "- Conexión a contenedores en ejecución con docker exec -it"
    echo "- Inicio de contenedores con docker start -ia para máxima interactividad"
    echo "- Eliminación segura de imágenes con verificación de contenedores"
    echo "- Soporte para carpetas compartidas (volúmenes)"
    echo "- Configuración de puertos"
    echo "- Modo detached (segundo plano) o interactivo"
    echo "- Nombres personalizados para contenedores"
}

# Función para verificar si Docker está corriendo
verificar_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}Error: Docker no está corriendo o no tienes permisos${NC}"
        echo -e "${YELLOW}Por favor, inicia Docker o ejecuta con sudo${NC}"
        return 1
    fi
    return 0
}

# Función para verificar si Docker está instalado
verificar_instalacion() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Docker no está instalado${NC}"
        return 1
    else
        echo -e "${GREEN}Docker está instalado${NC}"
        return 0
    fi
}

# Función para validar que la carpeta existe
validar_carpeta() {
    carpeta="$1"
    if [[ ! -d "$carpeta" ]]; then
        echo -e "${RED}Error: La carpeta '$carpeta' no existe${NC}"
        return 1
    fi
    return 0
}

# Función para obtener imágenes Docker disponibles
obtener_imagenes() {
    docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.Created}}" | head -n -1
}

# Función para montar contenedor con imagen seleccionada
montar_contenedor() {
    # Verificar que Docker está corriendo
    if ! verificar_docker; then
        return 1
    fi
    
    # Obtener imágenes disponibles actualizadas
    echo -e "${BLUE}=== Imágenes Docker disponibles ===${NC}"
    imagenes
    readarray -t imagenes < <(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "^<none>" | head -n -1)
    
    if [[ ${#imagenes[@]} -eq 0 ]]; then
        echo -e "${RED}No se encontraron imágenes Docker locales${NC}"
        echo -e "${YELLOW}Puedes descargar imágenes con 'docker pull <nombre_imagen>'${NC}"
        return 1
    fi
    
    # Mostrar imágenes con números
    echo -e "${GREEN}Seleccione una imagen:${NC}"
    for i in "${!imagenes[@]}"; do
        num=$((i + 1))
        imagen="${imagenes[$i]}"
        size=$(docker images --format "{{.Size}}" "$imagen" 2>/dev/null || echo "N/A")
        echo "  $num) $imagen (Tamaño: $size)"
    done
    
    # Seleccionar imagen
    while true; do
        read -p "Ingrese el número de la imagen (1-${#imagenes[@]}): " seleccion
        
        if [[ "$seleccion" =~ ^[0-9]+$ ]] && [[ $seleccion -ge 1 ]] && [[ $seleccion -le ${#imagenes[@]} ]]; then
            indice=$((seleccion - 1))
            imagen_seleccionada="${imagenes[$indice]}"
            break
        else
            echo -e "${RED}Selección inválida. Por favor ingrese un número entre 1 y ${#imagenes[@]}${NC}"
        fi
    done
    
    echo -e "${GREEN}Imagen seleccionada: $imagen_seleccionada${NC}"
    
    # Solicitar carpeta para compartir
    echo ""
    echo -e "${BLUE}=== Configuración de carpeta compartida ===${NC}"
    echo "Ingrese la ruta de la carpeta que desea compartir con el contenedor"
    echo "Ejemplos: /home/usuario/proyectos, ./datos, /tmp/compartido"
    
    while true; do
        read -p "Ruta de la carpeta: " carpeta_local
        
        # Convertir ruta relativa a absoluta
        if [[ "$carpeta_local" == ./* ]] || [[ "$carpeta_local" == ../* ]] || [[ "$carpeta_local" == /* ]]; then
            carpeta_local=$(realpath "$carpeta_local" 2>/dev/null || echo "$carpeta_local")
        fi
        
        if validar_carpeta "$carpeta_local"; then
            break
        else
            read -p "¿Desea crear la carpeta? (s/N): " crear
            if [[ "$crear" =~ ^[Ss]$ ]]; then
                mkdir -p "$carpeta_local"
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}Carpeta creada: $carpeta_local${NC}"
                    break
                else
                    echo -e "${RED}Error al crear la carpeta${NC}"
                fi
            fi
        fi
    done
    
    # Solicitar ruta dentro del contenedor
    read -p "Ruta dentro del contenedor (default: /app/compartido): " carpeta_contenedor
    carpeta_contenedor=${carpeta_contenedor:-/app/compartido}
    
    # Opciones adicionales
    echo ""
    echo -e "${BLUE}=== Opciones adicionales ===${NC}"
    read -p "¿Desea especificar un nombre para el contenedor? (opcional): " nombre_contenedor
    
    read -p "¿Desea exponer puertos? (ejemplo: 8080:80, múltiples separados por coma): " puertos
    
    # Construir comando Docker
    docker_cmd="docker run -it"
    
    # Agregar nombre si se especificó
    if [[ -n "$nombre_contenedor" ]]; then
        docker_cmd="$docker_cmd --name $nombre_contenedor"
    fi
    
    # Agregar montaje de volumen
    docker_cmd="$docker_cmd -v $carpeta_local:$carpeta_contenedor"
    
    # Agregar puertos si se especificaron
    if [[ -n "$puertos" ]]; then
        IFS=',' read -ra PUERTOS_ARRAY <<< "$puertos"
        for puerto in "${PUERTOS_ARRAY[@]}"; do
            puerto=$(echo "$puerto" | xargs)  # Trim whitespace
            if [[ "$puerto" =~ ^[0-9]+:[0-9]+$ ]]; then
                docker_cmd="$docker_cmd -p $puerto"
            else
                echo -e "${YELLOW}Advertencia: Formato de puerto inválido '$puerto', se ignora${NC}"
            fi
        done
    fi
    
    # Agregar imagen
    docker_cmd="$docker_cmd $imagen_seleccionada"
    
    # Mostrar resumen
    echo ""
    echo -e "${BLUE}=== Resumen de la configuración ===${NC}"
    echo -e "${GREEN}Imagen:${NC} $imagen_seleccionada"
    echo -e "${GREEN}Carpeta local:${NC} $carpeta_local"
    echo -e "${GREEN}Carpeta contenedor:${NC} $carpeta_contenedor"
    if [[ -n "$nombre_contenedor" ]]; then
        echo -e "${GREEN}Nombre contenedor:${NC} $nombre_contenedor"
    fi
    if [[ -n "$puertos" ]]; then
        echo -e "${GREEN}Puertos:${NC} $puertos"
    fi
    echo ""
    echo -e "${YELLOW}Comando a ejecutar:${NC}"
    echo "$docker_cmd"
    echo ""
    
    # Confirmar ejecución
    read -p "¿Desea ejecutar el contenedor? (S/n): " confirmar
    if [[ "$confirmar" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        return 0
    fi
    
    # Ejecutar comando
    echo -e "${BLUE}Iniciando contenedor...${NC}"
    eval "$docker_cmd"
    
    # Mensaje final
    echo ""
    echo -e "${GREEN}Contenedor detenido. Para volver a iniciarlo con la misma configuración:${NC}"
    echo "$docker_cmd"
}

# Función para mostrar imágenes
mostrar_imagenes() {
    echo -e "${BLUE}Imágenes disponibles:${NC}"
    docker images
}

# Función para eliminar imágenes
eliminar_imagen() {
    if ! verificar_docker; then
        return 1
    fi
    
    echo -e "${BLUE}=== Eliminar Imagen Docker ===${NC}"
    
    # Obtener imágenes disponibles
    imagenes
    readarray -t imagenes < <(docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.Created}}" | head -n -1)
    
    if [[ ${#imagenes[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No se encontraron imágenes Docker${NC}"
        return 1
    fi
    
    # Mostrar imágenes con números
    echo -e "${GREEN}Seleccione una imagen para eliminar:${NC}"
    for i in "${!imagenes[@]}"; do
        num=$((i + 1))
        info="${imagenes[$i]}"
        imagen=$(echo "$info" | awk '{print $1}')
        size=$(echo "$info" | awk '{print $2}')
        created=$(echo "$info" | awk '{print $3,$4,$5,$6}')
        echo "  $num) $imagen (Tamaño: $size, Creada: $created)"
    done
    
    # Seleccionar imagen
    while true; do
        read -p "Ingrese el número de la imagen (1-${#imagenes[@]}): " seleccion
        
        if [[ "$seleccion" =~ ^[0-9]+$ ]] && [[ $seleccion -ge 1 ]] && [[ $seleccion -le ${#imagenes[@]} ]]; then
            indice=$((seleccion - 1))
            info="${imagenes[$indice]}"
            imagen_seleccionada=$(echo "$info" | awk '{print $1}')
            break
        else
            echo -e "${RED}Selección inválida. Por favor ingrese un número entre 1 y ${#imagenes[@]}${NC}"
        fi
    done
    
    echo -e "${GREEN}Imagen seleccionada: $imagen_seleccionada${NC}"
    
    # Verificar si hay contenedores usando esta imagen
    echo -e "${BLUE}Verificando contenedores que usan esta imagen...${NC}"
    contenedores_usando=$(docker ps -a --filter "ancestor=$imagen_seleccionada" --format "{{.Names}}" 2>/dev/null)
    
    if [[ -n "$contenedores_usando" ]]; then
        echo -e "${YELLOW}ADVERTENCIA: Los siguientes contenedores usan esta imagen:${NC}"
        echo "$contenedores_usando"
        echo ""
        read -p "¿Desea eliminar estos contenedores primero? (s/N): " eliminar_contenedores
        
        if [[ "$eliminar_contenedores" =~ ^[Ss]$ ]]; then
            for contenedor in $contenedores_usando; do
                echo -e "${BLUE}Eliminando contenedor: $contenedor${NC}"
                docker rm -f "$contenedor" 2>/dev/null
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}Contenedor '$contenedor' eliminado${NC}"
                else
                    echo -e "${RED}Error al eliminar contenedor '$contenedor'${NC}"
                fi
            done
        else
            echo -e "${YELLOW}No se puede eliminar la imagen mientras contenedores la usen${NC}"
            return 1
        fi
    fi
    
    # Confirmar eliminación
    echo -e "${RED}ADVERTENCIA: Esta acción eliminará permanentemente la imagen${NC}"
    read -p "¿Está seguro de eliminar la imagen '$imagen_seleccionada'? (s/N): " confirmar
    
    if [[ "$confirmar" =~ ^[Ss]$ ]]; then
        echo -e "${BLUE}Eliminando imagen...${NC}"
        if docker rmi "$imagen_seleccionada"; then
            echo -e "${GREEN}Imagen '$imagen_seleccionada' eliminada exitosamente${NC}"
        else
            echo -e "${RED}Error al eliminar la imagen${NC}"
            echo -e "${YELLOW}Puede que la imagen esté siendo usada por contenedores detenidos. Use 'docker prune' para limpiar${NC}"
        fi
    else
        echo -e "${YELLOW}Operación cancelada${NC}"
    fi
}

# Función para obtener nuevas imágenes
obtener_imagen() {
    if ! verificar_docker; then
        return 1
    fi
    
    echo -e "${BLUE}=== Obtener Nueva Imagen Docker ===${NC}"
    
    # Opciones predefinidas
    echo -e "${GREEN}Imágenes populares:${NC}"
    echo "  1) ubuntu:latest"
    echo "  2) alpine:latest"
    echo "  3) nginx:latest"
    echo "  4) redis:latest"
    echo "  5) mysql:latest"
    echo "  6) postgres:latest"
    echo "  7) python:3.9"
    echo "  8) node:18"
    echo "  9) Especificar imagen personalizada"
    echo ""
    
    while true; do
        read -p "Seleccione una opción (1-9): " seleccion
        
        case $seleccion in
            1)
                imagen="ubuntu:latest"
                break
                ;;
            2)
                imagen="alpine:latest"
                break
                ;;
            3)
                imagen="nginx:latest"
                break
                ;;
            4)
                imagen="redis:latest"
                break
                ;;
            5)
                imagen="mysql:latest"
                break
                ;;
            6)
                imagen="postgres:latest"
                break
                ;;
            7)
                imagen="python:3.9"
                break
                ;;
            8)
                imagen="node:18"
                break
                ;;
            9)
                while true; do
                    read -p "Ingrese el nombre de la imagen (ej: ubuntu:22.04): " imagen_personalizada
                    if [[ -n "$imagen_personalizada" ]]; then
                        imagen="$imagen_personalizada"
                        break
                    else
                        echo -e "${RED}Por favor ingrese un nombre de imagen válido${NC}"
                    fi
                done
                break
                ;;
            *)
                echo -e "${RED}Opción no válida. Por favor seleccione 1-9${NC}"
                ;;
        esac
    done
    
    echo -e "${GREEN}Imagen seleccionada: $imagen${NC}"
    echo ""
    
    # Confirmar descarga
    read -p "¿Desea descargar la imagen '$imagen'? (S/n): " confirmar
    if [[ "$confirmar" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        return 0
    fi
    
    # Descargar imagen
    echo -e "${BLUE}Descargando imagen...${NC}"
    echo -e "${YELLOW}Ejecutando: docker pull $imagen${NC}"
    echo ""
    
    if docker pull "$imagen"; then
        echo ""
        echo -e "${GREEN}Imagen '$imagen' descargada exitosamente${NC}"
        
        # Mostrar información de la imagen
        echo ""
        echo -e "${BLUE}Información de la imagen:${NC}"
        docker images "$imagen"
        
        # Preguntar si desea crear un contenedor
        echo ""
        read -p "¿Desea crear un contenedor con esta imagen ahora? (S/n): " crear_contenedor
        if [[ ! "$crear_contenedor" =~ ^[Nn]$ ]]; then
            # Llamar a la función crear_contenedor con la imagen preseleccionada
            crear_contenedor_con_imagen "$imagen"
        fi
    else
        echo -e "${RED}Error al descargar la imagen${NC}"
    fi
}

# Función para crear contenedor con imagen preseleccionada
crear_contenedor_con_imagen() {
    imagen_preseleccionada="$1"
    
    echo -e "${BLUE}=== Crear Contenedor con Imagen: $imagen_preseleccionada ===${NC}"
    
    # Solicitar nombre del contenedor
    read -p "Nombre del contenedor (opcional): " nombre_contenedor
    
    # Solicitar carpeta para compartir
    echo ""
    echo -e "${BLUE}=== Configuración de carpeta compartida ===${NC}"
    echo "Ingrese la ruta de la carpeta que desea compartir (deje en blanco para omitir)"
    
    carpeta_local=""
    carpeta_contenedor=""
    while true; do
        read -p "Ruta de la carpeta (o Enter para omitir): " carpeta_local
        
        if [[ -z "$carpeta_local" ]]; then
            break
        fi
        
        # Convertir ruta relativa a absoluta
        if [[ "$carpeta_local" == ./* ]] || [[ "$carpeta_local" == ../* ]] || [[ "$carpeta_local" == /* ]]; then
            carpeta_local=$(realpath "$carpeta_local" 2>/dev/null || echo "$carpeta_local")
        fi
        
        if validar_carpeta "$carpeta_local"; then
            read -p "Ruta dentro del contenedor (default: /app/compartido): " carpeta_contenedor
            carpeta_contenedor=${carpeta_contenedor:-/app/compartido}
            break
        else
            read -p "¿Desea crear la carpeta? (s/N): " crear
            if [[ "$crear" =~ ^[Ss]$ ]]; then
                mkdir -p "$carpeta_local"
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}Carpeta creada: $carpeta_local${NC}"
                    read -p "Ruta dentro del contenedor (default: /app/compartido): " carpeta_contenedor
                    carpeta_contenedor=${carpeta_contenedor:-/app/compartido}
                    break
                else
                    echo -e "${RED}Error al crear la carpeta${NC}"
                fi
            fi
        fi
    done
    
    # Solicitar puertos
    read -p "¿Desea exponer puertos? (ejemplo: 8080:80, múltiples separados por coma, o Enter para omitir): " puertos
    
    # Solicitar si se ejecuta en modo detached
    read -p "¿Ejecutar en modo detached (segundo plano)? (s/N): " detached
    detached_flag=""
    if [[ "$detached" =~ ^[Ss]$ ]]; then
        detached_flag="-d"
    fi
    
    # Construir comando Docker
    docker_cmd="docker run $detached_flag"
    
    # Agregar nombre si se especificó
    if [[ -n "$nombre_contenedor" ]]; then
        docker_cmd="$docker_cmd --name $nombre_contenedor"
    fi
    
    # Agregar montaje de volumen si se especificó
    if [[ -n "$carpeta_local" ]]; then
        docker_cmd="$docker_cmd -v $carpeta_local:$carpeta_contenedor"
    fi
    
    # Agregar puertos si se especificaron
    if [[ -n "$puertos" ]]; then
        IFS=',' read -ra PUERTOS_ARRAY <<< "$puertos"
        for puerto in "${PUERTOS_ARRAY[@]}"; do
            puerto=$(echo "$puerto" | xargs)  # Trim whitespace
            if [[ "$puerto" =~ ^[0-9]+:[0-9]+$ ]]; then
                docker_cmd="$docker_cmd -p $puerto"
            else
                echo -e "${YELLOW}Advertencia: Formato de puerto inválido '$puerto', se ignora${NC}"
            fi
        done
    fi
    
    # Agregar imagen
    docker_cmd="$docker_cmd $imagen_preseleccionada"
    
    # Mostrar resumen
    echo ""
    echo -e "${BLUE}=== Resumen de la configuración ===${NC}"
    echo -e "${GREEN}Imagen:${NC} $imagen_preseleccionada"
    if [[ -n "$nombre_contenedor" ]]; then
        echo -e "${GREEN}Nombre contenedor:${NC} $nombre_contenedor"
    fi
    if [[ -n "$carpeta_local" ]]; then
        echo -e "${GREEN}Carpeta local:${NC} $carpeta_local"
        echo -e "${GREEN}Carpeta contenedor:${NC} $carpeta_contenedor"
    fi
    if [[ -n "$puertos" ]]; then
        echo -e "${GREEN}Puertos:${NC} $puertos"
    fi
    if [[ -n "$detached_flag" ]]; then
        echo -e "${GREEN}Modo:${NC} Detached (segundo plano)"
    else
        echo -e "${GREEN}Modo:${NC} Interactivo"
    fi
    echo ""
    echo -e "${YELLOW}Comando a ejecutar:${NC}"
    echo "$docker_cmd"
    echo ""
    
    # Confirmar ejecución
    read -p "¿Desea crear el contenedor? (S/n): " confirmar
    if [[ "$confirmar" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        return 0
    fi
    
    # Ejecutar comando
    echo -e "${BLUE}Creando contenedor...${NC}"
    
    eval "$docker_cmd"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Contenedor creado exitosamente${NC}"
        if [[ -n "$detached_flag" ]]; then
            echo -e "${YELLOW}El contenedor está corriendo en segundo plano${NC}"
        fi
    else
        echo -e "${RED}Error al crear el contenedor${NC}"
    fi
}

# Función para mostrar contenedores
mostrar_contenedores() {
    echo -e "${BLUE}Contenedores activos:${NC}"
    docker ps
    echo -e "\n${BLUE}Todos los contenedores:${NC}"
    docker ps -a
}

# Función para crear contenedor
crear_contenedor() {
    if ! verificar_docker; then
        return 1
    fi
    
    echo -e "${BLUE}=== Crear Nuevo Contenedor ===${NC}"
    
    # Obtener imágenes disponibles actualizadas
    imagenes
    readarray -t imagenes < <(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "^<none>" | head -n -1)
    
    if [[ ${#imagenes[@]} -eq 0 ]]; then
        echo -e "${RED}No se encontraron imágenes Docker locales${NC}"
        echo -e "${YELLOW}Puedes descargar imágenes con 'docker pull <nombre_imagen>'${NC}"
        return 1
    fi
    
    # Mostrar imágenes con números
    echo -e "${GREEN}Seleccione una imagen:${NC}"
    for i in "${!imagenes[@]}"; do
        num=$((i + 1))
        imagen="${imagenes[$i]}"
        size=$(docker images --format "{{.Size}}" "$imagen" 2>/dev/null || echo "N/A")
        echo "  $num) $imagen (Tamaño: $size)"
    done
    
    # Seleccionar imagen
    while true; do
        read -p "Ingrese el número de la imagen (1-${#imagenes[@]}): " seleccion
        
        if [[ "$seleccion" =~ ^[0-9]+$ ]] && [[ $seleccion -ge 1 ]] && [[ $seleccion -le ${#imagenes[@]} ]]; then
            indice=$((seleccion - 1))
            imagen_seleccionada="${imagenes[$indice]}"
            break
        else
            echo -e "${RED}Selección inválida. Por favor ingrese un número entre 1 y ${#imagenes[@]}${NC}"
        fi
    done
    
    echo -e "${GREEN}Imagen seleccionada: $imagen_seleccionada${NC}"
    
    # Solicitar nombre del contenedor
    read -p "Nombre del contenedor (opcional): " nombre_contenedor
    
    # Solicitar carpeta para compartir
    echo ""
    echo -e "${BLUE}=== Configuración de carpeta compartida ===${NC}"
    echo "Ingrese la ruta de la carpeta que desea compartir (deje en blanco para omitir)"
    
    carpeta_local=""
    carpeta_contenedor=""
    while true; do
        read -p "Ruta de la carpeta (o Enter para omitir): " carpeta_local
        
        if [[ -z "$carpeta_local" ]]; then
            break
        fi
        
        # Convertir ruta relativa a absoluta
        if [[ "$carpeta_local" == ./* ]] || [[ "$carpeta_local" == ../* ]] || [[ "$carpeta_local" == /* ]]; then
            carpeta_local=$(realpath "$carpeta_local" 2>/dev/null || echo "$carpeta_local")
        fi
        
        if validar_carpeta "$carpeta_local"; then
            read -p "Ruta dentro del contenedor (default: /app/compartido): " carpeta_contenedor
            carpeta_contenedor=${carpeta_contenedor:-/app/compartido}
            break
        else
            read -p "¿Desea crear la carpeta? (s/N): " crear
            if [[ "$crear" =~ ^[Ss]$ ]]; then
                mkdir -p "$carpeta_local"
                if [[ $? -eq 0 ]]; then
                    echo -e "${GREEN}Carpeta creada: $carpeta_local${NC}"
                    read -p "Ruta dentro del contenedor (default: /app/compartido): " carpeta_contenedor
                    carpeta_contenedor=${carpeta_contenedor:-/app/compartido}
                    break
                else
                    echo -e "${RED}Error al crear la carpeta${NC}"
                fi
            fi
        fi
    done
    
    # Solicitar puertos
    read -p "¿Desea exponer puertos? (ejemplo: 8080:80, múltiples separados por coma, o Enter para omitir): " puertos
    
    # Solicitar si se ejecuta en modo detached
    read -p "¿Ejecutar en modo detached (segundo plano)? (s/N): " detached
    detached_flag=""
    if [[ "$detached" =~ ^[Ss]$ ]]; then
        detached_flag="-d"
    fi
    
    # Construir comando Docker
    docker_cmd="docker run $detached_flag"
    
    # Agregar nombre si se especificó
    if [[ -n "$nombre_contenedor" ]]; then
        docker_cmd="$docker_cmd --name $nombre_contenedor"
    fi
    
    # Agregar montaje de volumen si se especificó
    if [[ -n "$carpeta_local" ]]; then
        docker_cmd="$docker_cmd -v $carpeta_local:$carpeta_contenedor"
    fi
    
    # Agregar puertos si se especificaron
    if [[ -n "$puertos" ]]; then
        IFS=',' read -ra PUERTOS_ARRAY <<< "$puertos"
        for puerto in "${PUERTOS_ARRAY[@]}"; do
            puerto=$(echo "$puerto" | xargs)  # Trim whitespace
            if [[ "$puerto" =~ ^[0-9]+:[0-9]+$ ]]; then
                docker_cmd="$docker_cmd -p $puerto"
            else
                echo -e "${YELLOW}Advertencia: Formato de puerto inválido '$puerto', se ignora${NC}"
            fi
        done
    fi
    
    # Agregar imagen
    docker_cmd="$docker_cmd $imagen_seleccionada"
    
    # Mostrar resumen
    echo ""
    echo -e "${BLUE}=== Resumen de la configuración ===${NC}"
    echo -e "${GREEN}Imagen:${NC} $imagen_seleccionada"
    if [[ -n "$nombre_contenedor" ]]; then
        echo -e "${GREEN}Nombre contenedor:${NC} $nombre_contenedor"
    fi
    if [[ -n "$carpeta_local" ]]; then
        echo -e "${GREEN}Carpeta local:${NC} $carpeta_local"
        echo -e "${GREEN}Carpeta contenedor:${NC} $carpeta_contenedor"
    fi
    if [[ -n "$puertos" ]]; then
        echo -e "${GREEN}Puertos:${NC} $puertos"
    fi
    if [[ -n "$detached_flag" ]]; then
        echo -e "${GREEN}Modo:${NC} Detached (segundo plano)"
    else
        echo -e "${GREEN}Modo:${NC} Interactivo"
    fi
    echo ""
    echo -e "${YELLOW}Comando a ejecutar:${NC}"
    echo "$docker_cmd"
    echo ""
    
    # Confirmar ejecución
    read -p "¿Desea crear el contenedor? (S/n): " confirmar
    if [[ "$confirmar" =~ ^[Nn]$ ]]; then
        echo -e "${YELLOW}Operación cancelada${NC}"
        return 0
    fi
    
    # Ejecutar comando
    echo -e "${BLUE}Creando contenedor...${NC}"
    
    eval "$docker_cmd"
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Contenedor creado exitosamente${NC}"
        if [[ -n "$detached_flag" ]]; then
            echo -e "${YELLOW}El contenedor está corriendo en segundo plano${NC}"
        fi
    else
        echo -e "${RED}Error al crear el contenedor${NC}"
    fi
}

# Función para eliminar contenedor
eliminar_contenedor() {
    if ! verificar_docker; then
        return 1
    fi
    
    echo -e "${BLUE}=== Eliminar Contenedor ===${NC}"
    
    # Obtener contenedores disponibles
    contenedores
    readarray -t contenedores < <(docker ps -a --format "{{.Names}}\t{{.Status}}\t{{.Image}}" | head -n -1)
    
    if [[ ${#contenedores[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No se encontraron contenedores${NC}"
        return 1
    fi
    
    # Mostrar contenedores con números
    echo -e "${GREEN}Seleccione un contenedor para eliminar:${NC}"
    for i in "${!contenedores[@]}"; do
        num=$((i + 1))
        info="${contenedores[$i]}"
        nombre=$(echo "$info" | awk '{print $1}')
        estado=$(echo "$info" | awk '{print $2,$3,$4,$5}')
        imagen=$(echo "$info" | awk '{print $NF}')
        echo "  $num) $nombre (Estado: $estado, Imagen: $imagen)"
    done
    
    # Seleccionar contenedor
    while true; do
        read -p "Ingrese el número del contenedor (1-${#contenedores[@]}): " seleccion
        
        if [[ "$seleccion" =~ ^[0-9]+$ ]] && [[ $seleccion -ge 1 ]] && [[ $seleccion -le ${#contenedores[@]} ]]; then
            indice=$((seleccion - 1))
            info="${contenedores[$indice]}"
            contenedor_seleccionado=$(echo "$info" | awk '{print $1}')
            break
        else
            echo -e "${RED}Selección inválida. Por favor ingrese un número entre 1 y ${#contenedores[@]}${NC}"
        fi
    done
    
    echo -e "${GREEN}Contenedor seleccionado: $contenedor_seleccionado${NC}"
    
    # Verificar si está corriendo
    estado=$(docker inspect --format '{{.State.Status}}' "$contenedor_seleccionado" 2>/dev/null || echo "unknown")
    force_flag=""
    
    if [[ "$estado" == "running" ]]; then
        echo -e "${YELLOW}El contenedor está corriendo${NC}"
        read -p "¿Desea detenerlo y eliminarlo? (s/N): " detener_eliminar
        if [[ ! "$detener_eliminar" =~ ^[Ss]$ ]]; then
            echo -e "${YELLOW}Operación cancelada${NC}"
            return 0
        fi
        force_flag="-f"
    fi
    
    # Confirmar eliminación
    echo -e "${RED}ADVERTENCIA: Esta acción eliminará permanentemente el contenedor${NC}"
    read -p "¿Está seguro de eliminar el contenedor '$contenedor_seleccionado'? (s/N): " confirmar
    
    if [[ "$confirmar" =~ ^[Ss]$ ]]; then
        echo -e "${BLUE}Eliminando contenedor...${NC}"
        if docker rm $force_flag "$contenedor_seleccionado"; then
            echo -e "${GREEN}Contenedor '$contenedor_seleccionado' eliminado exitosamente${NC}"
        else
            echo -e "${RED}Error al eliminar el contenedor${NC}"
        fi
    else
        echo -e "${YELLOW}Operación cancelada${NC}"
    fi
}

# Función para lanzar contenedor existente de forma interactiva
lanzar_contenedor_interactivo() {
    if ! verificar_docker; then
        return 1
    fi
    
    echo -e "${BLUE}=== Lanzar Contenedor Interactivo ===${NC}"
    
    # Obtener contenedores disponibles
    contenedores
    readarray -t contenedores < <(docker ps -a --format "{{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Ports}}" | head -n -1)
    
    if [[ ${#contenedores[@]} -eq 0 ]]; then
        echo -e "${YELLOW}No se encontraron contenedores${NC}"
        echo -e "${YELLOW}Primero cree un contenedor usando la opción 2${NC}"
        return 1
    fi
    
    # Mostrar contenedores con números
    echo -e "${GREEN}Seleccione un contenedor para lanzar:${NC}"
    for i in "${!contenedores[@]}"; do
        num=$((i + 1))
        info="${contenedores[$i]}"
        nombre=$(echo "$info" | awk '{print $1}')
        estado=$(echo "$info" | awk '{print $2,$3,$4,$5}')
        imagen=$(echo "$info" | awk '{print $(NF-2)}')
        puertos=$(echo "$info" | awk '{for(i=NF-1;i<=NF;i++) printf "%s ", $i}' | xargs)
        echo "  $num) $nombre (Estado: $estado, Imagen: $imagen, Puertos: $puertos)"
    done
    
    # Seleccionar contenedor
    while true; do
        read -p "Ingrese el número del contenedor (1-${#contenedores[@]}): " seleccion
        
        if [[ "$seleccion" =~ ^[0-9]+$ ]] && [[ $seleccion -ge 1 ]] && [[ $seleccion -le ${#contenedores[@]} ]]; then
            indice=$((seleccion - 1))
            info="${contenedores[$indice]}"
            contenedor_seleccionado=$(echo "$info" | awk '{print $1}')
            break
        else
            echo -e "${RED}Selección inválida. Por favor ingrese un número entre 1 y ${#contenedores[@]}${NC}"
        fi
    done
    
    echo -e "${GREEN}Contenedor seleccionado: $contenedor_seleccionado${NC}"
    
    # Verificar estado actual
    estado=$(docker inspect --format '{{.State.Status}}' "$contenedor_seleccionado" 2>/dev/null || echo "unknown")
    echo -e "${BLUE}Estado actual: $estado${NC}"
    
    # Opciones según el estado
    case $estado in
        "running")
            echo -e "${YELLOW}El contenedor ya está corriendo${NC}"
            echo ""
            echo "Opciones disponibles:"
            echo "  1) Conectarse al contenedor con terminal (exec -it)"
            echo "  2) Detener y reiniciar con terminal"
            echo "  3) Cancelar"
            echo ""
            
            while true; do
                read -p "Seleccione una opción (1-3): " opcion_lanzar
                
                case $opcion_lanzar in
                    1)
                        echo -e "${BLUE}Conectándose al contenedor con terminal interactiva...${NC}"
                        echo -e "${YELLOW}Ejecutando: docker exec -it $contenedor_seleccionado /bin/bash${NC}"
                        echo -e "${YELLOW}(Si bash no está disponible, intentará con /bin/sh)${NC}"
                        
                        # Iniciar directamente el exec sin comprobar errores para que se muestre la terminal
                        docker exec -it "$contenedor_seleccionado" /bin/bash 2>/dev/null || docker exec -it "$contenedor_seleccionado" /bin/sh
                        return 0
                        ;;
                    2)
                        echo -e "${BLUE}Deteniendo contenedor...${NC}"
                        docker stop "$contenedor_seleccionado"
                        
                        # Para asegurar que obtenemos una terminal, vamos a iniciar el contenedor
                        # y luego conectarnos con exec
                        echo -e "${BLUE}Iniciando contenedor...${NC}"
                        docker start "$contenedor_seleccionado"
                        
                        echo -e "${BLUE}Conectándose al contenedor con terminal...${NC}"
                        echo -e "${YELLOW}Ejecutando: docker exec -it $contenedor_seleccionado /bin/bash${NC}"
                        docker exec -it "$contenedor_seleccionado" /bin/bash 2>/dev/null || docker exec -it "$contenedor_seleccionado" /bin/sh
                        return 0
                        ;;
                    3)
                        echo -e "${YELLOW}Operación cancelada${NC}"
                        return 0
                        ;;
                    *)
                        echo -e "${RED}Opción no válida. Por favor seleccione 1-3${NC}"
                        ;;
                esac
            done
            ;;
        "exited"|"paused"|"created")
            echo -e "${YELLOW}El contenedor está $estado${NC}"
            echo ""
            echo "Opciones disponibles:"
            echo "  1) Reiniciar contenedor con nuevo proceso principal"
            echo "  2) Solo iniciar contenedor (con su comando original)"
            echo "  3) Crear nueva sesión interactiva temporal"
            echo "  4) Cancelar"
            echo ""
            
            while true; do
                read -p "Seleccione una opción (1-4): " opcion_lanzar
                
                case $opcion_lanzar in
                    1)
                        echo -e "${BLUE}Reiniciando contenedor con proceso principal...${NC}"
                        
                        # Obtener la configuración del contenedor existente
                        imagen=$(docker inspect --format '{{.Config.Image}}' "$contenedor_seleccionado" 2>/dev/null)
                        volumes=$(docker inspect --format '{{range .Mounts}}{{.Source}}:{{.Destination}} {{end}}' "$contenedor_seleccionado" 2>/dev/null)
                        ports=$(docker inspect --format '{{range $p, $c := .NetworkSettings.Ports}}{{range $c}}-p {{$p}}:{{$c.HostPort}} {{end}}{{end}}' "$contenedor_seleccionado" 2>/dev/null)
                        
                        if [[ -z "$imagen" ]]; then
                            echo -e "${RED}No se pudo obtener la imagen del contenedor${NC}"
                            return 1
                        fi
                        
                        echo -e "${YELLOW}Imagen detectada: $imagen${NC}"
                        
                        # Construir comando para recrear el contenedor con proceso principal
                        nuevo_nombre="${contenedor_seleccionado}_interactive"
                        docker_cmd="docker run -it --name $nuevo_nombre --rm"
                        
                        # Agregar volúmenes si existen
                        if [[ -n "$volumes" ]]; then
                            for volume in $volumes; do
                                docker_cmd="$docker_cmd -v $volume"
                            done
                        fi
                        
                        # Agregar puertos si existen
                        if [[ -n "$ports" ]]; then
                            docker_cmd="$docker_cmd $ports"
                        fi
                        
                        docker_cmd="$docker_cmd $imagen /bin/bash"
                        
                        echo -e "${BLUE}Creando nueva sesión interactiva...${NC}"
                        echo -e "${YELLOW}Ejecutando: $docker_cmd${NC}"
                        echo -e "${GREEN}Esta es una sesión temporal, se eliminará al salir${NC}"
                        echo ""
                        
                        eval "$docker_cmd"
                        return 0
                        ;;
                    2)
                        echo -e "${BLUE}Iniciando contenedor con su comando original...${NC}"
                        docker start "$contenedor_seleccionado"
                        return 0
                        ;;
                    3)
                        echo -e "${BLUE}Creando nueva sesión interactiva temporal...${NC}"
                        imagen=$(docker inspect --format '{{.Config.Image}}' "$contenedor_seleccionado" 2>/dev/null)
                        if [[ -n "$imagen" ]]; then
                            echo -e "${YELLOW}Usando imagen: $imagen${NC}"
                            docker run -it --rm "$imagen" /bin/bash 2>/dev/null || docker run -it --rm "$imagen" /bin/sh
                        else
                            echo -e "${RED}No se pudo obtener la imagen del contenedor${NC}"
                        fi
                        return 0
                        ;;
                    4)
                        echo -e "${YELLOW}Operación cancelada${NC}"
                        return 0
                        ;;
                    *)
                        echo -e "${RED}Opción no válida. Por favor seleccione 1-4${NC}"
                        ;;
                esac
            done
            ;;
        "unknown"|"dead"|"restarting")
            echo -e "${RED}El contenedor está en estado '$estado' y no puede ser lanzado${NC}"
            echo -e "${YELLOW}Considere eliminar y recrear el contenedor${NC}"
            return 1
            ;;
        *)
            echo -e "${RED}Estado desconocido: $estado${NC}"
            return 1
            ;;
    esac
}



# Menú principal
menu() {
    clear
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     MONTAR CONTENEDORES DOCKER       ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    if verificar_instalacion; then
        echo -e "${GREEN}1.${NC} Montar contenedor interactivo"
        echo -e "${GREEN}2.${NC} Crear nuevo contenedor"
        echo -e "${GREEN}3.${NC} Lanzar contenedor existente"
        echo -e "${GREEN}4.${NC} Eliminar contenedor"
        echo -e "${GREEN}5.${NC} Obtener nueva imagen"
        echo -e "${GREEN}6.${NC} Eliminar imagen"
        echo -e "${GREEN}7.${NC} Mostrar imágenes disponibles"
        echo -e "${GREEN}8.${NC} Mostrar contenedores"
        echo -e "${GREEN}9.${NC} Mostrar ayuda"
        echo -e "${RED}0.${NC} Salir"
    else
        echo -e "${RED}Docker no está instalado${NC}"
        echo -e "${YELLOW}Por favor, instala Docker primero${NC}"
        echo -e "${RED}0.${NC} Salir"
    fi
    
    echo ""
    echo -n "Selecciona una opción: "
}

# Función principal
menuDocker() {
    # Si no hay argumentos, mostrar menú interactivo
    while true; do
        menu
        read -r opcion
        
        case $opcion in
            1)
                if verificar_instalacion; then
                    montar_contenedor
                fi
                ;;
            2)
                if verificar_instalacion; then
                    crear_contenedor
                fi
                ;;
            3)
                if verificar_instalacion; then
                    lanzar_contenedor_interactivo
                fi
                ;;
            4)
                if verificar_instalacion; then
                    eliminar_contenedor
                fi
                ;;
            5)
                if verificar_instalacion; then
                    obtener_imagen
                fi
                ;;
            6)
                if verificar_instalacion; then
                    eliminar_imagen
                fi
                ;;
            7)
                if verificar_instalacion; then
                    mostrar_imagenes
                fi
                ;;
            8)
                if verificar_instalacion; then
                    mostrar_contenedores
                fi
                ;;
            9)
                mostrar_uso
                ;;
            0)
                echo -e "${YELLOW}Saliendo...${NC}"
                break
                ;;
            *)
                echo -e "${RED}Opción no válida${NC}"
                ;;
        esac
        
        echo ""
        echo -n "Presiona Enter para continuar..."
        read -r
    done
}
