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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.23-6260551186251776/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '69DDAB12DCCBD647A4B821D085FF57865190674195A55B953FF8AF42DD0E3687269B004E1AEBC926522CFE2A76419BEED59E364363A9831CD17A82FD6CDDF044'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.23-6260551186251776/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'BDD51EA5F01515EF3161A4109CB3BF7CE310E08DD78B9F4DE353ECB9F7408564562ABF0E158F3262FE0103BB2216DDD5D7BD11FE53FA39EA91FDA53774835B70'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
