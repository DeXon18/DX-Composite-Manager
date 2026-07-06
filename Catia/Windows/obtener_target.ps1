# ==============================================================================
# ATS DX Catia DSLS Target ID Generator
# ==============================================================================
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:ProductName = 'CATIA :: DSLS Target ID Generator'
$script:OutputFile = Join-Path (Split-Path $PSScriptRoot) 'targetDSLS.txt'
$script:GetCidPath = Join-Path $PSScriptRoot 'DSLicTarget.exe'

$script:Colors = @{
    Frame   = 'DarkYellow'
    Brand   = 'DarkGray'
    Text    = 'White'
    Header  = 'Gray'
    Info    = 'DarkCyan'
    Version = 'Cyan'
    Success = 'Green'
    Warning = 'Yellow'
    Error   = 'Red'
}

function Show-AtsDxHeader {
    Clear-Host
    Write-Host ''
    Write-Host ' █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█' -ForegroundColor $script:Colors.Frame
    Write-Host ' █  ' -NoNewline -ForegroundColor $script:Colors.Frame
    Write-Host 'CATIA ' -NoNewline -ForegroundColor $script:Colors.Text
    Write-Host ':: ' -NoNewline -ForegroundColor $script:Colors.Frame
    Write-Host 'DSLS Target ID Generator' -NoNewline -ForegroundColor $script:Colors.Frame

    # Length of "CATIA :: DSLS Target ID Generator" is 33
    $pad = [Math]::Max(0, 61 - 33)
    Write-Host (' ' * $pad) -NoNewline
    Write-Host '  █' -ForegroundColor $script:Colors.Frame

    Write-Host ' █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█' -ForegroundColor $script:Colors.Frame
    Write-Host ''
    Write-Host '   ATS GLOBAL SPAIN' -ForegroundColor $script:Colors.Header
    Write-Host '   Developer: Oskar Blazquez (Oskar.Blazquez@ats-global.com)' -ForegroundColor $script:Colors.Frame
    Write-Host '   Soporte: Soporte@ats-global.com o 945298229' -ForegroundColor $script:Colors.Frame
    Write-Host '   --------------------------------------------------------------------------' -ForegroundColor $script:Colors.Brand
    Write-Host ''
}

function Write-Section {
    param([Parameter(Mandatory)][string]$Text)

    Write-Host ''
    Write-Host "   $Text" -ForegroundColor $script:Colors.Info
    Write-Host '   --------------------------------------------------------------------------' -ForegroundColor $script:Colors.Brand
}

function Write-Ok { param([string]$Text) Write-Host "   [OK] $Text" -ForegroundColor $script:Colors.Success }
function Write-Warn { param([string]$Text) Write-Host "   [AVISO] $Text" -ForegroundColor $script:Colors.Warning }
function Write-Err { param([string]$Text) Write-Host "   [ERROR] $Text" -ForegroundColor $script:Colors.Error }

function Add-Lines {
    param([string[]]$Lines = @(''))
    Add-Content -Path $script:OutputFile -Value $Lines -Encoding UTF8
}

function Get-AtsDxEnvironment {
    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop
        $manufacturer = [string]$cs.Manufacturer
        $model = [string]$cs.Model
        $serial = [string]$bios.SerialNumber

        switch ($true) {
            ($manufacturer -match 'VMware' -or $model -match 'VMware') { return 'VMware' }
            ($manufacturer -match 'Amazon' -or $model -match 'EC2' -or $serial -match '^ec2') { return 'AWS' }
            ($manufacturer -match 'Microsoft' -and $model -match 'Virtual Machine') { return 'Hyper-V / Azure' }
            ($manufacturer -match 'QEMU' -or $model -match 'KVM') { return 'KVM / QEMU' }
            ($manufacturer -match 'Xen' -or $serial -match '^ec2') { return 'Xen' }
            ($manufacturer -match 'innotek|VirtualBox' -or $model -match 'VirtualBox') { return 'VirtualBox' }
            default { return 'Fisico o no identificado' }
        }
    } catch {
        return 'No identificado'
    }
}

function Initialize-OutputFile {
    try {
        if (Test-Path -LiteralPath $script:OutputFile) {
            Remove-Item -LiteralPath $script:OutputFile -Force
        }

        Add-Lines @(
            'CATIA :: DSLS Target ID Generator'
            "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            "Equipo: $env:COMPUTERNAME"
            "Usuario: $env:USERDOMAIN\$env:USERNAME"
            "Ruta: $PSScriptRoot"
            ''
        )

        return $true
    } catch {
        Write-Err "No se puede escribir en $script:OutputFile"
        Write-Err $_.Exception.Message
        Write-Host ''
        Write-Host '   Compruebe permisos de escritura en la carpeta o ejecute como administrador.' -ForegroundColor $script:Colors.Text
        return $false
    }
}

