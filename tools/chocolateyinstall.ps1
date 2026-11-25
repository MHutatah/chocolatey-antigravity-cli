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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.17-4823843970351104/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '0BE5ACA848BBB84663E7037263972058425B64D438D9437F22780C8F66D28FF79272AF0773234883DA7E99F1F0F25245CD39B2D0891CAFF63DFA2623011E1933'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.17-4823843970351104/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '7B468FB7B83F0DBD5BE39AFEBC5CE71570DE4D1020E248CF1D2461D338F5D0F6EB689500E0F68A36D26179BE6632F74A2D96A34F37D6EF20F62B28B87D7C55B2'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
