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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.4-5037094733742080/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'EA1450039E65C42055A7F84AC171B58B63AD9D77A05C4B8101511C02652EA76DDD6688243184E6D74DA97DFAFF754AD7DDBE4818A6F00169C5161431A200901C'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.4-5037094733742080/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '7E8F1EEF7ABDB3DED58B23087E8097C8AB49263F2BAB29306BB12A97D0996E0B82F9A35BF9EF07130105CB8354156B81A23E59CE5EE765F8EDA1E7AC96F618D6'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
