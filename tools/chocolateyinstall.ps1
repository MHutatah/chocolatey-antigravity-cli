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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.7-5900205422411776/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'E37D62282995AF8E86196BC5EC8756DB53676F68867BB6C4E2061B1D45ABC8FD2F88885ED33F8D33A5BC4B2C34419A43316E216C1B8EBCB1060D95C1C0EB4F36'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.7-5900205422411776/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'E9E69F036EF0A9C3329CD0608474711DFDBBF62DF10A98E237C9FB528DAF36BE21B4EE65B796B07E0F10EC266F008BB9E40A9C59BA32E4D13CA87BFEB36D3C2A'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
