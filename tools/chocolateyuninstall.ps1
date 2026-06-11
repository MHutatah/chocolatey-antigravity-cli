$ErrorActionPreference = 'Continue'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Undo the shim created by Install-BinFile in chocolateyinstall.ps1.
Uninstall-BinFile -Name 'agy'

# The downloaded binary lives in the package's tools dir and is removed with the
# package, but clean it up explicitly for good measure.
Remove-Item (Join-Path $toolsDir 'agy.exe') -Force -ErrorAction SilentlyContinue
Remove-Item (Join-Path $toolsDir 'agy.exe.ignore') -Force -ErrorAction SilentlyContinue
