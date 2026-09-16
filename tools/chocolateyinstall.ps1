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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.4-6085322963025920/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'BBBBCEE8C1AFCDC3FBCBE4E0ADE161B34F00D666BCC388E9DC43062BE6BB293B254C1A20AC6E6730D410EC014EB1366ABFC714D67BE3C1333EA6B1740CA00A56'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.4-6085322963025920/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '6F72C8B5F4DDE4AE098B8818967043A8BCF1F3F1904A19D9D10E9496C95637A3FA8F3A7F6F04CE9627440DF0A63E7ED26E5C54F82597EA874C5DE24231942165'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
