# Complete Self-Signed Certificate Guide for Electron + electron-vite

## ⚠️ Important Disclaimer
**Self-signed certificates are ONLY for testing/POC purposes.** They will still show security warnings to users. For production:
- **Windows**: You need an EV Code Signing Certificate from a Certificate Authority
- **macOS**: You need an Apple Developer Program membership ($99/year)

---

## Part A: Understanding the Landscape

### What is Code Signing?
Code signing certifies that your app was created by you and hasn't been tampered with. Without it:
- **Windows**: Users see "Unknown Publisher" and SmartScreen warnings
- **macOS**: Gatekeeper prevents the app from running unless users manually bypass security

### Your electron-vite Setup
Since you're using electron-vite, your project structure likely looks like:
```
your-app/
├── src/
│   ├── main/
│   ├── preload/
│   └── renderer/
├── electron.vite.config.js
├── package.json
└── electron-builder.yml (or config in package.json)
```

electron-vite uses **electron-builder** under the hood for packaging, which handles code signing.

---

## Part B: Windows Self-Signed Certificate (Testing Only)

### Step 1: Generate Self-Signed Certificate

**Method 1: Using PowerShell (Recommended for Testing)**

Open PowerShell **as Administrator** and run:

```powershell
# Create the certificate
$cert = New-SelfSignedCertificate `
  -Type Custom `
  -Subject "CN=Your Company Name, O=Your Company Name, C=US" `
  -KeyUsage DigitalSignature `
  -FriendlyName "Your App Name" `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") `
  -KeyExportPolicy Exportable `
  -KeySpec Signature `
  -KeyLength 2048 `
  -HashAlgorithm SHA256 `
  -NotAfter (Get-Date).AddYears(5)
```

**Important Fields:**
- `CN=Your Company Name` - This is your Publisher Name (will appear in Windows)
- `O=Your Company Name` - Organization name
- `C=US` - Country code (use your country)

### Step 2: Export Certificate to PFX

```powershell
# Set password for the PFX file (or leave empty for no password)
$password = ConvertTo-SecureString -String "your-password-here" -Force -AsPlainText

# Export to PFX
$certPath = "$env:USERPROFILE\Desktop\your-app-cert.pfx"
Export-PfxCertificate `
  -Cert $cert `
  -FilePath $certPath `
  -Password $password
```

This creates `your-app-cert.pfx` on your Desktop.

**Alternative (No Password):**
```powershell
Export-PfxCertificate `
  -Cert $cert `
  -FilePath "$env:USERPROFILE\Desktop\your-app-cert.pfx" `
  -Password (ConvertTo-SecureString -String "" -Force -AsPlainText)
```

### Step 3: Install Certificate (Required for Testing)

For the signed app to run on your Windows machine, install the certificate:

```powershell
# Import to Trusted Root (requires Admin)
Import-Certificate `
  -FilePath "$env:USERPROFILE\Desktop\your-app-cert.pfx" `
  -CertStoreLocation Cert:\LocalMachine\Root
```

Or manually:
1. Double-click the `.pfx` file
2. Choose "Local Machine" → Next
3. Keep file path → Next
4. Enter password (if set) → Next
5. Select "Place all certificates in the following store"
6. Browse → Select "Trusted Root Certification Authorities"
7. Finish

---

## Part C: Configure electron-builder

### Option 1: Environment Variables (Recommended for Security)

Create a `.env` file in your project root:

```bash
# .env
CSC_LINK=/path/to/your-app-cert.pfx
CSC_KEY_PASSWORD=your-password-here
```

**Add to `.gitignore`:**
```
.env
*.pfx
*.p12
```

### Option 2: Direct Configuration in package.json

```json
{
  "name": "your-app",
  "version": "1.0.0",
  "main": "out/main/index.js",
  "build": {
    "appId": "com.yourcompany.yourapp",
    "productName": "Your App Name",
    "directories": {
      "output": "release/${version}"
    },
    "files": [
      "out/**/*"
    ],
    "win": {
      "target": ["nsis"],
      "icon": "resources/icon.ico",
      "publisherName": "Your Company Name",
      "certificateFile": "./your-app-cert.pfx",
      "certificatePassword": "your-password-here",
      "signingHashAlgorithms": ["sha256"],
      "signAndEditExecutable": true
    },
    "nsis": {
      "oneClick": false,
      "perMachine": false,
      "allowToChangeInstallationDirectory": true,
      "deleteAppDataOnUninstall": false
    }
  }
}
```

### Option 3: Separate electron-builder.yml

Create `electron-builder.yml`:

```yaml
appId: com.yourcompany.yourapp
productName: Your App Name
directories:
  output: release/${version}
