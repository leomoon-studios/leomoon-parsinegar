[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$BuildDirectory,
    [Parameter(Mandatory = $true)][string]$DistDirectory,
    [string]$IsccPath = "",
    [string]$Commit = "unknown"
)

$ErrorActionPreference = "Stop"
$repoDirectory = Split-Path -Parent $PSScriptRoot
$version = (Get-Content -LiteralPath (Join-Path $repoDirectory "metadata\VERSION") -Raw).Trim()
$releaseDate = (Get-Content -LiteralPath (Join-Path $repoDirectory "metadata\RELEASE_DATE") -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') {
    throw "VERSION must contain a semantic version such as 1.2.3"
}
if ($releaseDate -notmatch '^\d{4}-\d{2}-\d{2}$') {
    throw "RELEASE_DATE must use YYYY-MM-DD format"
}

$build = (Resolve-Path -LiteralPath $BuildDirectory).Path
$stage = Join-Path $build "package\windows\stage"
$installerScript = Join-Path $build "packaging\windows\ParsiNegar.iss"
if (-not $IsccPath) {
    $command = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($command) {
        $IsccPath = $command.Source
    } else {
        $IsccPath = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
    }
}
if (-not (Test-Path -LiteralPath $IsccPath -PathType Leaf)) {
    throw "Inno Setup compiler was not found at $IsccPath"
}

$sourceFontCount = @(
    Get-ChildItem -LiteralPath (Join-Path $repoDirectory "assets\fonts\system") -File |
        Where-Object { $_.Extension -in ".ttf", ".otf", ".ttc" }
).Count
$installerFontCount = @(Select-String -LiteralPath $installerScript -SimpleMatch "FontInstall:").Count
if ($installerFontCount -ne $sourceFontCount) {
    throw "Generated installer contains $installerFontCount native font entries, expected $sourceFontCount"
}
Write-Host "Verified $installerFontCount native Inno Setup font entries"

$certificatePath = $env:PARSINEGAR_WINDOWS_CERTIFICATE_PATH
$certificatePassword = $env:PARSINEGAR_WINDOWS_CERTIFICATE_PASSWORD
$timestampUrl = $env:PARSINEGAR_WINDOWS_TIMESTAMP_URL
if (-not $timestampUrl) {
    $timestampUrl = "http://timestamp.digicert.com"
}
$signed = -not [string]::IsNullOrWhiteSpace($certificatePath)

function Find-SignTool {
    $kitsRoot = Join-Path ${env:ProgramFiles(x86)} "Windows Kits\10\bin"
    $tools = Get-ChildItem -LiteralPath $kitsRoot -Filter signtool.exe -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\x64\\signtool\.exe$' } |
        Sort-Object FullName -Descending
    if (-not $tools) {
        throw "signtool.exe was not found in the Windows SDK"
    }
    return $tools[0].FullName
}

function Sign-Artifact([string]$Path, [string]$SignTool) {
    $arguments = @("sign", "/fd", "SHA256", "/td", "SHA256", "/tr", $timestampUrl, "/f", $certificatePath)
    if (-not [string]::IsNullOrEmpty($certificatePassword)) {
        $arguments += @("/p", $certificatePassword)
    }
    $arguments += $Path
    & $SignTool @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Authenticode signing failed for $Path"
    }
    $signature = Get-AuthenticodeSignature -LiteralPath $Path
    if ($signature.Status -ne "Valid") {
        throw "Authenticode signature validation failed for $Path with status $($signature.Status)"
    }
}

$signTool = $null
$application = Join-Path $stage "bin\leomoon-parsinegar.exe"
if ($signed) {
    if (-not (Test-Path -LiteralPath $certificatePath -PathType Leaf)) {
        throw "The configured Windows signing certificate does not exist"
    }
    $signTool = Find-SignTool
    Sign-Artifact $application $signTool
}

& $IsccPath "/Qp" $installerScript
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup failed with exit code $LASTEXITCODE"
}

$installer = Join-Path $build "package\windows\leomoon-parsinegar-$Version-Setup.exe"
if ($signed) {
    Sign-Artifact $installer $signTool
}

& (Join-Path $PSScriptRoot "verify-windows-package.ps1") -StageDirectory $stage -InstallerPath $installer -Version $version

$dist = [System.IO.Path]::GetFullPath($DistDirectory)
if ($dist -eq [System.IO.Path]::GetPathRoot($dist) -or $dist -eq $repoDirectory) {
    throw "Refusing to replace unsafe artifact directory: $dist"
}
if (Test-Path -LiteralPath $dist) {
    Remove-Item -LiteralPath $dist -Recurse -Force
}
New-Item -ItemType Directory -Path $dist | Out-Null
$distInstaller = Join-Path $dist (Split-Path -Leaf $installer)
Copy-Item -LiteralPath $installer -Destination $distInstaller

$manifest = [ordered]@{
    application = "LeoMoon ParsiNegar"
    version = $version
    releaseDate = $releaseDate
    commit = $Commit
    platform = "windows-x64"
    format = "Inno Setup"
    signed = $signed
}
$manifest | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $dist "release-manifest.json") -Encoding utf8NoBOM

$checksumFiles = Get-ChildItem -LiteralPath $dist -File | Sort-Object Name
$checksumLines = foreach ($file in $checksumFiles) {
    $hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash *$($file.Name)"
}
$checksumLines | Set-Content -LiteralPath (Join-Path $dist "SHA256SUMS") -Encoding ascii

Write-Host "Windows release artifacts are ready in $dist"
