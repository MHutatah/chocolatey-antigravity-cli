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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.12-5784551402897408/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'A4B702666A2935F927FE34926692BD7572397815E1D533F89F64631B0E314533143913FEDFB530717EA9CB62E3C8AB4426E286765BCBE64442E0ADBA2251E399'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.12-5784551402897408/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'A65A003EB77DB870E7A686B4D809CC874746C8459D07B12C6366D6E80D344744A6047BD558D6859AC0C55D4609CC27BAB17D4D3D1460EF39FBDC8E83B5156E42'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
