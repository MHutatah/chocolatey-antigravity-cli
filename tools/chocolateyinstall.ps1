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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.5-4952523841339392/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '2D002DA52A693746C33243E247663AEFD68A9609CC89FB066B4B65471AC464F3E8E05C7B951D2EEAEBCD9F7EE2DDDBA996343952AD35FE99A591BCEFA9807DC3'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.5-4952523841339392/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '05CB2E7669DBE43F978038240E1A4E03B2AAE4858277E3670617E9F92ACF693760392F7C96A6E0DE351BBC7E61894B7075059930FBEE41EF8142D6DDCC15E92A'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
