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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.11-4956531888881664/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '3F3EAFD9B9C3097774606BEB6FDDF702323C1A3CB7D3B54C3C325427E6094009988093F05302868BBDC5EEE8D87C96588A0D4D4601A318D0E4CE0E3003C457C2'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.11-4956531888881664/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'D8725D28D5E4D1E8FE17D6646DA2EA02620D56A292E682201DCE60B965856E5B8E220F17EA72FF44F3AE38AE8137A18B56786A54FBBAE02FE30C452FC5DADDA1'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
