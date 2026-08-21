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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.17-5084709148033024/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '476CB921D8DFFEC9BAFD6404E586AAF297B805AC70F9373373D943A7836D24C8EC5778E24F243368D1E96135629B4A8014EF40E9DE1EA349EECB7DA0006F12A4'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.17-5084709148033024/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '354DEF717FE717F31D03EC5A359041B368A98D856CD544BED1BB8BFDE071C8012A7592E7D8840FCB182E083F9AB587DC1C6585F4C830C26131A22EF7B998799B'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
