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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.24-6130423206641664/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '2810AF04F7E912109D4DC5493762A93DFE2DDDEFDCE86BED1FA5C0DC87974AC18573197729344DE5EE1507ADE93F6F08D2FAEEA3B9AE8F56A3759299C6CD775C'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.24-6130423206641664/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '8D45E36D0F66BB5D5B809C10B108DBD411E621F6E7E37D908F2E0369E88D3B809FB1A0AD8CD26858ED63FB4F08A1CF84A3658BA6907938A267DCDD3A387F0C11'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
