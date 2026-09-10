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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.0-5210873191596032/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '4AC28489A7FEA9DC06E57C8B52AF97FFDDB54F4DAF9166AE198634A8537C6BAD84E156D14910DB05EB1576354FD5031FF7B030E0E5DD550C5A3354F1E05C030C'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.2.0-5210873191596032/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = 'D1F5ABFCA59310A0245614FBD8A0D270DB7DB6A4C329596D74DDEE4DA15DA663018904B5051F9F77F8A343FBF0938F806B06B42830A1EAFADB63F60829397AE4'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
