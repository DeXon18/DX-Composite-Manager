#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." >/dev/null 2>&1 && pwd)"
OUT_FILE="$BASE_DIR/composite.txt"
GETCID_PATH="$(dirname "${BASH_SOURCE[0]}")/getcid"

C_FRAME='\033[0;33m'
C_BRAND='\033[1;30m'
C_TEXT='\033[1;37m'
C_HEAD='\033[0;37m'
C_INFO='\033[0;36m'
C_VERS='\033[1;36m'
C_SUCC='\033[0;32m'
C_WARN='\033[1;33m'
C_ERR='\033[0;31m'
C_RESET='\033[0m'

ENV_CACHE=""

detect_env() {
    if [ -n "$ENV_CACHE" ]; then
        echo "$ENV_CACHE"
        return
    fi

    if [ -f /sys/class/dmi/id/sys_vendor ]; then
        local vendor
        local product

        vendor="$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null)"
        product="$(cat /sys/class/dmi/id/product_name 2>/dev/null)"

        case "$vendor" in
            *VMware*)
                ENV_CACHE="VMware"
                ;;
            *Amazon*)
                ENV_CACHE="AWS"
                ;;
            *Google*)
                ENV_CACHE="Google Cloud"
                ;;
            *Microsoft*)
                if [[ "$product" == *"Virtual Machine"* ]]; then
                    ENV_CACHE="Hyper-V / Azure"
                else
                    ENV_CACHE="Microsoft Fisico"
                fi
                ;;
            *QEMU*|*KVM*)
                ENV_CACHE="KVM / QEMU"
                ;;
            *Xen*)
                ENV_CACHE="Xen"
                ;;
            *innotek*|*VirtualBox*)
                ENV_CACHE="VirtualBox"
                ;;
            *)
                ENV_CACHE="Fisico o no identificado"
                ;;
        esac
    else
        ENV_CACHE="Fisico o no identificado"
    fi

    echo "$ENV_CACHE"
}

show_header() {
    clear
    echo ""
    echo -e "${C_FRAME} █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█${C_RESET}"
    echo -e "${C_FRAME} █  ${C_TEXT}ATS DX ${C_FRAME}:: ATS DX Composite ID Generator (Linux)                          █${C_RESET}"
    echo -e "${C_FRAME} █  \033[0;36mSIEMENS \033[1;37m:: Ecosistema de Digital Industries Software y Gestion PLM       ${C_FRAME}█${C_RESET}"
    echo -e "${C_FRAME} █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█${C_RESET}"
    echo ""
    echo -e "${C_HEAD}   ATS GLOBAL SPAIN${C_RESET}"
    echo -e "${C_FRAME}   Developer: Oskar Blazquez (Oskar.Blazquez@ats-global.com)${C_RESET}"
    echo -e "${C_FRAME}   Soporte: Soporte@ats-global.com o 945298229${C_RESET}"
    echo -e "${C_BRAND}   --------------------------------------------------------------------------${C_RESET}"
    echo ""
}

show_menu() {
    echo -ne "${C_TEXT}   Entorno detectado: ${C_RESET}"
    echo -e "${C_VERS}$(detect_env)${C_RESET}"
    echo ""
    echo -e "${C_TEXT}   Seleccione una opcion:${C_RESET}"
    echo ""
    echo -e "${C_TEXT}   1. Licencia Estandar (Maquina fisica o virtual local)${C_RESET}"
    echo -e "${C_TEXT}   2. Licencia Solid Edge (Node locked)${C_RESET}"
    echo -e "${C_TEXT}   3. Licencia Cloud Automatico (AWS / Google Cloud)${C_RESET}"
    echo -e "${C_TEXT}   4. Licencia Cloud Especifico (Microsoft Azure)${C_RESET}"
    echo -e "${C_TEXT}   5. Generar TODOS los identificadores (Solo si soporte lo pide)${C_RESET}"
    echo -e "${C_TEXT}   6. Ayuda: ¿Cual elijo?${C_RESET}"
    echo -e "${C_TEXT}   7. Salir${C_RESET}"
    echo ""
}

show_help() {
    show_header
    echo ""
    echo -e "   ${C_INFO}--- AYUDA DE OPCIONES ---${C_RESET}"
    echo -e "   ${C_TEXT}1. Licencia Estandar: Para maquinas fisicas o virtuales locales, como VMware o VirtualBox.${C_RESET}"
    echo -e "   ${C_TEXT}2. Solid Edge: Usa identificador composite2 para licencias Node locked.${C_RESET}"
    echo -e "   ${C_TEXT}3. Entorno Cloud: Para maquinas AWS o Google Cloud.${C_RESET}"
    echo -e "   ${C_TEXT}4. Azure: Exclusivo para maquinas virtuales en Microsoft Azure.${C_RESET}"
    echo -e "   ${C_TEXT}5. Todos: Ejecuta todos los chequeos. Usar solo si soporte lo solicita.${C_RESET}"
    echo ""
    read -r -p "   Pulse Enter para volver al menu..."
}

init_file() {
    > "$OUT_FILE"
    echo "ATS DX Composite ID Generator (Linux)" >> "$OUT_FILE"
    echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')" >> "$OUT_FILE"
    echo "Equipo: $(hostname)" >> "$OUT_FILE"
    echo "Usuario: ${USER:-desconocido}" >> "$OUT_FILE"
    echo "Ruta: $BASE_DIR" >> "$OUT_FILE"
    echo "Entorno detectado: $(detect_env)" >> "$OUT_FILE"
    echo "" >> "$OUT_FILE"
}

