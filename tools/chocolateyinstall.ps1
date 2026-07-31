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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.9-6572839516635136/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'E9EE3960B023ADEC8BF6ADD28339BD9AB7CDDF01F6D4E9374DC134FAA21A44D195A0CB8DD5A0E308E37137F38A631630FEC5094662CDA13EADCE26B009F853F4'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.9-6572839516635136/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'EA4E55761B8252DCF5E051C61B1CDAE1DCAFCB9B8A76672AAB13A2E8407FD8AE9FA5A389449F594C2FC970991AFD5188A4BEAD1B06FE86DBB096AC2472893AF1'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
