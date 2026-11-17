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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.10-5253791805734912/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'E4A6E8517904648B377656E849ADC90E50E920CF248E82F85778C8CD44094C1CDE39DE3027EC1DE57B6055B4011A2C021506D3CF496217DD8995B721C0B03E4D'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.10-5253791805734912/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '59A5E7B417A898B0322C7D6D6DF06E32CF292EB732096EC958E2CF0A411B40F1186A63CA14370B9BF978C8B619420852F7352531556D941F1D3B1C117D4C05AA'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
