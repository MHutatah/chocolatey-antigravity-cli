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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.22-5711547746615296/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'DA501A3D8F2247FC1D5334EBB6277CC2D04CD5618416A1A439B54F2267815D8122B22A1571E3F3DD8CE697DB92ED0692F367777034EFDBFEEBADACC70753DF3C'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.22-5711547746615296/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '8EF970162AF92B48F2BA6BA927A0D46F67AD29F5D48693B07B2B4C6461C03CF4AD81DFE628B2976E53AD5E350379351DED5D2B7C0DEEC2FFD85703D546669FFF'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
