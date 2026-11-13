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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.8-4602374149505024/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '496B02FD465D360816FCDF61B11187E277967BDED9A91C8B19E9FE286123BA4BC033567662A601C60F857B53FC07E1141D9F5D266DF1E79AF2FA18888B9B9659'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.8-4602374149505024/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '488CEE499FC4AD4326D22646662966054D14256D74A1A22C9EEBCEE4C2DE2EE130FBE6C916FB9EE3BD485209F4F734EB66E00E4D5212D03E5F251A6E4315AFC4'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
