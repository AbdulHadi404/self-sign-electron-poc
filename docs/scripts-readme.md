# Helper Scripts (PowerShell)

Location: `scripts/shell/`

1) `create-self-signed-cert.ps1`
- Creates a self-signed code-signing cert in the Windows cert store.
- Exports PFX and CER into `scripts/output/`.
- Generates a random password, writes it to `scripts/output/csc_key_password.txt`.
- Writes Base64 of the PFX to `scripts/output/csc_link_b64.txt` (for `CSC_LINK`/`CSC_LINK_B64`).
- Run in PowerShell (Admin).

2) `verify-signature.ps1`
- Verifies Authenticode signature for a built installer or exe.
- Usage example:
  ```
  ./verify-signature.ps1 -Path "release/1.0.0/self-sign-electron-poc-1.0.0-setup.exe"
  ```
- Run in PowerShell.

Related docs:
- Full guide: `docs/electron-codesign-guide.md`
- Walkthrough summary: `docs/codesign-walkthrough.md`

