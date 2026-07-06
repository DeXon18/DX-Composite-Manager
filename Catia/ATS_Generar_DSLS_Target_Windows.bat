@echo off
setlocal

TITLE ATS DX DSLS Target ID Generator

set "BASE_DIR=%~dp0"
set "WINDOWS_DIR=%BASE_DIR%Windows"
set "PS_SCRIPT=%WINDOWS_DIR%\obtener_target.ps1"

if not exist "%PS_SCRIPT%" (
    echo.
    echo [ERROR] No se ha encontrado el archivo:
    echo %PS_SCRIPT%
    echo.
    echo Estructura esperada:
    echo ATS_Generar_DSLS_Target_Windows.bat
    echo Windows\obtener_target.ps1
    echo Windows\DSLicTarget.exe
    echo.
    pause
    exit /b 1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

set "EXIT_CODE=%ERRORLEVEL%"

echo.
pause
exit /b %EXIT_CODE%
