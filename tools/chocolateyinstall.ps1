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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.20-5830032204103680/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '72C9F56E86F226C82368983348589D22AEDC48BEA39C26190C6F259B8FDE735E367F24BAA89769EBD61E86916C2F66C38DE250F1365CCC0ECB3A79436E00C62A'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.20-5830032204103680/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '14F800B37C6D96944AB1C844DE8D8B9A09DE85B05FDB88B6F1181095E80E62FD720F94B7AB3BEE506A96A37B7366D28DDD9664361A7EDF28B478986783FE31B3'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
