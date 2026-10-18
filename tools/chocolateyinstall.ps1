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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.2-4835981233356800/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '2A3DEDE68C9610F290E2692975F5EDD2B2A520ADDC7F42BFB32B32D26210E315DCC5C0ECA0E8E63D5BD0E3BD7E434539779B29F29197A81AB911224570A4D436'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.2-4835981233356800/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'E264FC21BBA7A105B03E1EDB07626FE75DC63BCC61BADFD5C6B575C57115523EFCA4F158B976B445DBC7164521383A9B3D8EDDB16F63E97823A9D8B52CBDACCA'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
