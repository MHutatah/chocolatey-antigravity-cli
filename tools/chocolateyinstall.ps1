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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.14-4571742832820224/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '360DBA3CD5DCF230EEC553CD4BAF12E7BAD31F04E5AE7A489255A6993A0D76BAAF50B110225849F552E3EDA02466CE798CB05B70866C2D1E4BFE234B5837F38D'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.14-4571742832820224/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '908FCD591144C6DF86506D7C135A486A2E4F4F606E09A9BCC5EB9BF943E385C06C94E0A218F29D8C5BA26DB1406EE3A7AA2D08AA8685DADC37FE0FCEDA2FCF6F'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
