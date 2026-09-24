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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.10-4751581200121856/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '47A54C3DC3BEF24CD6C6134E2C7A184C4D3713D682E80B9982B26FA26554FFA20B40EE9E64C2CFF3A5CE48D45569FCDBA7EBA21E2F75C0807057D2A2E39EF534'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.10-4751581200121856/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '8E13CB961B1F57FB8F4786F634F6C887F4D62FA6FE0AC534DA5B58F6031FD63AC26E526E8BB8281D627760617DC68B0FE038EF361333C0D020393E87997F1734'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
