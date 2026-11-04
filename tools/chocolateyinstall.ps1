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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.0-5269980577660928/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '20985F05C0355AFB83E041A70900FACE50D9DB5001EDF1C7F87BBFE8E6A8A773A3BC5654AA7AA49E09B55EBF8A1872CE9DA546CFB419EDB3F07F96F89A88B0CA'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.0-5269980577660928/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '9877ACE806BE37A3B8A8165CE1F61016D07955EC4306219051F90F4749A38727D61EF2D1A6441270684CEA7FD2733C8A8524170EC9FF301B1B6A6B9C543D864E'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
