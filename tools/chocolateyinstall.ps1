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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.12-4768735748292608/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '8D25C63471091B49578ECCA401F61AE9B5104B86D8B51971B904C15FFB96C829E8EA195B46BE1EAC23274BBB17F1EBC8D92E2E0A29F9FA01D40E4F04EB30AEB0'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.12-4768735748292608/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '6F44299B3B2F8DDB349F1E21BF07962C602A117ADB62D7E81A4B041EDE2067EC77ED26059F8636CB94295BFC9DD9F8CA9BF9CA4F4B4159EE6171A17A082C4082'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
