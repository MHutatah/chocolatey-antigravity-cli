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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.7-5951805767680000/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '4A796DF086F6DC74B81983770CBC678A9BC4E3268B68E1163576C12D87FAF115667DC9563E079DA7698F41548D565ABFD95E57FFA31E2824B2469602AD85B5DA'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.7-5951805767680000/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'C9442D25FF147AB27327503B3D75F8E08AD0611528DC749BB9030C39D677DC1A1ACBA278498C2A852675C9C22782D8BEECECB33E8E0C234FA0344405EA05BD32'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
