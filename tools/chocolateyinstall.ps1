$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Antigravity CLI is a single portable native exe, downloaded directly from
# Google's official public storage bucket (storage.googleapis.com/antigravity-public).
# The SHA512 checksums below are computed from those exact official binaries.
# See tools\VERIFICATION.txt for how to reproduce them.

$packageArgs = @{
    packageName  = 'antigravity-cli'
    fileFullPath = Join-Path $toolsDir 'agy.exe'
    checksumType = 'sha512'
}

switch ($env:PROCESSOR_ARCHITECTURE) {
    'ARM64' {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.3-4577820882632704/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '908E57BC5505397C0AE019F52D071ADD06A2131E8EEBA7C3609571ED627A6E0E1F57ECB979AE7FAE5A053FF8EFBF3142CC415A4FD13B7D8B2DF121CE092116E6'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.3-4577820882632704/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'A9AFA6F290B1FE91E75C363090D3C42995D086B63C65683030B2F81B073EA7D16C46156FA52746EA2109606465D9993C0FF02713646D75CB33B44A6780CB0CDE'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
