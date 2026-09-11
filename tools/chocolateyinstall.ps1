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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.1-5123043593420800/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'DDAD165ABCC9AF9FF2510ED3266A8793BD852192403BD30CE8A3B7F15B971454C72CF43DFFC352599CB2C0788F80A2585F85F65268012CE12BCA51BFF3AB9B9E'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.1-5123043593420800/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '0B82E5167A7FF950D772A4D651BB9796EABC0330B3EA2D6A2936AF4F7A4E0EA940B123630446FC4F1A50A1735233F1285C53E2BD0E082628E57CFD54E530226A'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