function Invoke-GetCid {
    Write-Section 'Generando dato de maquina...'

    Add-Lines @(
        ''
        '============================================================================='
        'Generando dato de maquina'
        "Comando: DSLicTarget.exe -t"
        '============================================================================='
    )

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo.FileName = $script:GetCidPath
    $proc.StartInfo.Arguments = "-t"
    $proc.StartInfo.UseShellExecute = $false
    $proc.StartInfo.RedirectStandardOutput = $true
    $proc.StartInfo.RedirectStandardError = $true
    $proc.StartInfo.CreateNoWindow = $true

    try {
        $proc.Start() | Out-Null

        $spinner = @('|', '/', '-', '\')
        $i = 0

        while (-not $proc.HasExited) {
            Write-Host "`r   [$($spinner[$i])] Ejecutando... espere" -NoNewline -ForegroundColor $script:Colors.Info
            $i = ($i + 1) % 4
            Start-Sleep -Milliseconds 100
        }

        $output = $proc.StandardOutput.ReadToEnd()
        $errOutput = $proc.StandardError.ReadToEnd()
        $exitCode = $proc.ExitCode
        $proc.Dispose()

        Write-Host "`r                                              `r" -NoNewline

        $lines = @($output -split "`r?`n" | Where-Object { $_.Trim() -ne '' })

        if ($errOutput) {
            $lines += @($errOutput -split "`r?`n" | Where-Object { $_.Trim() -ne '' })
        }

        if ($exitCode -ne 0) {
            Write-Warn "El comando ha finalizado con codigo $exitCode"
            Add-Lines "[AVISO] Codigo de salida: $exitCode"
        }

        if ($lines.Count -eq 0) {
            Write-Warn 'No se ha obtenido salida.'
            Add-Lines '[AVISO] Sin salida.'
            return $false
        }

        Add-Lines $lines

        if ($exitCode -eq 0) {
            Write-Ok 'Datos generados correctamente.'
            return $true
        }

        return $false
    } catch {
        Write-Host "`r                                              `r" -NoNewline
        Write-Err "No se ha podido ejecutar DSLicTarget.exe"
        Add-Lines "[ERROR] $($_.Exception.Message)"
        return $false
    }
}

function Complete-Process {
    param([bool]$Succeeded)
    Write-Host ''

    if ($Succeeded) {
        Write-Ok "Proceso finalizado."
    } else {
        Write-Warn "Proceso finalizado con avisos. Revise el fichero generado."
    }

    Write-Host ''
    Write-Host '   Fichero generado:' -ForegroundColor $script:Colors.Text
    Write-Host "   $script:OutputFile" -ForegroundColor $script:Colors.Version
    Write-Host ''
    Write-Host '   Por favor envie el fichero targetDSLS.txt a quien se lo haya solicitado.' -ForegroundColor $script:Colors.Text
    Write-Host '   En caso de duda, enviarlo a Soporte@ats-global.com' -ForegroundColor $script:Colors.Text
    Write-Host ''
}

# ==============================================================================
# Programa principal
# ==============================================================================

Show-AtsDxHeader

if (-not (Test-Path -LiteralPath $script:GetCidPath)) {
    Write-Err 'No se ha detectado DSLicTarget.exe.'
    Write-Host ''
    Write-Host '   Instrucciones:' -ForegroundColor $script:Colors.Text
    Write-Host '   1. Extraer el contenido de IT_Generador_DSLicTarget_Catia.zip en una misma carpeta.' -ForegroundColor $script:Colors.Text
    Write-Host '   2. Ejecutar el archivo obtener_target.ps1' -ForegroundColor $script:Colors.Text
    Write-Host '   3. Presionar intro para continuar hasta que desaparezca la pantalla negra de CMD.' -ForegroundColor $script:Colors.Text
    Write-Host '   4. Enviarnos el fichero generado llamado targetDSLS.txt.' -ForegroundColor $script:Colors.Text
    Write-Host ''
    Write-Host '   Pulse una tecla para continuar...' -ForegroundColor $script:Colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

if (-not (Initialize-OutputFile)) {
    Write-Host '   Pulse una tecla para continuar...' -ForegroundColor $script:Colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warn 'No se esta ejecutando como Administrador. Podrian ocurrir errores de registro.'
}

$envDetectado = Get-AtsDxEnvironment
if ($envDetectado -ne 'Fisico o no identificado' -and $envDetectado -ne 'No identificado') {
    Write-Err "Entorno virtual detectado ($envDetectado). Catia requiere maquina fisica."
    Write-Host ''
    Write-Host '   El proceso no puede continuar en este entorno.' -ForegroundColor $script:Colors.Text
    Write-Host '   Pulse una tecla para salir...' -ForegroundColor $script:Colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
Write-Host ''

$succeeded = Invoke-GetCid

Complete-Process -Succeeded $succeeded

if ($succeeded) {
    exit 0
} else {
    exit 2
}
