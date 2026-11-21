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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.14-5302690847260672/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'B2CE5462CF1845B25C05CA651B5BD93735FD807F8E7B40C61D0E99445DF1A76B97EE24C890D5F5BA0453F848CA174F74D492AD1901A2DDCBA5D7A9B4399DDFEF'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.14-5302690847260672/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '785548B23242EC9112759BB4B525D94A3D4D2E9868E5CEDB9EA34E5CE01DBB00ABF5DE66C41D8F4903E8A4379445F685483F999ECE91867BFBD9D4812760D835'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
