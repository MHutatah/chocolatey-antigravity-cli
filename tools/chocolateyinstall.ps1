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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.2-6061403484848128/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '048E7E981E37509A39C0FF0E4708D3BE14D012DB590B913E2B3C3AEB28FEA0E4346EAA1B08CFFFF6B0AFE951EF0A707A31652101639A9CCB9224EC9715EE2A02'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.2-6061403484848128/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'BBAA6CB014064DF87C4FE93C75B031DDADB98F85496B0212C46A7C4241755A6D6F2869A1FE9D5090252CF954CDB715C7BDA8AA2DFEF70021460A245DE9914BCE'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
