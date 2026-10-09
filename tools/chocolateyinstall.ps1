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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.2-5813501495738368/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '665AB77F10C93D10A9B5AD87B74BCF6F3EB5392387627149BB81F52BD2AF86581211AFB9BC3D0BE253D569888C63DA1A187C5C39E5F5D224C9B9E7E75ECA42E9'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.2-5813501495738368/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '088F449E742A72444539088DF261DB30010C8DEE16DC32920EEDE24C8AB497CE3DA410DD42FE4D673A36EB0C5084411399BA44F77F96389130A36027696F2120'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
