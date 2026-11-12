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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.7-6190022064472064/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '7E364822F2ED51D9CAECC8279D33EDFB7E5A20C19B95D0D2AB7BEC2E61DFF3250E19DD74CED40249ABC28894C64FADB78B683BD549BECBFD4A82D13A26B35E69'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.7-6190022064472064/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'D7303A9AC4597B4EFEA5DFDF40F648525AB5825BADDE2FABDB96A57196B71F6F16B645370E7933CC93A532389367799222B8356944454ABE646D93C7FF2B1B38'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
