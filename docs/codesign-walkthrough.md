# Our Code-Sign Walkthrough (self-signed, Windows)

## Repo shape and key settings

- electron-vite outputs: `out/main`, `out/preload`, `out/renderer`
- electron-builder: NSIS x64, output `release/${version}`, env-driven signing
- Env vars: `CSC_LINK` (Base64 PFX), `CSC_KEY_PASSWORD`
- Ignore sensitive stuff: `*.pfx`, `*.p12`, `cert/`, `scripts/output/`
- Workflows: `release-signed.yml` and `release-unsigned.yml` (GitHub releases)
- Helper scripts: `scripts/shell/create-self-signed-cert.ps1`, `verify-signature.ps1` (see `docs/scripts-readme.md`)

## How we generate the cert

Run (Admin):

```
scripts/shell/create-self-signed-cert.ps1
```

Outputs to `scripts/output/`:

- `self-sign-electron-poc.pfx` / `.cer`
- `csc_link_b64.txt` (for `CSC_LINK`/`CSC_LINK_B64`)
- `csc_key_password.txt` (password)
- `env.txt` ready to copy to repo root (not committed)

## Local env and build

Create `.env` in repo root:

```
CSC_LINK=<Base64 from csc_link_b64.txt>
CSC_KEY_PASSWORD=<from csc_key_password.txt>
```

Then:

```
npm install
npm run build:win
```

Outputs: `release/<version>/self-sign-electron-poc-<version>-setup.exe` and `win-unpacked/`.

Verify:

```
Get-AuthenticodeSignature "release\<version>\self-sign-electron-poc-<version>-setup.exe"
```

## CI flows

- `release-signed.yml`: signed build → GitHub Release
- `release-unsigned.yml`: unsigned build → GitHub Release
  Secrets required: `CSC_LINK_B64`, `CSC_KEY_PASSWORD`, and default `GITHUB_TOKEN` (permissions: contents: write).

## SmartScreen reality

Self-signed will still show “Unknown publisher” in Edge/SmartScreen prompts. For public distribution you need a trusted CA (OV/EV or cloud signing). Installing the cert to Trusted Root on test machines helps file properties but not SmartScreen reputation.

## Troubleshooting

- No cert found: check env values/Base64.
- Builder arg errors: we set version via `npm version --no-git-tag-version <v>`; run builder without `--project-version`.
- Compress-Archive: use `-Path` and `-DestinationPath`.
- Path issues in CI: use repo root for cache paths; no nested working dir.

## Build outputs

- Installer: `release/1.0.0/self-sign-electron-poc-1.0.0-setup.exe`
- Unpacked app: `release/1.0.0/win-unpacked/`

## Notes / Caveats (guide Part J)

- Self-signed is for testing only. Production requires a real code-signing cert (EV recommended) and Apple Developer ID for macOS with notarization.
- Keep PFX and `.env` out of version control (already ignored).
