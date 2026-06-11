#requires -Version 5.1
# Automated updater for the community antigravity-cli Chocolatey package.
#
# Resolves the latest release DIRECTLY from Google's public storage bucket (via
# its 'latest' pointer), independent of the winget feed - so it tracks Google's
# releases with no third-party-bot lag. It downloads both architecture binaries
# to compute their SHA256 (the community feed requires checksums in the package),
# rewrites the package files, and packs. With -Push it also publishes.
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

function Get-RemoteSha256([string]$url) {
    # WebClient.DownloadFile streams to disk without the per-chunk progress-bar
    # overhead that makes Invoke-WebRequest pathologically slow for large files.
    $tmp = Join-Path ([IO.Path]::GetTempPath()) ([IO.Path]::GetRandomFileName())
    try {
        $wc = New-Object System.Net.WebClient
        try { $wc.DownloadFile($url, $tmp) } finally { $wc.Dispose() }
        (Get-FileHash -Algorithm SHA256 -LiteralPath $tmp).Hash.ToUpper()
    } finally { Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue }
}

function Resolve-AntigravityRelease {
    param([switch]$ComputeHash)
    $base   = 'https://storage.googleapis.com'
    $bucket = 'antigravity-public'
    $api    = "$base/storage/v1/b/$bucket/o"

    $version = (Invoke-WebRequest -Uri "$base/$bucket/antigravity-cli/latest" -UseBasicParsing).Content.Trim()
    if ($version -notmatch '^\d+\.\d+\.\d+$') { throw "Unexpected 'latest' pointer value: '$version'." }

    # The release build is the one whose exe was uploaded when Google flipped
    # 'latest' to this version (other build-ids are RCs/rebuilds).
    $pointer = [datetime]((Invoke-RestMethod -Uri "$api/antigravity-cli%2Flatest").updated)

    $list = Invoke-RestMethod -Uri "$api`?prefix=antigravity-cli/$version-&delimiter=/"
    $prefixes = @($list.prefixes)
    if (-not $prefixes) { throw "No build directories found for version $version." }

    $chosen = $null; $bestDelta = [double]::MaxValue
    foreach ($p in $prefixes) {
        $enc = [uri]::EscapeDataString("${p}windows-x64/cli_windows_x64.exe")
        try { $meta = Invoke-RestMethod -Uri "$api/$enc" } catch { continue }
        $delta = [math]::Abs(([datetime]$meta.timeCreated - $pointer).TotalSeconds)
        if ($delta -lt $bestDelta) { $bestDelta = $delta; $chosen = $p }
    }
    if (-not $chosen) { throw "Could not resolve a release build for $version." }
    $buildPath = $chosen.TrimEnd('/')

    $r = [ordered]@{
        Version = $version
        Build   = ($buildPath -replace '^antigravity-cli/', '')
        X64Url  = "$base/$bucket/$buildPath/windows-x64/cli_windows_x64.exe"
        ArmUrl  = "$base/$bucket/$buildPath/windows-arm/cli_windows_arm64.exe"
        X64Sha  = ''
        ArmSha  = ''
    }
    if ($ComputeHash) {
        Write-Host "Downloading binaries to compute SHA256 (x64 + arm64)..."
        $r.X64Sha = Get-RemoteSha256 $r.X64Url
        $r.ArmSha = Get-RemoteSha256 $r.ArmUrl
    }
    [pscustomobject]$r
}

if ($ResolveOnly) {
    Resolve-AntigravityRelease | Format-List
    return
}

Write-Host "Resolving the latest Antigravity CLI directly from Google's storage bucket..."
$head    = Resolve-AntigravityRelease           # cheap: version + urls, no hashing yet
$latest  = $head.Version
$nuspec  = [xml](Get-Content $nuspecPath -Raw)
$current = $nuspec.package.metadata.version
Write-Host "Current package version: $current   Google 'latest': $latest (build $($head.Build))"
if ([version]$latest -le [version]$current) {
    Write-Host "Already up to date; nothing to do."
    return
}

# New version: now do the expensive hashing.
$rel = Resolve-AntigravityRelease -ComputeHash

# Parse the current URLs/checksums from the file so replacement is exact.
$installText = Get-Content $installPath -Raw
$oldX64Url = [regex]::Match($installText, 'https://\S+windows-x64/cli_windows_x64\.exe').Value
$oldArmUrl = [regex]::Match($installText, 'https://\S+windows-arm/cli_windows_arm64\.exe').Value
$oldX64Sha = [regex]::Match($installText, "(?s)windows-x64/cli_windows_x64\.exe'\s*\r?\n\s*\`$packageArgs\.checksum\s*=\s*'([0-9A-Fa-f]{64})'").Groups[1].Value
$oldArmSha = [regex]::Match($installText, "(?s)windows-arm/cli_windows_arm64\.exe'\s*\r?\n\s*\`$packageArgs\.checksum\s*=\s*'([0-9A-Fa-f]{64})'").Groups[1].Value
if (-not ($oldX64Url -and $oldArmUrl -and $oldX64Sha -and $oldArmSha)) {
    throw "Could not parse the current URLs/checksums from chocolateyinstall.ps1."
}

foreach ($path in $installPath, $verifyPath) {
    $t = Get-Content $path -Raw
    $t = $t.Replace($oldX64Url, $rel.X64Url).Replace($oldArmUrl, $rel.ArmUrl)
    $t = $t.Replace($oldX64Sha, $rel.X64Sha).Replace($oldArmSha, $rel.ArmSha)
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
