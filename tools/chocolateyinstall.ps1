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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.5-4931130160447488/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'A8E068A790AB692AF8812CF893CCAF7E77112212EF0CDF8BC63FA711F12388C75E8E896C0F4A7EBFA89BC27BCF666CC0B68C9EBB37E94C3B38F87102746B8632'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.5-4931130160447488/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '5372089A6BB2D2B0D2EB0B58F505EFAC7AEFED72A09DB0F29481D338354B477769719B096B2DBF889F78D0900A4329B7F6A9D9C7E1076EFC91B8E1E807B989FD'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
