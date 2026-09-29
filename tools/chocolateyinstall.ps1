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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.13-6662628811079680/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = 'A7DED065B37D98A7FE8052D1A5FE0144C3E416C5D44929DCA9BA6B03CEFFA2FF542E828777B6C42A895E249CDCA656B5141731B705B4D15B967C9DFCFBA8FB7C'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.13-6662628811079680/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '8256013FF3FFBFEC14157E1F25541C303B33D091ED05A645D02267B23C6F4615D8FFA1068CCE2C7687F2FE216375F5D72642B43A2C73F3C90BD0C3D49E443187'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
