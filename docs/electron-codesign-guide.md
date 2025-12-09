# Internal Code Signing Playbook (Self-Signed, Windows, Electron + electron-vite)

This is our in-house checklist for building and signing Windows artifacts with a self-signed cert. Self-signed is **test-only**: SmartScreen and browser downloads will still say “Unknown publisher.” For production, use a trusted CA (EV/OV or cloud signing).

---

## 1) What we actually do

- Build outputs go to `out/main`, `out/preload`, `out/renderer`.
- electron-builder targets NSIS x64, outputs to `release/${version}`.
- Signing is fed by env vars: `CSC_LINK` (Base64 PFX) and `CSC_KEY_PASSWORD`.
- Scripts: `npm run build:win` (local), GitHub workflows for signed/unsigned releases.
- Secrets are **never** committed; we ignore PFX/output.

---

## 2) Generate a self-signed cert (our script)

Run (Admin) `scripts/shell/create-self-signed-cert.ps1`. It produces in `scripts/output/`:

- `self-sign-electron-poc.pfx` / `.cer`
- `csc_link_b64.txt` (use for `CSC_LINK`/`CSC_LINK_B64`)
- `csc_key_password.txt` (PFX password)
- `env.txt` ready to drop into repo root (not committed)

Why self-signed: fast local testing. Expect “Unknown publisher” on downloads; SmartScreen reputation needs a trusted CA.

---

## 3) Local env and build

Create `.env` (local only):

```
CSC_LINK=<Base64 from scripts/output/csc_link_b64.txt>
CSC_KEY_PASSWORD=<from scripts/output/csc_key_password.txt>
```

Then:

```
npm install
npm run build:win
```

Outputs: `release/<version>/self-sign-electron-poc-<version>-setup.exe` and `win-unpacked/`.

Verify:

```
Get-AuthenticodeSignature .\release\<version>\self-sign-electron-poc-<version>-setup.exe
```

---

## 4) CI (GitHub Actions)

Workflows:

- `release-signed.yml`: builds, signs, and creates a GitHub Release.
- `release-unsigned.yml`: builds unsigned and creates a GitHub Release.

Secrets required:

- `CSC_LINK_B64`
- `CSC_KEY_PASSWORD`

Permissions set to `contents: write` for release creation. Builds skip publish to updater endpoints; releases are assets-only.

---

## 5) SmartScreen reality check

- Self-signed will show “Unknown publisher” in Edge/SmartScreen/download prompts.
- Installing the cert into Trusted Root on a test machine helps file Properties show the publisher, but SmartScreen reputation still requires a trusted CA (OV/EV or cloud signing).
- For public distribution, plan for OV/EV or Azure Trusted Signing.

---

## 6) Troubleshooting (Windows)

- “No certificates found”: check env vars and Base64 correctness.
- “Unknown argument project-version”: use version bump before build (`npm version --no-git-tag-version <v>`), run builder without that flag.
- Path issues in CI: avoid nested working-directory; use repo root for cache paths.
- Compress-Archive errors: pass paths via `-Path` and `-DestinationPath`.

---

## 7) Production plan (outside this POC)

- Use a trusted code-signing identity (OV/EV or cloud signing).
- For macOS distribution, you need Apple Developer ID + notarization; self-signed is not acceptable.
- Protect signing material; never commit PFX or passwords.
