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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '1BE97BA06C66176BAE16C9034AC0F813DF495232084C40DF0C76460F947B58ED688019593DFB430F2256ACF544F233055A3390B3E9043FADFFC9FF7B46A9660A'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.15-5514532022517760/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'F9B9D4FFE050C9B909DF2AFFFC5DCCA834CD97ED18C1A4CC1B686244C24CF53FD44B45C34C99C25B9892CB8057CBF35A27A376DB0A62A5222E1CBF9E8E0BB47E'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
