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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '8ABCBB02274247830A9669D81CC468EE936958278A46CAA825FC4C3B40D0621284CF9CF5D570DB5C202C6BE353D6410591E5861A27FC3CEB13AC3A687FA2AF4B'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.3-5524738307653632/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'EC15855BD5DE768232C0AEE31D11EAC636A9E7D8BC4AD3DBE3887A9797F7FD821CAFABBA61482CD5515674A05246BE2B7F96CA3F17E38C6A3F7431A2A3AFF81F'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
