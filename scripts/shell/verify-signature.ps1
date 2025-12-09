<#
Verifies Authenticode signature for built installer or exe.
Usage:
  ./verify-signature.ps1 -Path "release/1.0.0/self-sign-electron-poc-1.0.0-setup.exe"
#>

param(
  [Parameter(Mandatory = $true)]
  [string] $Path
)

if (-not (Test-Path $Path)) {
  throw "File not found: $Path"
}

Get-AuthenticodeSignature -FilePath $Path | Format-List Status, StatusMessage, SignerCertificate


