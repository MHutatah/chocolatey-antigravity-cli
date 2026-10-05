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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.17-6683332533157888/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '712ACD49A7EFD65C5A0425CB8402344534AEB5F17DDB35913AC47511D9C09297916058D258BD46A5984777F13A6A21006F925FC750FC295BB7A0550A35FB992B'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.17-6683332533157888/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'FA3CBE2AA9F8CCC6DBF9333346CC5943020C6C71F112F9C221E573B49C39A073AD192BB8F59A0A526FF5471A72440BAD87148158900EDB689DC18DB68D998A9A'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
