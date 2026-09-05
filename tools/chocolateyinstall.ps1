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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.27-5211191891591168/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '6D290388D41C84AA83BDD6A94F8C5AD177FCEFA659DAA55EE6953DF475001219EC8245C0D9CEEB2432449B5ABBC8793B0D5DBDC54F2930A48DE5A5BA79CAEC5B'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.27-5211191891591168/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '85B4FB9CB6C2235142D02D869FBF7B0A8A4B0CA0D0994DD1948B58CACB9F69F59D337D9808298B8C2054F604C6849FEA977D17B898E9662168CC7FC870F8AA3C'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