files:
  - out/**/*

win:
  target:
    - target: nsis
      arch:
        - x64
  icon: resources/icon.ico
  publisherName: Your Company Name
  certificateFile: ./your-app-cert.pfx
  certificatePassword: env:CSC_KEY_PASSWORD
  signingHashAlgorithms:
    - sha256
  signAndEditExecutable: true

nsis:
  oneClick: false
  perMachine: false
  allowToChangeInstallationDirectory: true
  deleteAppDataOnUninstall: false
```

---

## Part D: Update package.json Scripts

```json
{
  "scripts": {
    "dev": "electron-vite dev",
    "build": "electron-vite build",
    "preview": "electron-vite preview",
    "build:win": "npm run build && electron-builder --win --x64",
    "build:mac": "npm run build && electron-builder --mac",
    "build:linux": "npm run build && electron-builder --linux"
  }
}
```

If using `.env` file, install `dotenv-cli`:
```bash
npm install -D dotenv-cli
```

Update scripts:
```json
{
  "scripts": {
    "build:win": "dotenv -- electron-vite build && electron-builder --win --x64"
  }
}
```

---

## Part E: Verify electron.vite.config.js

Ensure your config outputs to the correct directory:

```javascript
// electron.vite.config.js
import { defineConfig } from 'electron-vite'
import { resolve } from 'path'

export default defineConfig({
  main: {
    build: {
      outDir: 'out/main'
    }
  },
  preload: {
    build: {
      outDir: 'out/preload'
    }
  },
  renderer: {
    build: {
      outDir: 'out/renderer'
    }
  }
})
```

---

## Part F: Build and Sign

### Build Process

1. **Clean previous builds:**
```bash
rm -rf out release
```

2. **Build the app:**
```bash
npm run build:win
```

This will:
- Run `electron-vite build` to bundle your code into `out/`
- Run `electron-builder` which will:
  - Package the app
  - Sign all executables with your certificate
  - Create installer in `release/` folder

### Expected Output

```
release/
├── 1.0.0/
│   ├── Your-App-Name-Setup-1.0.0.exe (signed installer)
│   └── win-unpacked/ (unpacked app files, also signed)
```

---

## Part G: Verify Signing

### Windows Verification

**Method 1: Using File Properties**
1. Right-click the `.exe` file
2. Select "Properties"
3. Go to "Digital Signatures" tab
4. You should see your certificate listed

**Method 2: Using PowerShell**
```powershell
Get-AuthenticodeSignature "path\to\your\app.exe"
```

**Method 3: Using SignTool (if Windows SDK installed)**
```bash
signtool verify /pa "path\to\your\app.exe"
```

---

## Part H: Testing the Signed App

1. **Install the certificate on test machines** (as shown in Step 3)
2. **Run the installer**
3. **Expected behavior:**
   - Self-signed: Still shows warning but shows YOUR publisher name instead of "Unknown"
   - The app will install and run

---

## Part I: Troubleshooting

### Issue: "SignTool Error: No certificates were found that met all the given criteria"

**Solutions:**
- Ensure certificate is installed in correct store
- Check `certificateSubjectName` matches the CN in your certificate
- Verify password is correct

### Issue: "The app is damaged and can't be opened" (macOS)

Self-signed certificates don't work on macOS for distribution. You must:
- Join Apple Developer Program
- Use a valid Developer ID certificate

### Issue: Build succeeds but app isn't signed

**Check:**
- Certificate path is correct
- Password is correct (if using one)
- Certificate hasn't expired
- You're running on Windows (can't sign Windows apps on Mac/Linux without special setup)

### Issue: "Access Denied" errors

- Run PowerShell as Administrator
- Check file permissions on certificate file

---

## Part J: Production Considerations

### For Production Release

**Windows:**
1. Purchase an EV Code Signing Certificate from:
   - DigiCert
   - Sectigo
   - SSL.com
   - GlobalSign

2. **Modern requirement (June 2023+):** EV certificates must be on hardware tokens (USB drives)

3. **Alternative:** Azure Trusted Signing (cloud-based, cheapest option)
   - Available for US/Canada organizations (3+ years history)
   - Removes SmartScreen warnings immediately

**macOS:**
1. Join Apple Developer Program ($99/year)
2. Download Developer ID Certificate
3. Configure notarization (required by macOS Catalina+)

---

## Part K: CI/CD Considerations

### For GitHub Actions / CI Servers

**Secure Certificate Storage:**

1. **Encode certificate to base64:**
```bash
base64 -i your-app-cert.pfx > cert-base64.txt
```

2. **Add as GitHub Secret:**
   - Go to repo Settings → Secrets
   - Add `CSC_LINK` with base64 content
   - Add `CSC_KEY_PASSWORD` with password

3. **In workflow:**
```yaml
- name: Build Windows
  env:
    CSC_LINK: ${{ secrets.CSC_LINK }}
    CSC_KEY_PASSWORD: ${{ secrets.CSC_KEY_PASSWORD }}
  run: npm run build:win
