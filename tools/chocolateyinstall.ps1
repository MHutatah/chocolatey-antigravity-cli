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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.13-5999302598852608/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'C85686D6AE68D4566F86AF0C240E4B49A303549AE152757546878193F25A263B02C4D8F1D5030631DC93646A298DCB02713C18E7850390E3DB5C9DDA6C31265F'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.13-5999302598852608/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '6B80A17A2BC34A969ED9BA31500A8201B0B4AAD3E7FE061374022D161FEC8BD7DE49B6DC069A6AC67A90632E8671BBE860A7E94309BC5ADBC536D27A75A86B58'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
