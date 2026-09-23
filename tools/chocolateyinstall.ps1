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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.9-5905287731871744/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '3552CDB0D1BF148B71E009EB398047BA1BED0F83BDF8C450F26B166A455ECFD9787A0872306654D79D2BB578A329A4AB37790D4DF96C23610514D8B573A23CF0'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.9-5905287731871744/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'F903D73005B1B0374ABC73DE9CEA260F1C80D18C9411DB15DD67D05372A1A93B3560D1D8CB907125A3F00274758143C7394AF490D3624DCBE82C8874EBB51A8A'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