```

**Important:** Windows environment variables are limited to 8192 characters. If your base64 cert exceeds this, use file upload approach or cloud signing.

---

## Part L: Key Configuration Fields Explained

### Critical electron-builder Fields

```yaml
appId: "com.yourcompany.yourapp"
# Unique identifier, reverse domain notation

productName: "Your App Name"
# Display name shown to users

publisherName: "Your Company Name"
# Must match certificate CN field EXACTLY

certificateSubjectName: "Your Company Name"
# Alternative to certificateFile, uses cert from Windows cert store

signingHashAlgorithms: ["sha256"]
# Use SHA256 (SHA1 deprecated, breaks Windows 10 auto-update)

signAndEditExecutable: true
# Sign the executable after building
```

---

## Summary Checklist

### Initial Setup (One-time)
- [ ] Generate self-signed certificate with PowerShell
- [ ] Export to PFX file with password
- [ ] Install certificate on your dev machine
- [ ] Create `.env` file with certificate path and password
- [ ] Add `.env` and `*.pfx` to `.gitignore`

### Configuration
- [ ] Configure `electron-builder` in `package.json` or `electron-builder.yml`
- [ ] Verify `electron.vite.config.js` outputs to correct directory
- [ ] Update build scripts in `package.json`

### Building
- [ ] Run `npm run build:win`
- [ ] Verify signature on output executable
- [ ] Test installation on clean Windows machine

### Remember
- Self-signed = Testing only
- Production = Buy real certificate
- macOS = Requires Apple Developer Program
- Keep certificates secure and out of version control

---

## Additional Resources

**Official Documentation:**
- [Electron Code Signing](https://www.electronjs.org/docs/latest/tutorial/code-signing)
- [electron-builder Configuration](https://www.electron.build/configuration/configuration)
- [electron-vite Guide](https://electron-vite.org/guide/)

**Certificate Authorities (Production):**
- [DigiCert](https://www.digicert.com/signing/code-signing-certificates)
- [SSL.com](https://www.ssl.com/certificates/ev-code-signing/)
- [Sectigo](https://sectigo.com/ssl-certificates-tls/code-signing)

**Cloud Signing (Modern Alternative):**
- [Azure Trusted Signing](https://azure.microsoft.com/en-us/products/trusted-signing)
- [DigiCert KeyLocker](https://docs.digicert.com/en/digicert-keylocker.html)
