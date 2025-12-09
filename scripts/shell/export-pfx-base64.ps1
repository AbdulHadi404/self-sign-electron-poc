<#
Reads the PFX and prints base64 to use for GitHub secret CSC_LINK_B64.
Run in PowerShell. Outputs to console and also copies to clipboard.
#>

$certDir = Join-Path $PSScriptRoot "..\..\cert"
$pfxPath = Join-Path $certDir "self-sign-electron-poc.pfx"

if (-not (Test-Path $pfxPath)) {
  throw "PFX not found at $pfxPath. Create it first (create-self-signed-cert.ps1)."
}

$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($pfxPath))
Set-Clipboard -Value $b64
Write-Host "Base64 of PFX (also copied to clipboard):"
Write-Output $b64


