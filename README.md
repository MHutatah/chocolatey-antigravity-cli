# antigravity-cli (Chocolatey package)

Unofficial, community-maintained Chocolatey package for the **Antigravity CLI**
(`agy`), the terminal build of [Google Antigravity](https://antigravity.google/)
and successor to the Gemini CLI.

> Not affiliated with Google. Antigravity is proprietary software (c) Google LLC.

```powershell
choco install antigravity-cli
```

The package downloads the official Antigravity CLI binary (x64/arm64) at install
time from Google's storage bucket and verifies it against a SHA256 checksum
(see [`tools/VERIFICATION.txt`](tools/VERIFICATION.txt)). A daily GitHub Action
runs [`update.ps1`](update.ps1) to track Google's `antigravity-cli/latest` pointer.