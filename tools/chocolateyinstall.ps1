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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.8-4907747922280448/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '6C383AB068B33C01EB2E82A7300CBC33240F856226BD5EE3FAB8F86FA68CDAA737D884872E09586733CA894423F364155778C2A3E5DD2AAF2F6E592EC3702060'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.8-4907747922280448/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'C8B48F0ADD536C78D96F07E278EA272C60FBBAC9FEFD386AD6B6B96DFA11D7496EBBB3BCD664986195D1B5F8A07A34CBB351C64B6B1207E15D1D40283F6C5469'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
