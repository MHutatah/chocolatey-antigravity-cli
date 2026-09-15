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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.3-5101874907578368/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'CB8BBA34B7146014D71BD21A43340CF0F080E3E2D09453EFF109A133FAE23F8AF18BAD8993D39654EE0A03370F1A372F811E10AF2661D1071A83ED76B28FA386'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.3-5101874907578368/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'B1D25DD76540CA9759D167FBFF27F02EBDE920C4924670640D47B96FF3A2984196CA3D078AE6C668CAD1EE7BA79F633CBEB3C616B8E3CF817DFA83A80D2DC240'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
