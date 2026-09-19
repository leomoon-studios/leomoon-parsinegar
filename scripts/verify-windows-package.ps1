[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$StageDirectory,
    [Parameter(Mandatory = $true)][string]$InstallerPath,
    [Parameter(Mandatory = $true)][string]$Version
)

$ErrorActionPreference = "Stop"
$stage = (Resolve-Path -LiteralPath $StageDirectory).Path
$installer = (Resolve-Path -LiteralPath $InstallerPath).Path
$binaryDirectory = Join-Path $stage "bin"
$application = Join-Path $binaryDirectory "ParsiNegar.exe"

function Require-File([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Required Windows package file is missing: $Path"
    }
    if ((Get-Item -LiteralPath $Path).Length -eq 0) {
        throw "Required Windows package file is empty: $Path"
    }
}

$requiredFiles = @(
    $application,
    (Join-Path $binaryDirectory "Qt6Core.dll"),
    (Join-Path $binaryDirectory "Qt6Gui.dll"),
    (Join-Path $binaryDirectory "Qt6Qml.dll"),
    (Join-Path $binaryDirectory "Qt6Quick.dll"),
    (Join-Path $binaryDirectory "Qt6QuickControls2.dll"),
    (Join-Path $binaryDirectory "platforms\qwindows.dll"),
    (Join-Path $stage "share\doc\parsinegar-desktop\LICENSE"),
    (Join-Path $stage "share\doc\parsinegar-desktop\THIRD_PARTY_NOTICES.md"),
    (Join-Path $stage "share\doc\parsinegar-desktop\SOURCES.md"),
    (Join-Path $stage "share\doc\parsinegar-desktop\Qt-LGPL-NOTICE.md"),
    (Join-Path $stage "share\doc\parsinegar-desktop\Qt-LGPL-3.0-only.txt"),
    $installer
)
foreach ($path in $requiredFiles) {
    Require-File $path
}

if ((Split-Path -Leaf $installer) -ne "ParsiNegar-Desktop-$Version-Setup.exe") {
    throw "Windows installer filename does not match version $Version"
}

$versionInfo = (Get-Item -LiteralPath $application).VersionInfo
if ($versionInfo.ProductVersion -ne $Version -or $versionInfo.FileVersion -ne $Version) {
    throw "Windows executable metadata does not match version $Version"
}

$unexpectedRuntimes = Get-ChildItem -LiteralPath $binaryDirectory -File | Where-Object {
    $_.Name -match '^(python|python3|node|npm|omarchy|quickshell)(\.exe|\.cmd|\.bat)?$'
}
if ($unexpectedRuntimes) {
    throw "Windows package contains an unexpected external runtime: $($unexpectedRuntimes.Name -join ', ')"
}

$smoke = Start-Process -FilePath $application -ArgumentList "--smoke-test" -Wait -PassThru
if ($smoke.ExitCode -ne 0) {
    throw "Staged Windows application smoke test failed with exit code $($smoke.ExitCode)"
}

Write-Host "Verified self-contained Windows stage and installer $installer"
