@echo off
setlocal

TITLE ATS DX Composite Generator

set "BASE_DIR=%~dp0"

if not "%BASE_DIR:\AppData\Local\Temp=%"=="%BASE_DIR%" (
    echo.
    echo ==============================================================================
    echo [ERROR] SE ESTA EJECUTANDO DESDE DENTRO DEL ARCHIVO ZIP (Carpeta Temporal)
    echo ==============================================================================
    echo.
    echo El archivo de salida no se guardara correctamente si no lo descomprime primero.
    echo.
    echo Por favor, siga estos pasos:
    echo 1. Cierre esta ventana.
    echo 2. Haga CLIC DERECHO sobre el archivo .zip descargado.
    echo 3. Seleccione "Extraer todo..." o "Extraer aqui".
    echo 4. Entre en la nueva carpeta extraida y ejecute este archivo de nuevo.
    echo.
    pause
    exit /b 1
)

set "WINDOWS_DIR=%BASE_DIR%Windows"
set "PS_SCRIPT=%WINDOWS_DIR%\obtener_composite.ps1"

if not exist "%PS_SCRIPT%" (
    echo.
    echo ==============================================================================
    echo [ERROR] No se han detectado los archivos necesarios.
    echo ==============================================================================
    echo.
    echo Es probable que este ejecutando el script desde dentro del archivo ZIP.
    echo Por favor, siga estas instrucciones:
    echo.
    echo   1. Cierre esta ventana.
    echo   2. Haga CLIC DERECHO sobre el archivo .zip descargado.
    echo   3. Seleccione "Extraer todo..." o "Extraer aqui".
    echo   4. Entre en la nueva carpeta extraida y ejecute este archivo de nuevo.
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

set "EXIT_CODE=%ERRORLEVEL%"

echo.
pause
exit /b %EXIT_CODE%
