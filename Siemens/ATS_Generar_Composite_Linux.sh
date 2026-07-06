#!/bin/bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPT="$BASE_DIR/Linux/obtener_composite.sh"

if [ ! -f "$SCRIPT" ]; then
    echo "[ERROR] No se ha encontrado el archivo:"
    echo "$SCRIPT"
    echo ""
    echo "Estructura esperada:"
    echo "ATS_Generar_Composite_Linux.sh"
    echo "Linux/obtener_composite.sh"
    echo "Linux/getcid"
    echo ""
    read -p "Presione Enter para salir..."
    exit 1
fi

chmod +x "$SCRIPT" 2>/dev/null
chmod +x "$BASE_DIR/Linux/getcid" 2>/dev/null

bash "$SCRIPT"
EXIT_CODE=$?

echo ""
read -p "Presione Enter para salir..."
exit $EXIT_CODE
