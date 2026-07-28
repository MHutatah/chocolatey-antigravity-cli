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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.8-5636713813508096/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '1159967E80F3939F47A3BD6AECFE37DA9F4425C571CB4E91E17E842FEB550865016A894E5CE3A9263D9021B39D617B9BDF162AC355BB9BC03DF7BA0326D5ADF3'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.8-5636713813508096/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'B345091C96ADB1FAAE7191BF0F9C77744E46E418ECF23B5037483E0A9041949D0C0858AC948A6FC462C68FBE40C0F0366BE14A022DFAF01CDA935BB7BFD15F89'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
