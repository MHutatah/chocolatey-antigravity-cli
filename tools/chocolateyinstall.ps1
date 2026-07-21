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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.5-5958982624477184/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '96AD7EE0E286F5DFA868B0C61CE05F826FC741469F5C3D8A90B609F20BA1A17EA1DDADD1D0A9D1801BF45B3ADDD74A067202064AEBC07F23D2752A3667C93B16'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.5-5958982624477184/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '200A3814BBC775EA9E479DD00CC2D7315F471C0CF31A46D376C6E7248D5803DED8C9BC92DDE677AFE25CCE23143B5B4348495E5E908AD6EFB5C3516D99843510'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
