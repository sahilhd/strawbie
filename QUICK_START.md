# 🚀 Quick Start Guide - DAOmates

## 5-Minute Setup

### Step 1: Get Your API Key (2 minutes)
1. Go to https://platform.openai.com/api-keys
2. Sign up or log in
3. Click "Create new secret key"
4. Copy your key (starts with `sk-`)

### Step 2: Configure the App (1 minute)
```bash
# In the DAOmates directory
cp DAOmates/Info.plist.template DAOmates/Info.plist
```

Then edit `DAOmates/Info.plist` and replace:
```xml
<key>OPENAI_API_KEY</key>
<string>YOUR_OPENAI_API_KEY_HERE</string>
```

With your actual key:
```xml
<key>OPENAI_API_KEY</key>
<string>sk-your-actual-key-here</string>
```

### Step 3: Open & Run (2 minutes)
```bash
open DAOmates.xcodeproj
```

1. Select your development team: Project Settings → Signing & Capabilities
2. Choose a simulator or device
3. Press ⌘R to run

That's it! 🎉

## First Launch Experience

1. **Onboarding** (new users only)
   - Swipe through 4 feature screens
   - Or tap "Skip" to go straight to login

2. **Sign Up**
   - Create an account with email and password
   - Optionally add your wallet address
   - Enable Face ID/Touch ID (recommended)

3. **Select Avatar**
   - Choose from 7 crypto personalities
   - Select your birth year
   - Tap "Continue" to start chatting

4. **Chat Away!**
   - Type your crypto questions
   - Get personalized responses
   - Your history is saved automatically

## Key Features

### 🔐 Security
- **Keychain Storage**: Passwords encrypted
- **Biometric Auth**: Face ID / Touch ID
- **Secure API Keys**: Never in code

### 👤 Profile Management
- Tap your initial in top-right corner
- Edit username and wallet address
- View your chat statistics
- Enable/disable biometric auth
- Sign out securely

### 💬 AI Personalities

| Avatar | Focus | Best For |
|--------|-------|----------|
| ABG | NFTs | Trendy takes on digital art |
| Satoshi | Bitcoin | Blockchain fundamentals |
| Luna | DeFi | Yield farming strategies |
| Vitalik | Ethereum | Smart contracts & scaling |
| Nova | NFTs | Art curation & collecting |
| Alpha | Trading | Market analysis & strategies |
| Cosmos | DAOs | Governance & community |

## Common Issues & Solutions

### "No API Key Found"
**Problem**: OpenAI API key not configured
**Solution**: Follow Step 2 above

### "Signing Failed"
**Problem**: No development team selected
**Solution**: Xcode → Project Settings → Signing & Capabilities → Select Team

### "Biometric Not Working"
**Problem**: Testing in simulator
**Solution**: Biometrics only work on real devices. Use email/password for simulator testing.

### "Build Failed"
**Problem**: Missing dependencies or configuration
**Solution**: 
```bash
# Clean build folder
⌘ + Shift + K

# Then rebuild
⌘ + B
```

## Testing Tips

### In Simulator (Free)
- Use email/password authentication
- Test UI and flow
- Biometrics won't work

### On Device (Requires Apple Developer Account)
- Full biometric authentication
- Real-world performance
- Camera/photo permissions

## Production Checklist

When ready to ship:

- [ ] Remove any test accounts
- [ ] Verify API keys are not in code
- [ ] Test on multiple devices
- [ ] Create app screenshots
- [ ] Add app icon (1024x1024)
- [ ] Review Terms and Privacy Policy
- [ ] Set correct bundle identifier
- [ ] Archive and upload to App Store Connect

See [PRODUCTION_SETUP.md](PRODUCTION_SETUP.md) for detailed checklist.

## Directory Structure

```
DAOmates/
├── DAOmates/              # Main app code
│   ├── Models/           # Data structures
│   ├── Views/            # UI screens
│   ├── ViewModels/       # Business logic
│   ├── Services/         # Backend & API
│   └── Utils/            # Helpers
├── README.md             # Project overview
├── PRODUCTION_SETUP.md   # Detailed setup
├── QUICK_START.md        # This file!
└── setup.sh              # Automated setup
```

## Useful Commands

```bash
# Run setup script
./setup.sh

# Open project
open DAOmates.xcodeproj

# Clean build (if issues)
# In Xcode: ⌘ + Shift + K

# Build
# In Xcode: ⌘ + B

# Run
# In Xcode: ⌘ + R

# Test
# In Xcode: ⌘ + U
```

## Environment Variables (Alternative to Info.plist)

You can also set API key as environment variable:

**In Xcode:**
1. Product → Scheme → Edit Scheme
2. Run → Arguments → Environment Variables
3. Add: `OPENAI_API_KEY` = `your-key-here`

**In Terminal:**
```bash
export OPENAI_API_KEY="your-key-here"
```

## Development vs Production

### Development (Current)
- Mock authentication (no backend required)
- Local storage only
- Test with simulator

### Production (Optional Firebase)
1. Create Firebase project
2. Add `GoogleService-Info.plist`
3. Uncomment Firebase code in `FirebaseAuthService.swift`
4. Add Firebase SDK via SPM
5. Initialize in `DAOmatesApp.swift`

See [PRODUCTION_SETUP.md](PRODUCTION_SETUP.md) for Firebase setup.

## Support & Resources

- **Documentation**: See all `.md` files in root
- **Issues**: Check [GitHub Issues](../../issues)
- **Email**: support@daomates.app

## Quick Links

- [Full README](README.md) - Project overview
- [Production Setup](PRODUCTION_SETUP.md) - Complete guide
- [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - What's built
- [OpenAI API Keys](https://platform.openai.com/api-keys)
- [Firebase Console](https://console.firebase.google.com/)
- [App Store Connect](https://appstoreconnect.apple.com/)

---

**Need Help?** Create an issue or email support@daomates.app

**Ready to Ship?** See [PRODUCTION_SETUP.md](PRODUCTION_SETUP.md)

Happy coding! 🎉

