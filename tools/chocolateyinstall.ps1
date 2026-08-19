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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.15-5350383476932608/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '1BF81D8C66A41EC11A3A15173AEF1C109283AC76FA65117AF043081FFE2767DCFE8D32A78A8E1CE60FF378E6E0B65F5E646DD9BF1AB65F2CEE2058EAEB6C92C7'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.15-5350383476932608/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'F336E4EE83FC29A5DBBDA1A918A2ADA7B166270916F6342DCA98B1FA6F6EBC2D8F39FA49CEA3443D7D8DB5C906F386682F2E8CDEEA20A94D9C8C3C20BE68F0F9'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
