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
$uninstallLog = Join-Path $env:RUNNER_TEMP "parsinegar-uninstall.log"
$desktopLocations = @(
    [Environment]::GetFolderPath("Desktop"),
    [Environment]::GetFolderPath("CommonDesktopDirectory")
) | Select-Object -Unique
$bundledFontFiles = @(
    Get-ChildItem -LiteralPath (Join-Path $repoDirectory "assets\fonts\system") -File |
        Where-Object { $_.Extension -in ".ttf", ".otf", ".ttc" }
)
$fontsDirectory = Join-Path $env:SystemRoot "Fonts"
$fontsRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

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

function Wait-PathAbsent([string]$Path, [int]$TimeoutSeconds = 60) {
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    while (Test-Path -LiteralPath $Path) {
        if ([DateTime]::UtcNow -ge $deadline) {
            throw "Path remains after $TimeoutSeconds seconds: $Path"
        }
        Start-Sleep -Milliseconds 200
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

function Get-RegisteredFontFiles {
    return @(
        (Get-ItemProperty -Path $fontsRegistry).PSObject.Properties |
            Where-Object { $_.Name -notlike "PS*" -and $_.Value -is [string] } |
            ForEach-Object { [string]$_.Value }
    )
}

function Assert-SystemFontsInstalled {
    $registeredFontFiles = @(Get-RegisteredFontFiles)
    foreach ($font in $bundledFontFiles) {
        if (-not (Test-Path -LiteralPath (Join-Path $fontsDirectory $font.Name) -PathType Leaf)) {
            throw "System-wide font file is missing: $($font.Name)"
        }
        if ($font.Name -notin $registeredFontFiles) {
            throw "System-wide font registration is missing: $($font.Name)"
        }
    }
}

function Assert-SystemFontsAbsent {
    $registeredFontFiles = @(Get-RegisteredFontFiles)
    foreach ($font in $bundledFontFiles) {
        if ((Test-Path -LiteralPath (Join-Path $fontsDirectory $font.Name)) -or
            ($font.Name -in $registeredFontFiles)) {
            throw "System-wide font remains after uninstall or opt-out: $($font.Name)"
        }
    }
}

function Uninstall-Application {
    $uninstaller = Join-Path $installDirectory "unins000.exe"
    if (-not (Test-Path -LiteralPath $uninstaller -PathType Leaf)) {
        throw "Windows uninstaller is missing"
    }
    Write-Host "Uninstalling application"
    Invoke-CheckedProcess $uninstaller @("/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/LOG=`"$uninstallLog`"") 600
    Wait-PathAbsent $installDirectory
}

try {
    if (Test-Path -LiteralPath $testRoot) {
        Remove-Item -LiteralPath $testRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $testRoot | Out-Null

    Write-Host "Installing with default font and desktop-shortcut tasks"
    Invoke-CheckedProcess $installer @("/SP-", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/LOG=`"$installLog`"", "/DIR=`"$installDirectory`"") 600
    Test-InstalledApplication
    Assert-SystemFontsInstalled
    if (-not (Find-DesktopShortcut)) {
        throw "Default installation did not create a desktop shortcut"
    }
    Uninstall-Application
    Assert-SystemFontsAbsent
    if (Find-DesktopShortcut) {
        throw "Desktop shortcut remains after uninstall"
    }

    Write-Host "Installing with optional font and desktop-shortcut tasks disabled"
    Invoke-CheckedProcess $installer @("/SP-", "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/TASKS=", "/LOG=`"$optOutLog`"", "/DIR=`"$installDirectory`"") 600
    Test-InstalledApplication
    Assert-SystemFontsAbsent
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
