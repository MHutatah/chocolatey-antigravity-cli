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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.6-5912685477494784/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'BA9934FADBCD1DD95AFFE0B5A2A729CBA67447F9665F9B29CD033CF4BA24EA0E6E97DB864516BA917C08A52C1AC80EFC6101D138DF8289DEA00D1C032D95460D'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.6-5912685477494784/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'ADED27790F3AC05147DE7AB85315C343EF64379D685AC1116105F6451C6A0399AA4D2C112A735CBC8E6554B76C50E4584A718236D18862E15ACA97999AAB364A'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
