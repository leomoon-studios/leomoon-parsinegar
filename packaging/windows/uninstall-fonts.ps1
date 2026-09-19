param([Parameter(Mandatory = $true)][string]$ManifestPath)

$ErrorActionPreference = "SilentlyContinue"
if (-not (Test-Path -LiteralPath $ManifestPath)) { exit 0 }

$fontsDirectory = Join-Path $env:SystemRoot "Fonts"
$fontsRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class ParsiNegarFontApi {
    [DllImport("gdi32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool RemoveFontResourceEx(string path, uint flags, IntPtr reserved);
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(IntPtr window, uint message, IntPtr wParam, IntPtr lParam, uint flags, uint timeout, out IntPtr result);
}
"@

Get-Content -LiteralPath $ManifestPath | ForEach-Object {
    $parts = $_ -split "`t", 2
    if ($parts.Count -ne 2) { return }
    $fontPath = Join-Path $fontsDirectory $parts[0]
    [void][ParsiNegarFontApi]::RemoveFontResourceEx($fontPath, 0, [IntPtr]::Zero)
    Remove-ItemProperty -Path $fontsRegistry -Name $parts[1] -Force
    Remove-Item -LiteralPath $fontPath -Force
}

$result = [IntPtr]::Zero
[void][ParsiNegarFontApi]::SendMessageTimeout(
    [IntPtr]0xffff, 0x001D, [IntPtr]::Zero, [IntPtr]::Zero, 0x0002, 5000, [ref]$result)
