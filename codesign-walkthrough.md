# Self-Signed Code Signing Walkthrough (based on `electron-codesign-guide.md`)

## What we changed (repo)

- `electron.vite.config.ts`: set build outputs to `out/main`, `out/preload`, `out/renderer` (matches guide Part E).
- `electron-builder.yml`: added Windows target (nsis x64), output dir `release/${version}`, enabled signing via PFX env vars, removed old schema-incompatible fields (aligns with guide Part C/D).
- `package.json`: `build:win` uses `dotenv -e .env` so `CSC_LINK`/`CSC_KEY_PASSWORD` are loaded at build time (guide Part D).
- `.gitignore`: ignoring `*.pfx`/`*.p12` (guide Part C security note).
- Created `.env` (locally) to hold secrets; not committed. We used `env.txt` earlier as placeholder, then `.env`.

## Steps performed

1. Generate self-signed cert (guide Part B):
   - PowerShell (admin): `New-SelfSignedCertificate -Type Custom ... -KeyUsage DigitalSignature ... -HashAlgorithm SHA256 -NotAfter (Get-Date).AddYears(5)`
   - Export PFX with password: `Export-PfxCertificate -Cert $cert -FilePath <path>\self-sign-electron-poc.pfx -Password <securestring>`
   - Export CER (optional) for trusting locally: `Export-Certificate -Cert $cert -FilePath <path>\self-sign-electron-poc.cer`

2. Place certificate files:
   - Stored PFX (and optional CER) under `self-sign-electron-poc/cert/`.

3. Configure environment (guide Part C Option 1):
   - `.env` in project root:
     ```
     CSC_LINK=C:\Users\Work\Documents\POC\self-sign-electron-poc\cert\self-sign-electron-poc.pfx
     CSC_KEY_PASSWORD=<your-password>
     ```

4. Build config alignment (guide Parts C/E/D):
   - electron-vite out dirs set to `out/*`.
   - electron-builder targets NSIS x64, uses env-driven signing, output to `release/${version}`.
   - Scripts load env with `dotenv-cli` before build + electron-builder.

5. Build and sign (guide Part F):
   - Command: `npm run build:win`
   - electron-builder signed: `self-sign-electron-poc.exe`, `elevate.exe`, uninstaller, and installer with the PFX.

6. Verify signature (guide Part G):
   - PowerShell: `Get-AuthenticodeSignature "release\1.0.0\self-sign-electron-poc-1.0.0-setup.exe"`
   - Result: `Status: Valid`, signer `CN=Self Sign Electron POC, O=Self Sign Electron POC, C=US`, Thumbprint `C21AD77FF0611C5FABCAD75E0006A567A0462089`.

7. Optional trust for local testing (guide Part H):
   - Import CER or PFX into `Local Machine > Trusted Root Certification Authorities` to show your publisher name and reduce warnings on your machine.

## Build outputs

- Installer: `release/1.0.0/self-sign-electron-poc-1.0.0-setup.exe`
- Unpacked app: `release/1.0.0/win-unpacked/`

## Notes / Caveats (guide Part J)

- Self-signed is for testing only. Production requires a real code-signing cert (EV recommended) and Apple Developer ID for macOS with notarization.
- Keep PFX and `.env` out of version control (already ignored).
