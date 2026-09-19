[CmdletBinding()]
param([Parameter(Mandatory = $true)][string]$ArtifactDirectory)

$ErrorActionPreference = "Stop"
$repoDirectory = Split-Path -Parent $PSScriptRoot
$version = (Get-Content -LiteralPath (Join-Path $repoDirectory "metadata\VERSION") -Raw).Trim()
$artifacts = (Resolve-Path -LiteralPath $ArtifactDirectory).Path
$installer = Join-Path $artifacts "ParsiNegar-Desktop-$Version-Setup.exe"
$checksums = Join-Path $artifacts "SHA256SUMS"
if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) {
    throw "Windows installer is missing"
}

foreach ($line in Get-Content -LiteralPath $checksums) {
    if ($line -notmatch '^([0-9a-f]{64}) \*(.+)$') {
        throw "Invalid SHA256SUMS entry: $line"
    }
    $path = Join-Path $artifacts $Matches[2]
    $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actual -ne $Matches[1]) {
        throw "Checksum mismatch for $($Matches[2])"
    }
}

$testRoot = Join-Path $env:RUNNER_TEMP "parsinegar-windows-smoke"
$installDirectory = Join-Path $testRoot "application"
$env:APPDATA = Join-Path $testRoot "appdata"
$env:LOCALAPPDATA = Join-Path $testRoot "localappdata"
$installLog = Join-Path $env:RUNNER_TEMP "parsinegar-install.log"
$optOutLog = Join-Path $env:RUNNER_TEMP "parsinegar-install-optout.log"
$desktopLocations = @(
    [Environment]::GetFolderPath("Desktop"),
    [Environment]::GetFolderPath("CommonDesktopDirectory")
) | Select-Object -Unique

function Invoke-CheckedProcess([string]$FilePath, [string[]]$Arguments, [int]$TimeoutSeconds = 600) {
    $process = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru
    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        $process.Kill($true)
        throw "$FilePath did not finish within $TimeoutSeconds seconds"
    }
    if ($process.ExitCode -ne 0) {
        throw "$FilePath failed with exit code $($process.ExitCode)"
    }
}

function Test-InstalledApplication {
    $application = Join-Path $installDirectory "bin\ParsiNegar.exe"
    if (-not (Test-Path -LiteralPath $application -PathType Leaf)) {
        throw "Installed application executable is missing"
    }
    $metadata = (Get-Item -LiteralPath $application).VersionInfo
    if ($metadata.ProductVersion -ne $version) {
        throw "Installed application version does not match $version"
    }
    $originalPath = $env:PATH
    try {
        $env:PATH = "$env:SystemRoot\System32;$env:SystemRoot"
        Write-Host "Launching installed application with only Windows system paths"
        Invoke-CheckedProcess $application @("--smoke-test") 30
    } finally {
        $env:PATH = $originalPath
    }
}

function Find-DesktopShortcut {
    foreach ($desktop in $desktopLocations) {
        $shortcut = Join-Path $desktop "ParsiNegar Desktop.lnk"
        if (Test-Path -LiteralPath $shortcut -PathType Leaf) {
            return $shortcut
        }
    }
    return $null
}

function Assert-SystemFontsInstalled([string[]]$FontRecords) {
    $fontsDirectory = Join-Path $env:SystemRoot "Fonts"
    $fontsRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    foreach ($record in $FontRecords) {
        $parts = $record -split "`t", 2
        if ($parts.Count -ne 2) {
            throw "Invalid installed-font manifest entry: $record"
        }
        if (-not (Test-Path -LiteralPath (Join-Path $fontsDirectory $parts[0]) -PathType Leaf)) {
            throw "System-wide font file is missing: $($parts[0])"
        }
        if ((Get-ItemPropertyValue -Path $fontsRegistry -Name $parts[1]) -ne $parts[0]) {
            throw "System-wide font registration is missing: $($parts[0])"
        }
    }
}

function Uninstall-Application([string[]]$FontRecords = @()) {
    $uninstaller = Join-Path $installDirectory "unins000.exe"
    if (-not (Test-Path -LiteralPath $uninstaller -PathType Leaf)) {
        throw "Windows uninstaller is missing"
    }
    Write-Host "Uninstalling application"
    Invoke-CheckedProcess $uninstaller @("/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART") 600
    if (Test-Path -LiteralPath (Join-Path $installDirectory "bin\ParsiNegar.exe")) {
        throw "Application executable remains after uninstall"
    }
    $fontsDirectory = Join-Path $env:SystemRoot "Fonts"
    $fontsRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    foreach ($record in $FontRecords) {
        $parts = $record -split "`t", 2
        if ((Test-Path -LiteralPath (Join-Path $fontsDirectory $parts[0])) -or
            ($null -ne (Get-ItemPropertyValue -Path $fontsRegistry -Name $parts[1] -ErrorAction SilentlyContinue))) {
            throw "System-wide font remains after uninstall: $($parts[0])"
        }
    }
}

try {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $testRoot | Out-Null

    Write-Host "Installing with default font and desktop-shortcut tasks"
    Invoke-CheckedProcess $installer @("/SP-", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/LOG=`"$installLog`"", "/DIR=`"$installDirectory`"") 600
    Test-InstalledApplication
    $fontManifest = Join-Path $installDirectory "installed-fonts.txt"
    if (-not (Test-Path -LiteralPath $fontManifest -PathType Leaf) -or (Get-Content -LiteralPath $fontManifest).Count -eq 0) {
        throw "Default installation did not install the bundled system fonts"
    }
    $fontRecords = @(Get-Content -LiteralPath $fontManifest)
    Assert-SystemFontsInstalled $fontRecords
    if (-not (Find-DesktopShortcut)) {
        throw "Default installation did not create a desktop shortcut"
    }
    Uninstall-Application $fontRecords
    if (Find-DesktopShortcut) {
        throw "Desktop shortcut remains after uninstall"
    }

    Write-Host "Installing with optional font and desktop-shortcut tasks disabled"
    Invoke-CheckedProcess $installer @("/SP-", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/TASKS=", "/LOG=`"$optOutLog`"", "/DIR=`"$installDirectory`"") 600
    Test-InstalledApplication
    if (Test-Path -LiteralPath (Join-Path $installDirectory "installed-fonts.txt")) {
        throw "Font manifest exists after opting out of system fonts"
    }
    if (Find-DesktopShortcut) {
        throw "Desktop shortcut exists after opting out"
    }
    Uninstall-Application
} finally {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
}

Write-Host "Windows installer default and opt-out smoke checks passed"
