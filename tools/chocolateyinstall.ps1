$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Antigravity CLI is a single portable native exe, downloaded directly from
# Google's official public storage bucket (storage.googleapis.com/antigravity-public).
# The SHA256 checksums below are computed from those exact official binaries.
# See tools\VERIFICATION.txt for how to reproduce them.

$packageArgs = @{
    packageName  = 'antigravity-cli'
    fileFullPath = Join-Path $toolsDir 'agy.exe'
    checksumType = 'sha256'
}

switch ($env:PROCESSOR_ARCHITECTURE) {
    'ARM64' {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.8-5528783575449600/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'F638B301522725D9F064C9C103CE661E7F0EB31EB89D54DE1284882CBA8D6311'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.0.8-5528783575449600/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'C920099EB9932521DEC8430E6CB94934DA26B26AC1F21CDFBC49797833E4E0E0'
    }
}

Get-ChocolateyWebFile @packageArgs

# Chocolatey automatically creates an 'agy' shim from tools\agy.exe at the end of
# install (and removes it on uninstall), so no Install-BinFile call is needed.
Write-Host "Installed Antigravity CLI (command: agy)."
