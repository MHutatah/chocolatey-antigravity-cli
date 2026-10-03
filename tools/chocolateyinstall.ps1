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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.16-5594158052802560/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '3BB1F9A0A6D9C13BE8FFB80655AC155D13A255C9C5645F8094DC45321CCFF09584C1976C29583C13686DF87040EB4E62501F2FDFA1F0982C045CC6AB108B858E'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.16-5594158052802560/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '796D9A15983BEDB7DB7F517D94D35A9ACA93B54F4C6E14DD4CE26D5D56EE9924F96AC42F184A8AB3DFCA36A3140C9A60FA3697C363FD847D3F4D32340664F7E9'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
