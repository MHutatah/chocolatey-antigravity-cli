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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.0-5281842794987520/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '9F9A5E43C880B738E656ECC06A904A4B8E07CCF67DB67FC858EFEA59BA383B6F4EF52C47CB0275CA71A0F56D005F90A5417E10FC2BEF122D089E11FA2CFED977'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.0-5281842794987520/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '7F49ED6C1F83F0DCDFAB61EEEB51C71C8B273AED893AC47F50C5B0D7EB4D26F417E495368D6C6FE7499AF47AFE43DF1772E656B341A23399ECCBDA76AFDBDE99'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
