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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.6-6535449645285376/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'CC66896DC08D4DF0B29CE9380492EE600548CCA58DB2C9D80DE2863740C4D526ACB937572BC4A2A2F48B87A0ECE81C71D19D359B80CE8B5A039AD6F9F50B1C71'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.6-6535449645285376/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'DB69E85C198DC5496B83C4CFE7493A94583A2197D0C7367AD2C352644E779B1D469FDC223566E568A723E85478C6556F61D707D4D6E03BBB7356B08B30049490'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
