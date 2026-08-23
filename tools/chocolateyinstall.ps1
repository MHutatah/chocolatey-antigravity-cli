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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.19-4894004681244672/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '2EA35AA877892B1C40482FF748BAC90958998BFE15E81F49EBB1F3880550ECBDF50786B057F6B95923236B48AB589A678CAD5A9ECF150E4FF4CF6E9EAC582EDD'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.19-4894004681244672/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '5B7C6C93D90244B8DB44BD6E3D6CEF2D7092947CA7870E77DF8E626F6A58E2322F3623CC0D239E90CB698D1F072168A797362A51E25B22338AA6A3E2666DF31E'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
