# Self-Signed Code Signing Walkthrough (based on `docs/electron-codesign-guide.md`)

## What we changed (repo)

- Build outputs in `electron.vite.config.ts` set to `out/main`, `out/preload`, `out/renderer` (guide Part E).
- `electron-builder.yml`: NSIS x64 target, output `release/${version}`, env-driven signing (guide Part C/D).
- `package.json`: `build:win` loads `.env` via `dotenv-cli` to supply `CSC_LINK`/`CSC_KEY_PASSWORD` (guide Part D).
- `.gitignore`: ignores `*.pfx`, `*.p12`, `cert/`, `scripts/output/`.
- `.env` (local-only) holds signing secrets; `env.txt` can be generated from scripts/output.
- GitHub Actions workflow `.github/workflows/release.yml` uses secrets `CSC_LINK_B64` (Base64 PFX) and `CSC_KEY_PASSWORD`.
- Helper PowerShell scripts in `scripts/shell` (see `docs/scripts-readme.md`):
  - `create-self-signed-cert.ps1` (generates cert, PFX/CER, Base64, password to `scripts/output/`)
  - `verify-signature.ps1`

## Steps performed

1. Generate self-signed cert (guide Part B) using script:
   - Run (Admin): `scripts/shell/create-self-signed-cert.ps1`
   - Outputs to `scripts/output/`:
     - `self-sign-electron-poc.pfx`, `self-sign-electron-poc.cer`
     - `csc_link_b64.txt` (use for `CSC_LINK`/`CSC_LINK_B64`)
     - `csc_key_password.txt` (PFX password)

2. Configure environment (guide Part C Option 1):
   - `.env` in project root:
     ```
     CSC_LINK=<Base64 from scripts/output/csc_link_b64.txt>
     CSC_KEY_PASSWORD=<password from scripts/output/csc_key_password.txt>
     ```

3. Build config alignment (guide Parts C/E/D):
   - electron-vite out dirs set to `out/*`.
   - electron-builder targets NSIS x64, uses env-driven signing, output to `release/${version}`.
   - Scripts load env with `dotenv-cli` before build + electron-builder.

4. Build and sign (guide Part F):
   - Command: `npm run build:win`
   - electron-builder signs: `self-sign-electron-poc.exe`, `elevate.exe`, uninstaller, installer.

5. Verify signature (guide Part G):
   - PowerShell: `Get-AuthenticodeSignature "release\1.0.0\self-sign-electron-poc-1.0.0-setup.exe"`
   - Result observed: `Status: Valid`, signer `CN=Self Sign Electron POC, O=Self Sign Electron POC, C=US`, Thumbprint `C21AD77FF0611C5FABCAD75E0006A567A0462089`.

6. Optional trust for local testing (guide Part H):
   - Import CER or PFX into `Local Machine > Trusted Root Certification Authorities` to show your publisher name and reduce warnings on your machine.

## Build outputs

- Installer: `release/1.0.0/self-sign-electron-poc-1.0.0-setup.exe`
- Unpacked app: `release/1.0.0/win-unpacked/`

## Notes / Caveats (guide Part J)

- Self-signed is for testing only. Production requires a real code-signing cert (EV recommended) and Apple Developer ID for macOS with notarization.
- Keep PFX and `.env` out of version control (already ignored).
