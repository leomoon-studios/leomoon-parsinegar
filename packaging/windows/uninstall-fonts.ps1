param([Parameter(Mandatory = $true)][string]$ManifestPath)

$ErrorActionPreference = "SilentlyContinue"
if (-not (Test-Path -LiteralPath $ManifestPath)) { exit 0 }

$fontsDirectory = Join-Path $env:SystemRoot "Fonts"
$fontsRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

Get-Content -LiteralPath $ManifestPath | ForEach-Object {
    $parts = $_ -split "`t", 2
    if ($parts.Count -ne 2) { return }
    Remove-ItemProperty -Path $fontsRegistry -Name $parts[1] -Force
    Remove-Item -LiteralPath (Join-Path $fontsDirectory $parts[0]) -Force
}

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class ParsiNegarFontBroadcast {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(IntPtr window, uint message, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
}
"@
$result = [IntPtr]::Zero
[void][ParsiNegarFontBroadcast]::SendMessageTimeout(
    [IntPtr]0xffff, 0x001D, [IntPtr]::Zero, [IntPtr]::Zero, 0x0002, 5000, [ref]$result)
