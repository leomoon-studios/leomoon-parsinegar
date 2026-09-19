param(
    [Parameter(Mandatory = $true)][string]$SourceDirectory,
    [Parameter(Mandatory = $true)][string]$ManifestPath
)

$ErrorActionPreference = "Stop"
$fontsDirectory = Join-Path $env:SystemRoot "Fonts"
$fontsRegistry = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
$installed = New-Object System.Collections.Generic.List[string]

function Send-FontChange {
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
}

try {
    Get-ChildItem -LiteralPath $SourceDirectory -File |
        Where-Object { $_.Extension -in ".ttf", ".otf", ".ttc" } |
        ForEach-Object {
            $destination = Join-Path $fontsDirectory $_.Name
            if (Test-Path -LiteralPath $destination) {
                return
            }

            $registryName = "ParsiNegar Desktop - $($_.Name)"
            Copy-Item -LiteralPath $_.FullName -Destination $destination
            New-ItemProperty -Path $fontsRegistry -Name $registryName -Value $_.Name -PropertyType String -Force | Out-Null
            $installed.Add("$($_.Name)`t$registryName")
        }

    $installed | Set-Content -LiteralPath $ManifestPath -Encoding UTF8
    Send-FontChange
} catch {
    foreach ($entry in $installed) {
        $parts = $entry -split "`t", 2
        Remove-ItemProperty -Path $fontsRegistry -Name $parts[1] -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath (Join-Path $fontsDirectory $parts[0]) -Force -ErrorAction SilentlyContinue
    }
    Remove-Item -LiteralPath $ManifestPath -Force -ErrorAction SilentlyContinue
    throw
}
