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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.16-6607970839166976/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'E4F8B895E7214CD680C06A390DE815A7E15485815EDD9F1093F4D39567DEA78D2C7D44E77943EA21371DBF67F79B71C95DD7448B8A82947A9A91080A4AC5C062'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.16-6607970839166976/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'EEADA12986101FDD06130393E82BE6CE9BB835493DE934D12835DB8A1BB20CCB9CDCFC43553EC67E71F43484DA9821D4BC710CE117A43FAC0439CCF5714DE701'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
