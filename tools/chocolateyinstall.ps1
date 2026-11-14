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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.9-4515810895593472/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '2FAD3C679C83F9B7D686959980099899A5608CE56866BDD18FE8693DC60C1B0CFC77466910CAAA74B5FE7EEEBFB5B553AFF7815574BF7BDEADCBB27DA22B57AE'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.9-4515810895593472/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '539A9415A686D9EC45F5C59FE7D32C485C6FA9ABAEA50208AE8EDE4ED3622B9FB2BFD6680C87DC52344981172A96DDACB261FF4231276B5572FB5B62A9B0221E'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
