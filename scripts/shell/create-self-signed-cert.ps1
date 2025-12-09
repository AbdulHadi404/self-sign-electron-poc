<#
Creates a self-signed code-signing certificate and outputs everything needed as text:
- csc_link_b64.txt (Base64 for CSC_LINK/CSC_LINK_B64)
- csc_key_password.txt (the PFX password used)
Outputs are placed in scripts/output/. Run in PowerShell (Admin).
Note: PFX/CER are still written to scripts/output/ for local signing/verification.
#>

$outDir = Join-Path $PSScriptRoot "..\output"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$pfxPath = Join-Path $outDir "self-sign-electron-poc.pfx"
$cerPath = Join-Path $outDir "self-sign-electron-poc.cer"
$b64Path = Join-Path $outDir "csc_link_b64.txt"
$pwdPath = Join-Path $outDir "csc_key_password.txt"

# Generate a password automatically (you can change this to prompt if desired)
$passwordPlain = [Guid]::NewGuid().ToString("N")
$password = ConvertTo-SecureString -String $passwordPlain -AsPlainText -Force

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

# Produce Base64 for CSC_LINK / CSC_LINK_B64
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($pfxPath))
Set-Content -Path $b64Path -Value $b64 -Encoding UTF8
Set-Content -Path $pwdPath -Value $passwordPlain -Encoding UTF8

Write-Host "Generated files in ${outDir}:"
Write-Host "  PFX: $pfxPath"
Write-Host "  CER: $cerPath"
Write-Host "  CSC_LINK/CSC_LINK_B64: $b64Path"
Write-Host "  CSC_KEY_PASSWORD: $pwdPath"



