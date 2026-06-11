# antigravity-cli (Chocolatey package)

Unofficial, community-maintained Chocolatey package for the **Antigravity CLI**
(`agy`), the terminal/TUI build of [Google Antigravity](https://antigravity.google/)
and the successor to the Gemini CLI.

> Not maintained by or affiliated with Google. Antigravity is proprietary
> software (c) Google LLC.

## What it does

Downloads the official Antigravity CLI portable binary at install time directly
from Google's official storage bucket, verifies it with a SHA256 checksum, and
puts it on your PATH as `agy`. Supports `x64` and `arm64`.

```powershell
choco install antigravity-cli
```

## Maintaining / releasing a new version

Updates are automated by [`update.ps1`](update.ps1). It resolves the latest
release directly from Google's `antigravity-cli/latest` pointer (no winget/npm
dependency, no third-party lag), picks the release build, downloads both
architecture binaries to compute their SHA256, rewrites `antigravity-cli.nuspec`,
`tools/chocolateyinstall.ps1`, and `tools/VERIFICATION.txt`, and packs.

```powershell
.\update.ps1                 # update + pack only
.\update.ps1 -ResolveOnly    # dry run: show what Google's 'latest' resolves to
.\update.ps1 -Push           # update + pack + push (needs $env:CHOCO_API_KEY)
```

This runs hands-off via [`.github/workflows/update.yml`](.github/workflows/update.yml)
on a daily schedule: when Google ships a new version it updates, pushes to the
Chocolatey community feed, and commits the bump back. It needs one repository
secret, `CHOCO_API_KEY` (your push key from <https://community.chocolatey.org/account>).

## Verification

See [`tools/VERIFICATION.txt`](tools/VERIFICATION.txt). The checksums are computed
from Google's official binaries and can be cross-checked against the
[winget-pkgs manifest](https://github.com/microsoft/winget-pkgs/tree/master/manifests/g/Google/AntigravityCLI)
once that feed catches up to the same version.
