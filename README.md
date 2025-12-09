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

1. Create a self-signed PFX certificate using PowerShell (see `electron-codesign-guide.md` in repo root).
2. Save the PFX somewhere outside the repo and note its password.
3. Add a `.env` file in the project root with:
   ```
   CSC_LINK=C:\path\to\your-app-cert.pfx
   CSC_KEY_PASSWORD=your-password-here
   ```
4. Run `npm run build:win` on Windows. The script loads the `.env` values and signs the binaries via electron-builder.
5. Verify the signature with `Get-AuthenticodeSignature .\release\<version>\self-sign-electron-poc.exe`.
