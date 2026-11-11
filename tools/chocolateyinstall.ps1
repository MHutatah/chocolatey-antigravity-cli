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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.5-6740358537805824/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'DD195D009C1B39E205916882ADC7D2CC193CA768B39242FA695D412E6E4522621E5042EE948E4C915776F83D0EFD7A2F02022409217B0C5D318E04C48AF43DAB'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.5-6740358537805824/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '11E01089801B86DB04D92D4CEC3F67BBEFF90CA1076AE46BC7475415AB5F3AD7B53419252B7B2C2A68066375B2B6821A6E74A0A959892DAD656D3EF769D44955'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
