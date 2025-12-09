<#
Creates a self-signed code-signing certificate, exports PFX+CER into the repo's cert/ folder.
Run in PowerShell (Admin). Adjust subject/password/paths as needed.
#>

$certDir = Join-Path $PSScriptRoot "..\..\cert"
New-Item -ItemType Directory -Force -Path $certDir | Out-Null

$pfxPath = Join-Path $certDir "self-sign-electron-poc.pfx"
$cerPath = Join-Path $certDir "self-sign-electron-poc.cer"
$password = Read-Host -AsSecureString "Enter password for PFX"

Write-Host "Creating self-signed certificate..."
$cert = New-SelfSignedCertificate `
  -Type Custom `
  -Subject "CN=Self Sign Electron POC, O=Self Sign Electron POC, C=US" `
  -KeyUsage DigitalSignature `
  -FriendlyName "Self Sign Electron POC" `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") `
  -KeyExportPolicy Exportable `
  -KeySpec Signature `
  -KeyLength 2048 `
  -HashAlgorithm SHA256 `
  -NotAfter (Get-Date).AddYears(5)

Write-Host "Exporting PFX to $pfxPath"
Export-PfxCertificate -Cert $cert -FilePath $pfxPath -Password $password | Out-Null

Write-Host "Exporting CER to $cerPath"
Export-Certificate -Cert $cert -FilePath $cerPath | Out-Null

Write-Host "Done."
Write-Host "PFX: $pfxPath"
Write-Host "CER: $cerPath"


