# self-sign-electron-poc

An Electron application with React and TypeScript

## Recommended IDE Setup

- [VSCode](https://code.visualstudio.com/) + [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint) + [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)

## Project Setup

### Install

```bash
$ npm install
```

### Development

```bash
$ npm run dev
```

### Build

```bash
# For windows
$ npm run build:win

# For macOS
$ npm run build:mac

# For Linux
$ npm run build:linux
```

## Code signing (self-signed for testing)

1) Generate a PFX via our script (Admin): `scripts/shell/create-self-signed-cert.ps1`
   - Outputs in `scripts/output/`: `csc_link_b64.txt`, `csc_key_password.txt`, `env.txt` (ready for repo root)
2) Create `.env` in project root:
   ```
   CSC_LINK=<Base64 from csc_link_b64.txt>
   CSC_KEY_PASSWORD=<from csc_key_password.txt>
   ```
3) Build/sign: `npm run build:win`
4) Verify: `Get-AuthenticodeSignature .\release\<version>\self-sign-electron-poc-<version>-setup.exe`

Notes:
- Self-signed is test-only; SmartScreen will still show “Unknown publisher”.
- See `docs/electron-codesign-guide.md` and `docs/codesign-walkthrough.md` for full context.
