@echo off
setlocal

TITLE ATS DX Composite Generator

set "BASE_DIR=%~dp0"

echo "%BASE_DIR%" | find /i "%TEMP%" >nul
if not errorlevel 1 (
    echo.
    echo ==============================================================================
    echo [ERROR] SE ESTA EJECUTANDO DESDE DENTRO DEL ARCHIVO ZIP (Carpeta Temporal)
    echo ==============================================================================
    echo.
    echo El archivo de salida no se guardara correctamente si no lo descomprime.
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
    echo [ERROR] No se ha encontrado el archivo:
    echo %PS_SCRIPT%
    echo.
    echo Estructura esperada:
    echo ATS_Generar_Composite_Windows.bat
    echo Windows\obtener_composite.ps1
    echo Windows\getcid.exe
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

set "EXIT_CODE=%ERRORLEVEL%"

echo.
pause
exit /b %EXIT_CODE%