invoke_getcid() {
    local title="$1"
    local arg="$2"
    local tmp_file
    local pid
    local exit_code
    local spin='|/-\'
    local i=0

    tmp_file="$(mktemp)"

    echo -e "\n   ${C_INFO}$title${C_RESET}"
    echo -e "${C_BRAND}   --------------------------------------------------------------------------${C_RESET}"

    echo "" >> "$OUT_FILE"
    echo "=============================================================================" >> "$OUT_FILE"
    echo "$title" >> "$OUT_FILE"
    echo "Comando: getcid $arg -nopause" >> "$OUT_FILE"
    echo "=============================================================================" >> "$OUT_FILE"

    echo -ne "   ${C_INFO}[..] Ejecutando... espere${C_RESET}"

    "$GETCID_PATH" "$arg" -nopause > "$tmp_file" 2>&1 &
    pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % 4 ))
        printf "\r   ${C_INFO}[%s] Ejecutando... espere${C_RESET}" "${spin:$i:1}"
        sleep 0.1
    done

    wait "$pid"
    exit_code=$?

    printf "\r                                              \r"

    if [ ! -s "$tmp_file" ]; then
        echo -e "   ${C_WARN}[AVISO] Sin salida.${C_RESET}"
        echo "[AVISO] Sin salida." >> "$OUT_FILE"
        rm -f "$tmp_file"
        return 1
    fi

    cat "$tmp_file" >> "$OUT_FILE"
    rm -f "$tmp_file"

    if [ "$exit_code" -eq 0 ]; then
        echo -e "   ${C_SUCC}[OK] Datos generados correctamente.${C_RESET}"
        return 0
    else
        echo -e "   ${C_ERR}[ERROR] El comando finalizo con codigo $exit_code${C_RESET}"
        echo "[ERROR] Codigo de salida: $exit_code" >> "$OUT_FILE"
        return 1
    fi
}

finish_process() {
    echo ""
    echo -e "   ${C_SUCC}[OK] Proceso finalizado.${C_RESET}"
    echo ""
    echo -e "   ${C_TEXT}Fichero generado:${C_RESET}"
    echo -e "   ${C_VERS}$OUT_FILE${C_RESET}"
    echo ""
    echo -e "   ${C_TEXT}Por favor envie el fichero composite.txt a quien se lo haya solicitado.${C_RESET}"
    echo -e "   ${C_TEXT}En caso de duda, enviarlo a Soporte@ats-global.com${C_RESET}"
    echo ""
}

show_header

if [ ! -f "$GETCID_PATH" ]; then
    echo -e "   ${C_ERR}[ERROR] No se ha detectado getcid para Linux.${C_RESET}"
    echo ""
    echo -e "   ${C_TEXT}Instrucciones:${C_RESET}"
    echo -e "   ${C_TEXT}1. Extraiga todo el contenido del ZIP.${C_RESET}"
    echo -e "   ${C_TEXT}2. Verifique que el binario 'getcid' esta dentro de la carpeta Linux.${C_RESET}"
    echo -e "   ${C_TEXT}3. Ejecute de nuevo ATS_Generar_Composite_Linux.sh${C_RESET}"
    echo ""
    exit 1
fi

if [ ! -x "$GETCID_PATH" ]; then
    echo -e "   ${C_WARN}[AVISO] El binario getcid no tiene permisos de ejecucion.${C_RESET}"
    echo -e "   ${C_TEXT}Intentando aplicar permisos automaticamente...${C_RESET}"
    chmod +x "$GETCID_PATH" 2>/dev/null

    if [ ! -x "$GETCID_PATH" ]; then
        echo -e "   ${C_ERR}[ERROR] No se pudieron aplicar permisos de ejecucion a getcid.${C_RESET}"
        echo ""
        echo -e "   ${C_TEXT}Ejecute manualmente:${C_RESET}"
        echo -e "   ${C_VERS}chmod +x \"$GETCID_PATH\"${C_RESET}"
        echo ""
        exit 1
    fi
fi

while true; do
    show_menu
    read -r -p "   Introduzca una opcion: " option

    if [ "$option" = "7" ]; then
        echo ""
        echo -e "   ${C_WARN}Proceso cancelado por el usuario.${C_RESET}"
        echo ""
        exit 0
    elif [ "$option" = "6" ]; then
        show_help
        continue
    fi

    case "$option" in
        1|2|3|4|5)
            break
            ;;
        *)
            echo ""
            echo -e "   ${C_ERR}Opcion no valida. Intentelo de nuevo.${C_RESET}"
            echo ""
            ;;
    esac
done

show_header
init_file

case "$option" in
    1)
        invoke_getcid "Entorno virtual/local no Cloud" "-nocloud"
        ;;
    2)
        invoke_getcid "Generar Solid Edge (composite2)" "-composite2"
        ;;
    3)
        invoke_getcid "Entorno Cloud automatico" "-cloud"
        ;;
    4)
        invoke_getcid "Microsoft Azure" "-azure"
        ;;
    5)
        invoke_getcid "Todos los IDs recomendados" "-allcomposite"
        invoke_getcid "Entorno Cloud automatico" "-cloud"
        invoke_getcid "Microsoft Azure" "-azure"
        invoke_getcid "Entorno virtual/local no Cloud" "-nocloud"
        ;;
esac

finish_process
