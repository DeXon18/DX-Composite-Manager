# ==============================================================================
# ATS DX Composite ID Generator
# ==============================================================================
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:ProductName = 'ATS DX Composite ID Generator'
$script:OutputFile = Join-Path (Split-Path $PSScriptRoot) 'composite.txt'
$script:GetCidPath = Join-Path $PSScriptRoot 'getcid.exe'

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

$script:CidTasks = @{
    All       = @{ Title = 'Todos los IDs recomendados'; Argument = '-allcomposite' }
    Cloud     = @{ Title = 'Entorno Cloud automatico'; Argument = '-cloud' }
    Azure     = @{ Title = 'Microsoft Azure'; Argument = '-azure' }
    NoCloud   = @{ Title = 'Entorno virtual/local no Cloud'; Argument = '-nocloud' }
    SolidEdge = @{ Title = 'Generar Solid Edge (composite2)'; Argument = '-composite2' }
}

$script:MenuActions = @{
    '1' = @('NoCloud')
    '2' = @('SolidEdge')
    '3' = @('Cloud')
    '4' = @('Azure')
    '5' = @('All', 'Cloud', 'Azure', 'NoCloud')
}

function Show-AtsDxHeader {
    Clear-Host
    Write-Host ''
    Write-Host ' █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█' -ForegroundColor $script:Colors.Frame
    Write-Host ' █  ' -NoNewline -ForegroundColor $script:Colors.Frame
    Write-Host 'ATS DX ' -NoNewline -ForegroundColor $script:Colors.Text
    Write-Host ':: ' -NoNewline -ForegroundColor $script:Colors.Frame
    Write-Host $script:ProductName -NoNewline -ForegroundColor $script:Colors.Frame

    $pad = [Math]::Max(0, 61 - $script:ProductName.Length)
    Write-Host (' ' * $pad) -NoNewline
    Write-Host '  █' -ForegroundColor $script:Colors.Frame

    Write-Host ' █  ' -NoNewline -ForegroundColor $script:Colors.Frame
    Write-Host 'SIEMENS ' -NoNewline -ForegroundColor Cyan
    Write-Host ':: Ecosistema de Digital Industries Software y Gestión PLM' -NoNewline -ForegroundColor $script:Colors.Text

    $siemensText = 'SIEMENS :: Ecosistema de Digital Industries Software y Gestión PLM'
    $pad2 = [Math]::Max(0, 71 - $siemensText.Length)
    Write-Host (' ' * $pad2) -NoNewline
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

$script:EnvCache = $null

function Get-AtsDxEnvironment {
    if ($null -ne $script:EnvCache) { return $script:EnvCache }

    try {
        $cs = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
        $bios = Get-CimInstance -ClassName Win32_BIOS -ErrorAction Stop

        $manufacturer = [string]$cs.Manufacturer
        $model = [string]$cs.Model
        $serial = [string]$bios.SerialNumber

        $script:EnvCache = switch ($true) {
            ($manufacturer -match 'VMware' -or $model -match 'VMware') { 'VMware'; break }
            ($manufacturer -match 'Amazon' -or $model -match 'EC2' -or $serial -match '^ec2') { 'AWS'; break }
            ($manufacturer -match 'Microsoft' -and $model -match 'Virtual Machine') { 'Hyper-V / Azure'; break }
            ($manufacturer -match 'QEMU' -or $model -match 'KVM') { 'KVM / QEMU'; break }
            ($manufacturer -match 'Xen' -or $serial -match '^ec2') { 'Xen'; break }
            ($manufacturer -match 'innotek|VirtualBox' -or $model -match 'VirtualBox') { 'VirtualBox'; break }
            default { 'Fisico o no identificado' }
        }
    } catch {
        $script:EnvCache = 'No identificado'
    }

    return $script:EnvCache
}

function Initialize-OutputFile {
    try {
        if (Test-Path -LiteralPath $script:OutputFile) {
            Remove-Item -LiteralPath $script:OutputFile -Force
        }

        Add-Lines @(
            'ATS DX Composite ID Generator'
            "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
            "Equipo: $env:COMPUTERNAME"
            "Usuario: $env:USERDOMAIN\$env:USERNAME"
            "Ruta: $PSScriptRoot"
            "Entorno detectado: $(Get-AtsDxEnvironment)"
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
    param(
        [Parameter(Mandatory)][string]$Title,
        [Parameter(Mandatory)][string]$Argument
    )

    Write-Section $Title

    Add-Lines @(
        ''
        '============================================================================='
        $Title
        "Comando: getcid.exe $Argument"
        '============================================================================='
    )

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo.FileName = $script:GetCidPath
    $proc.StartInfo.Arguments = "$Argument -nopause"
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
        Write-Err "No se ha podido ejecutar getcid.exe $Argument"
        Add-Lines "[ERROR] $($_.Exception.Message)"
        return $false
    }
}

function Show-Help {
    Show-AtsDxHeader
    Write-Host ''
    Write-Host '   --- AYUDA DE OPCIONES ---' -ForegroundColor $script:Colors.Info
    Write-Host '   1. Licencia Estandar: Para maquinas fisicas o virtuales locales (VMware/VirtualBox).' -ForegroundColor $script:Colors.Text
    Write-Host '   2. Solid Edge: Usa identificador composite2 (para licencias Node locked).' -ForegroundColor $script:Colors.Text
    Write-Host '   3. Entorno Cloud: Para maquinas AWS o Google Cloud.' -ForegroundColor $script:Colors.Text
    Write-Host '   4. Azure: Exclusivo para maquinas virtuales en Microsoft Azure.' -ForegroundColor $script:Colors.Text
    Write-Host '   5. Todos: Ejecuta todos los chequeos. Ideal si soporte te lo pide.' -ForegroundColor $script:Colors.Text
    Write-Host ''
    Read-Host '   Pulse Enter para volver al menu'
}

function Show-Menu {
    Show-AtsDxHeader
    Write-Host '   Entorno detectado: ' -NoNewline -ForegroundColor $script:Colors.Text
    Write-Host (Get-AtsDxEnvironment) -ForegroundColor $script:Colors.Version
    Write-Host ''
    Write-Host '   Seleccione una opcion:' -ForegroundColor $script:Colors.Text
    Write-Host ''
    Write-Host '   1. Licencia Estandar (Maquina fisica o virtual local)' -ForegroundColor $script:Colors.Text
    Write-Host '   2. Licencia Solid Edge (Node locked)' -ForegroundColor $script:Colors.Text
    Write-Host '   3. Licencia Cloud Automatico (AWS / Google Cloud)' -ForegroundColor $script:Colors.Text
    Write-Host '   4. Licencia Cloud Especifico (Microsoft Azure)' -ForegroundColor $script:Colors.Text
    Write-Host '   5. Generar TODOS los identificadores (Solo si soporte lo pide)' -ForegroundColor $script:Colors.Text
    Write-Host '   6. Ayuda: ¿Cual elijo?' -ForegroundColor $script:Colors.Text
    Write-Host '   7. Salir' -ForegroundColor $script:Colors.Text
    Write-Host ''
}

function Complete-Process {
    param(
        [int]$SucceededCount,
        [int]$TotalCount
    )

    Write-Host ''

    if ($SucceededCount -eq $TotalCount) {
        Write-Ok "Proceso finalizado ($SucceededCount de $TotalCount tareas correctas)."
    } else {
        Write-Warn "Proceso finalizado con avisos ($SucceededCount de $TotalCount tareas correctas). Revise el fichero generado."
    }

    Write-Host ''
    Write-Host '   Fichero generado:' -ForegroundColor $script:Colors.Text
    Write-Host "   $script:OutputFile" -ForegroundColor $script:Colors.Version
    Write-Host ''
    Write-Host '   Por favor envie el fichero composite.txt a quien se lo haya solicitado.' -ForegroundColor $script:Colors.Text
    Write-Host '   En caso de duda, enviarlo a Soporte@ats-global.com' -ForegroundColor $script:Colors.Text
    Write-Host ''
}

# ==============================================================================
# Programa principal
# ==============================================================================

if (-not (Test-Path -LiteralPath $script:GetCidPath)) {
    Show-AtsDxHeader
    Write-Err 'No se ha detectado getcid.exe.'
    Write-Host ''
    Write-Host '   Instrucciones:' -ForegroundColor $script:Colors.Text
    Write-Host '   1. Extraiga todo el contenido del ZIP en una misma carpeta.' -ForegroundColor $script:Colors.Text
    Write-Host '   2. Verifique que getcid.exe esta dentro de la carpeta Windows.' -ForegroundColor $script:Colors.Text
    Write-Host '   3. Ejecute de nuevo ATS_Generar_Composite_Windows.bat.' -ForegroundColor $script:Colors.Text
    Write-Host ''
    exit 1
}

$option = $null

while ($true) {
    Show-Menu
    $option = (Read-Host '   Introduzca una opcion').Trim()

    if ($option -eq '7') {
        Write-Host ''
        Write-Warn 'Proceso cancelado por el usuario.'
        Write-Host ''
        exit 0
    }

    if ($option -eq '6') {
        Show-Help
        continue
    }

    if ($script:MenuActions.ContainsKey($option)) {
        break
    }

    Write-Host ''
    Write-Err 'Opcion no valida. Intentelo de nuevo.'
    Write-Host ''
}

Show-AtsDxHeader

if (-not (Initialize-OutputFile)) {
    exit 1
}

$taskKeys = $script:MenuActions[$option]
$succeeded = 0

foreach ($key in $taskKeys) {
    $task = $script:CidTasks[$key]

    if (Invoke-GetCid -Title $task.Title -Argument $task.Argument) {
        $succeeded++
    }
}

Complete-Process -SucceededCount $succeeded -TotalCount $taskKeys.Count

if ($succeeded -eq $taskKeys.Count) {
    exit 0
} else {
    exit 2
}
