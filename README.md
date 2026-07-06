# DX-Composite-Manager

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white)
![ATS Global](https://img.shields.io/badge/ATS_Global-Company-003366?style=for-the-badge)

**DX-Composite-Manager** es un conjunto de herramientas diseñadas para facilitar la obtención de identificadores de máquina únicos necesarios para la generación de licencias de software (Siemens y Dassault Systèmes). 

Está pensado para ser ejecutado tanto por usuarios finales como por personal de soporte técnico (ATS Global), ofreciendo una interfaz clara, interactiva y robusta.

## Estructura del Repositorio

El repositorio se divide en dos bloques principales según el software:

### 1. Siemens (`/Siemens`)
Contiene los scripts y binarios necesarios para extraer el **Composite ID** (usado por el gestor de licencias de Siemens).

- **Soporte Multiplataforma**: Scripts disponibles para **Windows** (`.ps1` y `.bat`) y **Linux** (`.sh`).
- **Detección de Entorno**: Detecta automáticamente si se está ejecutando en una máquina física o en entornos virtuales (VMware, VirtualBox, AWS, Azure, Hyper-V, KVM, etc.).
- **Menú Interactivo**:
  - Licencia Estándar (Máquina física o virtual local)
  - Licencia Solid Edge (Node locked / `composite2`)
  - Licencias Cloud Automático o Específico (Azure)
  - Modo completo (Solo para uso de Soporte)

### 2. Catia (`/Catia`)
Contiene los scripts y binarios para extraer el **DSLS Target ID** (usado por el sistema de licencias de Dassault Systèmes / Catia).

- **Soporte Windows**: Diseñado para ejecutarse en sistemas Windows (`.ps1` y `.bat`).
- **Validación Estricta**:
  - Catia **solo** permite licencias en máquinas físicas. El script incluye un bloqueo de seguridad que detiene el proceso si detecta que se ejecuta en una máquina virtual.
  - Verifica si el usuario tiene privilegios de **Administrador** para evitar errores al intentar escribir en el registro de Windows.

## Instrucciones Generales de Uso (Usuarios finales)

Cada carpeta incluye su propio archivo `LEEME.txt` con instrucciones detalladas, pero el proceso general es:

1. Extraer el archivo `.zip` correspondiente (`Siemens` o `Catia`) en una misma carpeta local.
2. Ejecutar el archivo lanzador correspondiente (por ejemplo: `ATS_Generar_Composite_Windows.bat` o `ATS_Generar_DSLS_Target_Windows.bat`).
3. (Opcional) En el caso de Siemens, seleccionar la opción deseada en el menú.
4. Seguir las instrucciones en pantalla.
5. Enviar el archivo de texto generado (`composite.txt` o `targetDSLS.txt`) a Soporte.

## Soporte Técnico

Para cualquier problema o duda con la ejecución de estas herramientas, póngase en contacto con:
- **Correo**: Soporte@ats-global.com
- **Teléfono**: 945 298 229

**Desarrollado por ATS GLOBAL SPAIN.**