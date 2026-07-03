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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.16-4893150192467968/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '4309CDC2A4DC054C92B808749B8F8AA00BC40C902A5B6E390A6FC4B8E3F0D875AFB9CD062EF6C317A64383224BF4757C4E9B90A818C4075EDA3A24C16FDEE501'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.16-4893150192467968/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'A25AA14BA15B271AAEEC4615A1F9E01153959C7E10636A79444DF74AC63D5629A607CB6A2547A885A63D7D100ED628B3D2407A2A200293DC6EDB263522DCB2CC'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
