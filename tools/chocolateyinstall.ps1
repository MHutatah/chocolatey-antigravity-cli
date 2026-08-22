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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.18-6435547766456320/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '33B65754CBB026D24CB7ED04F3E2CA8079AF23B55E8F036B2930D4E20E68B78996B7F3AA1C61C4BB0DF9C1BCB0D35B932F9001CD881DAB46C5EEAE1A210C5E37'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.1.18-6435547766456320/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'D3740A2360B114575C1D3C9BCF784855541A6682FEC7EF20148AB157917ABB682D5A9179A26F844CD161583C6167BD079707D373E7664C731296017AEB0B2F6E'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
