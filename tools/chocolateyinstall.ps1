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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.16-5250855658717184/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'A3D961732875EEDC8CF9B946C542290616D41508EBC9144CB38787615F95B48DDFC9D3EDD5BEE06EAAE061A0FA000A03C3DB9EFAFCD046D90EC021EC4C54EEA9'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.16-5250855658717184/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '058A85911C40A0BEBA24D0AE4E3227EA5060388060D4746AA6B48722FF43516C16FBFFE6D30E31E2C266D5B47495A7886F072CC4E0143B26EB3CD9A007578C83'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
