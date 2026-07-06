# ==============================================================================
# GLOVIUS :: Host ID Generator (MAC)
# ==============================================================================
#Requires -Version 5.1

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$script:ProductName = 'GLOVIUS :: Host ID Generator'
$script:OutputFile = Join-Path (Split-Path $PSScriptRoot) 'Glovius Host ID.txt'

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
    Write-Host 'GLOVIUS ' -NoNewline -ForegroundColor $script:Colors.Text
    Write-Host ':: ' -NoNewline -ForegroundColor $script:Colors.Frame
    Write-Host 'Host ID Generator' -NoNewline -ForegroundColor $script:Colors.Frame

    $pad = [Math]::Max(0, 61 - 28)
    Write-Host (' ' * $pad) -NoNewline
    Write-Host '            █' -ForegroundColor $script:Colors.Frame

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

function Initialize-OutputFile {
    try {
        if (Test-Path -LiteralPath $script:OutputFile) {
            Remove-Item -LiteralPath $script:OutputFile -Force
        }

        Add-Lines @(
            'GLOVIUS :: Host ID Generator'
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

function Invoke-GetMac {
    Write-Section 'Obteniendo direccion MAC (Glovius Host ID)...'

    Add-Lines @(
        ''
        '============================================================================='
        'Host ID (MAC Address)'
        '============================================================================='
    )

    try {
        $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled -eq $true -and $_.MacAddress -ne $null }
        if (-not $adapters) {
            Write-Err "No se encontraron adaptadores de red activos."
            Add-Lines "[ERROR] No active network adapters found."
            return $false
        }

        $lines = @()
        foreach ($adapter in $adapters) {
            $macClean = $adapter.MacAddress.Replace(':', '').Replace('-', '')
            $lines += "Adaptador: $($adapter.Description)"
            $lines += "MAC (Glovius ID): $macClean"
            $lines += ''
        }

        Add-Lines $lines
        Write-Ok 'Datos extraidos correctamente.'
        return $true
    } catch {
        Write-Err "No se pudo obtener la direccion MAC."
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
    Write-Host '   Por favor envie el fichero "Glovius Host ID.txt" a quien se lo haya solicitado.' -ForegroundColor $script:Colors.Text
    Write-Host '   En caso de duda, enviarlo a Soporte@ats-global.com' -ForegroundColor $script:Colors.Text
    Write-Host ''

    Write-Host '   Pulse una tecla para continuar...' -ForegroundColor $script:Colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ==============================================================================
# Programa principal
# ==============================================================================

Show-AtsDxHeader

if (-not (Initialize-OutputFile)) {
    Write-Host '   Pulse una tecla para continuar...' -ForegroundColor $script:Colors.Info
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}

$succeeded = Invoke-GetMac

Complete-Process -Succeeded $succeeded

if ($succeeded) {
    exit 0
} else {
    exit 2
}
