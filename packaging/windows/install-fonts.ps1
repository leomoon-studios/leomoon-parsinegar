param(
    [Parameter(Mandatory = $true)][string]$SourceDirectory,
    [Parameter(Mandatory = $true)][string]$ManifestPath
)

$ErrorActionPreference = "Stop"
$fontNamespace = (New-Object -ComObject Shell.Application).Namespace(0x14)
$installed = New-Object System.Collections.Generic.List[string]

Get-ChildItem -LiteralPath $SourceDirectory -File | Where-Object { $_.Extension -in ".ttf", ".otf", ".ttc" } | ForEach-Object {
    if ($null -eq $fontNamespace.ParseName($_.Name)) {
        $fontNamespace.CopyHere($_.FullName, 0x14)
        $installed.Add($_.Name)
    }
}

$installed | Set-Content -LiteralPath $ManifestPath -Encoding UTF8
