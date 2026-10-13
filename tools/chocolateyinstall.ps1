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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.4-5524158944247808/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'EE8E6C6E2CEA95A2E05D78F682B008ED92483CD5402D6838A53CA287E09FA3AF3F5322ECD831261D96CFDAC3CDA70DC24E3A4A5D42A5AE1F178CAEE6E14B70F2'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.4-5524158944247808/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '21AC62DEB74ACCE6E7CE3F5FD32411DDAF5E860319CC80857A85DDCE1563D08D6A5042AA913D7211175FBCDE8E4EE5D527ED3F84DCD2B7F0AC3A4C4E8D2008EB'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
