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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.25-6680093607723008/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '8D8E240C9B6E96C8B96F24ED641F0E3D4C59B0D40D1870E8FB841CA77FE13A30B35C498A27C9A9FA44712346DDE072D8145CFAF3D39B254C49AA7707568B8EE3'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.25-6680093607723008/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '55BFCFE11AC6196AC7C1FF440A9BE96EFD1BF8E2567B696D0DD92B64F53A37AE983FCCA571FF93D7B81C347CD124BA64D0769D212295504A4ACD43A65F8924F2'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
