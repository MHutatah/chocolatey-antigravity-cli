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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.4-6277569641840640/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'FBF29D9F2E54E62A03AC8E817C6BE71A9498D7E4D0FC22457D2C4025B3DA67886703286F1078D090F8BDE1482723A92D75070E34C8C734A172174B811B886818'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.4-6277569641840640/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'BCE6FB59B4E632217AED5C4C5689B352AE3726AC82D51F0A0FCC2587CB72A24EE18652140F539DC1A8C9BC66F46BBF131607DDCF2A8752B4994641B76C86A4DC'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
