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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.3-6604829099950080/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '62F09BB3DC3C8BB142DE2AD87C855C524CA0EFB70BB9A54430121A021B14060FA3AA39D2A0E0B40B6198EE8FF26AF59CA5911FF5CE19C70FD8AC2CF4E3C7D699'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.3-6604829099950080/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'B282C10CA3266078806D7BCAE66DB8EC0C6E2953EE6E62DE1DA6499182D24C02FFFA8A74C620817BD35B15CF5F5A18287FB1AB30BCB9C7A67592C248696ED909'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
