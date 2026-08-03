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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.10-6423386432339968/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'DEDB14A49E91F1A4D6613AAD16A04138378AC03888CEE94FDF161EA1D64901E83E53B82DC393CB5E0582C80D7D0B89EB680475FF5081FF550B965B285CBA33B7'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.10-6423386432339968/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'B2FEE3202B1083308621715E3332C4B8280A0DFB0E13A6DE0D4140DB09A64D9C877B3274F3DC1DBAEE86C0C67B4F665EF1C260FE5D4EC761A8CD48FEAF19D8EA'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
