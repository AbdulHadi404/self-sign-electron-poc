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

## Code Signing (Self-signed for testing)

1. Create a self-signed PFX certificate using PowerShell (see `docs/electron-codesign-guide.md`). You can use `scripts/shell/create-self-signed-cert.ps1` which outputs:
   - `scripts/output/csc_link_b64.txt` (Base64 for CSC_LINK/CSC_LINK_B64)
   - `scripts/output/csc_key_password.txt` (the PFX password)
2. Add a `.env` file in the project root with:
   ```
   CSC_LINK=${BASE64_FROM_csc_link_b64.txt}
   CSC_KEY_PASSWORD=${PASSWORD_FROM_csc_key_password.txt}
   ```
3. Run `npm run build:win` on Windows. The script loads the `.env` values and signs the binaries via electron-builder.
4. Verify the signature with `Get-AuthenticodeSignature .\release\<version>\self-sign-electron-poc.exe`.
