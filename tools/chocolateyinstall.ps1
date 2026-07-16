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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.3-5723946948100096/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '692CB15B05C7551832D8FFBB1C4999B9CE141C15386CE1A587EDF2840A064CC24F1AA951112A361B66645E4A43347D067EFD3B9F9589241E660DF56B48B20BE9'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.3-5723946948100096/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '8658CAADEF37E73392511EF80E6C6D55B6F8ABD353D86CCF7A1D7DE7974F48D6AF52514D91A1AC6D7DF4F7D1ADEFD1620A8E7973163E51792D06175E995F4FA6'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
