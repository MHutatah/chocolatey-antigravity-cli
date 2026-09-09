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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.28-5576113066475520/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'FBD8ABB46B89329CDBE7B054C317624DF0C525FCE9A8B87A547C78E31D6BBFF4BE02552308069F1BF08E318D4729D837482AF57CDDDC2D1CCC775C4CBCFFCCB3'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.28-5576113066475520/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'DF10BECFBC71EF23786C2CE9A70C5DBD8008D707019D878A69C4F0E5B58D95AA9B1AC6AD0EF5763205D7EAF1A85050D5429E601B662A9FC2D9022CDFC35E98B9'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
