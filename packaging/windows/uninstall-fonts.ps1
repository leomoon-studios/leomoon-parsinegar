param([Parameter(Mandatory = $true)][string]$ManifestPath)

$ErrorActionPreference = "SilentlyContinue"
if (-not (Test-Path -LiteralPath $ManifestPath)) { exit 0 }

$fontNamespace = (New-Object -ComObject Shell.Application).Namespace(0x14)
Get-Content -LiteralPath $ManifestPath | ForEach-Object {
    $item = $fontNamespace.ParseName($_)
    if ($null -ne $item) { $item.InvokeVerb("delete") }
}
