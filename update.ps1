#requires -Version 5.1
# Automated updater for the community antigravity-cli Chocolatey package.
#
# Resolves the latest release from Google's public storage bucket via its
# 'latest' pointer, then reads Google's official CLI auto-updater manifests for
# the exact public Google download URLs and SHA512 values. It rewrites the
# package files and packs. With -Push it also publishes.
#
#   .\update.ps1               # update + pack only
#   .\update.ps1 -Push         # update + pack + push (needs CHOCO_API_KEY)
#   .\update.ps1 -ResolveOnly  # just show what Google's 'latest' resolves to

[CmdletBinding()]
param(
    [switch]$Push,
    [switch]$ResolveOnly,
    [string]$ApiKey     = $env:CHOCO_API_KEY,
    [string]$PushSource = 'https://push.chocolatey.org/'
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$nuspecPath  = Join-Path $PSScriptRoot 'antigravity-cli.nuspec'
$installPath = Join-Path $PSScriptRoot 'tools\chocolateyinstall.ps1'
$verifyPath  = Join-Path $PSScriptRoot 'tools\VERIFICATION.txt'

function Resolve-AntigravityRelease {
    param([switch]$ComputeHash)
    $base   = 'https://storage.googleapis.com'
    $bucket = 'antigravity-public'
    $manifestBase = 'https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/manifests'

    try {
        $x64Manifest = Invoke-RestMethod -Uri "$manifestBase/windows_amd64.json"
        $armManifest = Invoke-RestMethod -Uri "$manifestBase/windows_arm64.json"
    } catch {
        throw "Failed to download Google's CLI manifests from $manifestBase."
    }
    if ($x64Manifest.version -ne $armManifest.version) {
        throw "Google CLI manifests report mismatched versions: x64=$($x64Manifest.version) arm64=$($armManifest.version)."
    }

    try {
        $version = (Invoke-WebRequest -Uri "$base/$bucket/antigravity-cli/latest" -UseBasicParsing).Content.Trim()
        if ($version -notmatch '^\d+\.\d+\.\d+$') { throw "Unexpected 'latest' pointer value: '$version'." }
    } catch {
        Write-Warning "Could not read Google's latest pointer; using CLI manifest version $($x64Manifest.version)."
        $version = $x64Manifest.version
    }

    if ($x64Manifest.version -ne $version -or $armManifest.version -ne $version) {
        throw "Google latest is $version, but CLI manifests report x64=$($x64Manifest.version) arm64=$($armManifest.version)."
    }

    $x64Url = $x64Manifest.url
    $armUrl = $armManifest.url
    $x64Sha = $x64Manifest.sha512
    $armSha = $armManifest.sha512
    if (-not ($x64Url -and $armUrl -and $x64Sha -and $armSha)) { throw "Could not parse Antigravity CLI URLs/checksums from Google's CLI manifests." }

    $x64Build = [regex]::Match($x64Url, '/antigravity-cli/([^/]+)/windows-x64/').Groups[1].Value
    $armBuild = [regex]::Match($armUrl, '/antigravity-cli/([^/]+)/windows-arm/').Groups[1].Value
    if ($x64Build -ne $armBuild) { throw "Google CLI manifests have mismatched build paths: x64=$x64Build arm64=$armBuild." }

    $r = [ordered]@{
        Version = $version
        Build   = $x64Build
        X64Url  = $x64Url
        ArmUrl  = $armUrl
        X64Sha  = $x64Sha.ToUpper()
        ArmSha  = $armSha.ToUpper()
    }
    if ($ComputeHash) {
        Write-Host "Using SHA512 values from Google's CLI manifests."
    }
    [pscustomobject]$r
}

if ($ResolveOnly) {
    Resolve-AntigravityRelease | Format-List
    return
}

Write-Host "Resolving the latest Antigravity CLI from Google's latest pointer and CLI manifests..."
$head    = Resolve-AntigravityRelease           # cheap: version + urls, no hashing yet
$latest  = $head.Version
$nuspec  = [xml](Get-Content $nuspecPath -Raw)
$current = $nuspec.package.metadata.version
Write-Host "Current package version: $current   Google 'latest': $latest (build $($head.Build))"
if ([version]$latest -le [version]$current) {
    Write-Host "Already up to date; nothing to do."
    return
}

# New version: now record the manifest checksums.
$rel = Resolve-AntigravityRelease -ComputeHash

# Parse the current URLs/checksums from the file so replacement is exact.
$installText = Get-Content $installPath -Raw
$oldX64Url = [regex]::Match($installText, 'https://\S+windows-x64/cli_windows_x64\.exe').Value
$oldArmUrl = [regex]::Match($installText, 'https://\S+windows-arm/cli_windows_arm64\.exe').Value
$oldX64Sha = [regex]::Match($installText, "(?s)windows-x64/cli_windows_x64\.exe'\s*\r?\n\s*\`$packageArgs\.checksum\s*=\s*'([0-9A-Fa-f]{64}|[0-9A-Fa-f]{128})'").Groups[1].Value
$oldArmSha = [regex]::Match($installText, "(?s)windows-arm/cli_windows_arm64\.exe'\s*\r?\n\s*\`$packageArgs\.checksum\s*=\s*'([0-9A-Fa-f]{64}|[0-9A-Fa-f]{128})'").Groups[1].Value
if (-not ($oldX64Url -and $oldArmUrl -and $oldX64Sha -and $oldArmSha)) {
    throw "Could not parse the current URLs/checksums from chocolateyinstall.ps1."
}

foreach ($path in $installPath, $verifyPath) {
    $t = Get-Content $path -Raw
    $t = $t.Replace($oldX64Url, $rel.X64Url).Replace($oldArmUrl, $rel.ArmUrl)
    $t = $t.Replace($oldX64Sha, $rel.X64Sha).Replace($oldArmSha, $rel.ArmSha)
    $t = [regex]::Replace($t, "checksumType\s*=\s*'sha(?:256|512)'", "checksumType = 'sha512'")
    $t = $t.Replace('SHA256', 'SHA512').Replace('sha256', 'sha512')
    Set-Content -Path $path -Value $t -Encoding Ascii -NoNewline
}

$nuspec.package.metadata.version = $latest
$nuspec.Save($nuspecPath)
Write-Host "Updated nuspec, chocolateyinstall.ps1, and VERIFICATION.txt to $latest."

Write-Host "Packing..."
& choco pack $nuspecPath --out $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw "choco pack failed." }

if ($Push) {
    if (-not $ApiKey) { throw "No API key. Pass -ApiKey or set CHOCO_API_KEY." }
    $nupkg = Join-Path $PSScriptRoot "antigravity-cli.$latest.nupkg"
    Write-Host "Pushing $nupkg ..."
    & choco push $nupkg --source $PushSource --api-key $ApiKey
    if ($LASTEXITCODE -ne 0) { throw "choco push failed." }
    Write-Host "Pushed antigravity-cli $latest. It now enters Chocolatey moderation."
} else {
    Write-Host "Done. Built antigravity-cli.$latest.nupkg (run with -Push to publish)."
}
