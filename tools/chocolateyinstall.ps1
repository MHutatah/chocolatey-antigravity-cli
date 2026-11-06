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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.2-4951595792859136/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '652B2FD876D248C41EAF65414E32F719EAAB8AC35B26DEEF213FE240C04A1AEC3D16F9E513FD47FB4AD8BD12B32C45C35518DCE7FDB1FC1AF996CB550BE69323'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.2-4951595792859136/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'D0B00AF82E3FD882F83EFBE97905222C80AFC4283D74FBFBE362B4E5BB6CAB6FA0D3188D3851B2B31D45FBD6312FEB54F22321E146F0972ED9583FB38EFB7276'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
