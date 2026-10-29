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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.10-5501573669978112/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '20263CA8219A45C4ADDB3FEFB2A748148CD781DFE2B6294261CE48DCD4E95B5C4AD725DC89552E57515A7DB2401A1C2FC3FA26E56D42E2029E13DE5D940A8BC1'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.10-5501573669978112/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '581D3FAD72393696BF2A35B7E66BD1E4EBDF895BAA4727107F1B318DDBA9F076241CD568A170F287FA89BEEE829337E88FF36B00455919F0B0AB1BAC33C3439D'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
