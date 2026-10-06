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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.0-6233328509124608/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '8DD1B647D153911CC6F696B8BDCFA676C0B1460119E2493001AA127389D914377952189A33E8FBB6D92DBD4BC9D6CA61FC4998F9CD613DDEF7CFE3D5CF892361'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.3.0-6233328509124608/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '00DDC37369441524AA9BD92176E31513E47A2A85FE5D09EC71E3BBE2FD4955551C6B9989F1EB82599DD9329B321E470644106EE3B07C1E3E82BFF67124A67461'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
