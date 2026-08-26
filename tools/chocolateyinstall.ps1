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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.21-6424454201475072/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'ACB138E96F1DA33C5DAD2C4B95D9C6B655585592E4DC8F6911E7F0C63847AFE77EED0CDB6C3BEFC44BAEDE5A7E63A420F5CFB5961F930C2760ADF48EECBBFBDE'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.21-6424454201475072/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'DACA9ADF0AC002A9471C321D0A3B5C96D9575AE57799675BA62AC96A3EB56564BF9F665E4DA3F81DA0050625AAC0F2A93DBFE7558417868A380D8CC7FDDF40DF'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
