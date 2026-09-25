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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.11-6016716732497920/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'CDC93AE126BD415DB794FC1184006AB7472008ABFFB6F9A026F337138302F48E80D9547E9D6CFFEB7FCADE0D5A2B904E798E35F1D64E12AD503B67895388F19B'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.11-6016716732497920/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '321FC8729CD87A9BF6FF860DB06B686E32DB7D7943E3860F89F1337E085EED62D4F30A4AB216691F8462841298BEB0FC8CE5AD9D846A7014F643E78C76B622F5'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
