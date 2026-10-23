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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.6-4884751325200384/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'D65FA18E5851681A8B8B7EA04B2F25A6A6F140F9EE1ED81BFE6CB51DD7FA66D2B7845ACE26DDF7627BE5D1727097D4A64B454B3D997F24164745537C4EECF1BF'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.6-4884751325200384/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '56E6F15CE99D349AE8186D4E049A1CA8C7002E09447B5498DA06581BD02843641BC95AA37046B0121DD3783C3A863135EDBC0650B409A0E6B562C60E76240D22'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
