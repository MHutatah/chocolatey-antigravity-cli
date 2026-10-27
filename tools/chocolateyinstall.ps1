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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.8-5447777392656384/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'A856FFFA9176E1DB17603EFB02FDC71250E5FE2881C41519854607C5B5AD4D168CF300A4DE9961E1C4D4B869A40D2ED821CE955B6EFF7F8B9A1F91D18D4AB0B7'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.8-5447777392656384/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '9EA0EC4157540D6F9B9F3DAABACEE1ABED4352987D3AA7294CA405CEA483F7C733711281A5065E8412AE99D98D79525E80E47087A496152B723233F98658A78F'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
