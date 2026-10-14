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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.5-6164039479459840/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '62D7CD7B17AD3F120A581990576DC80A8F97931BE4C49E1043267C8DD74B611BF93ADAE1BFA40B769B1A4F24B5F1BCA2572D1F270DE185E44D5E424B22AC71D1'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.5-6164039479459840/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '4483CAC360DCEDCDBA19C49D4E589559CE7FCBA039DAF1887FFA5BD68D1F4437660733295822C13283D4243E00813259AD839466F5B9BC6C20728077A392D38C'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
