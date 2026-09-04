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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.26-5550154686791680/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '3F831CC141CCC2956540C606E917B4C3E5B593629D57EEE08F110C9442180CAE3065D97EBEEA24A06B09947780BAE7C621CC351447CD821001554D24788528C5'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.26-5550154686791680/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'CE5B88CB4A9016A3C8834B26C4148AB666064FB28101431D79D072965FFFAF2A0DB2CC632447CD7B1DECA60C95E5E33B1C1E4C43B3D2E47A7070C00FC7655D34'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
