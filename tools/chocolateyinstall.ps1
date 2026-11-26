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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.18-6386224290725888/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'CC552CA2EEC40FE433045D09ECB70263AF95D8530ECA5EBDA3D68C1534829F41CBC9C2F2B8DD25A72601C56403AE12758A19A0904951BFBE804520B930AFB829'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.5.18-6386224290725888/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '53605DB7013DFED51E8C416D51E0C17A3B5AD0750C13DA5669954BA4A281318746BE0CF8CDE2B256CFDB4BFBDADE4BADAD1A0503931F8458416184549AFA06B6'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
