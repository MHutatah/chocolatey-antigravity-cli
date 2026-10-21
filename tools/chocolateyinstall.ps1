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
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.4-4783783166214144/windows-arm/cli_windows_arm64.exe'
        $packageArgs.checksum = '6160EBCE6FAECBF3ED84471BA850978E66E9336700579C1F116D36C681D820A1948309BDF176D0FF24DCEB4A7E941215C61697555A928EC4B0D6454BDC8CEFA3'
    }
    default {
        $packageArgs.url      = 'https://storage.googleapis.com/antigravity-public/antigravity-cli/1.4.4-4783783166214144/windows-x64/cli_windows_x64.exe'
        $packageArgs.checksum = '40D73598E36919F4A5C0ABF15A1CE7677CBD7854B3EAA10D77BE1D1354CE9730A54FEEE6D04AD311D27597561F952D65FA0BBF156131E72F4CC528C22AB05462'
    }
}

Get-ChocolateyWebFile @packageArgs

# Register exactly one shim named 'agy'. The .ignore stops Chocolatey's
# auto-shimmer from creating a second shim for the same binary;
# chocolateyUninstall.ps1 removes this shim on uninstall (Uninstall-BinFile).
New-Item -ItemType File -Path "$($packageArgs.fileFullPath).ignore" -Force | Out-Null
Install-BinFile -Name 'agy' -Path $packageArgs.fileFullPath

Write-Host "Installed Antigravity CLI (command: agy)."
