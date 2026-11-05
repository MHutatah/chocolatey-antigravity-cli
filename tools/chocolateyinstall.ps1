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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.1-4523430503120896/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'F23080F15CFC91E798458D560378AFE49E7F8A27DF57D8CDCA08B5CB0367A27C97BDF4AAEC2EE0425AB71C87EB46FA6BDBEED99B2AE30FB19DAEBE08873A97AD'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.1-4523430503120896/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '218D2751189E25A275122519A2AFC6A3D0AF5FF68306CEBC68A5DA3127BCA69A497760988BFD40A884A619D4FA58CCAFCB2FBA1289DC1FC56E3D7D7B565F4CEC'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
