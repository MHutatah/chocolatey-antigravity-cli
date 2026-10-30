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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.11-5180209989812224/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '351C35CD4CAB294B9867C724DAD6C5E28DD589F578436B06293FD177AEF56F7CC6551758007D1060915117A0C6623A48B84F3622A526347D455D3A3B53B195F5'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.11-5180209989812224/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'A70660E829DA409D10906FA6120ED79E3DC44A9AFDE7BE6C6B28A10C2CEE32E6216CFA49F2C1C8D81D7656DF61DCD185B4DD808CA8A65042AF4A6E9110B9D604'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
