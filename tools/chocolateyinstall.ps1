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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.14-6392696810635264/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'AF2572DA5140451247A9FFCFD1BF69623E1BAC768E9D579AB52E03B76698202EAA2FA1F416816E9F47023D5AAD2263CC1F7F11944EFE4435F951B70389042F20'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.14-6392696810635264/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '59FDE8EBF9DDC31964D180A34F97C6046E3D131767E8E8641D0A97EDF3752AD70667374E9353EA9D8D79999F9C0E2FFF720633A676BE41A8FD7B0027FC89AD6D'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
