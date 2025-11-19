# Strawbie

A production-ready iOS app featuring ABG, your AI-powered fashion & crypto companion. Chat with your stylish bestie who loves beauty, fashion, and smart investments.

![DAOmates](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## 🌟 Features

### Authentication & Security
- 🔐 Secure authentication with Keychain storage
- 👤 Face ID / Touch ID biometric authentication
- 🔑 Password reset functionality
- 🛡️ Industry-standard encryption
- 🔒 Privacy-focused design

### User Experience
- 🎨 Beautiful, modern UI
- 🚀 Smooth onboarding flow
- 💬 Multiple AI personalities with unique expertise
- 📱 Responsive design for all iPhone sizes
- 🎭 Personalized chat history
- ⚙️ Profile management

### AI Companions
- **ABG**: Fashion-forward crypto bestie (NFT focus)
- **Satoshi**: The legendary Bitcoin creator (Blockchain focus)
- **Luna**: DeFi Protocol Expert (DeFi focus)
- **Vitalik**: Ethereum Visionary (Smart Contracts)
- **Nova**: NFT Curator & Artist
- **Alpha**: Trading Strategist
- **Cosmos**: DAO Governance Specialist

## 📱 Screenshots

<!-- Add your screenshots here -->

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later
- Apple Developer Account (for device testing)
- **Firebase Account** (free)
- OpenAI API Key

### ⚡ Quick Setup (5 minutes)

**Important**: DAOmates now uses **Firebase Authentication** and **Firestore Database** for secure user management. Follow these steps:

1. **See the Quick Guide**: Open `QUICK_FIREBASE_SETUP.md` for a 5-minute setup
2. **Or detailed guide**: Open `FIREBASE_SETUP.md` for step-by-step instructions

Without Firebase setup, the app will show build errors. Don't worry - it's easy!

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/daomates.git
cd daomates
```

2. Configure API Keys:
```bash
# Copy the template
cp DAOmates/Info.plist.template DAOmates/Info.plist

# Edit Info.plist and add your OpenAI API key
# Or set as environment variable: OPENAI_API_KEY
```

3. Open the project:
```bash
open DAOmates.xcodeproj
```

4. Select your development team in Xcode:
   - Open project settings
   - Select "DAOmates" target
   - Go to "Signing & Capabilities"
   - Choose your team

5. Build and run (⌘R)

### Configuration

See [PRODUCTION_SETUP.md](PRODUCTION_SETUP.md) for detailed configuration instructions including:
- API key management
- Firebase setup (optional)
- App Store preparation
- Privacy permissions
- And more

## 🏗️ Architecture

The app follows MVVM architecture with clean separation of concerns:

```
DAOmates/
├── Models/           # Data models
├── Views/            # SwiftUI views
│   ├── Auth/        # Authentication screens
│   ├── Chat/        # Chat interfaces
│   ├── Main/        # Main app screens
│   ├── Settings/    # Settings & profile
│   └── Legal/       # Terms & Privacy
├── ViewModels/       # Business logic
├── Services/         # API & backend services
└── Utils/           # Helpers & extensions
```

## 🔧 Tech Stack

- **Language**: Swift 5.9
- **UI Framework**: SwiftUI
- **Architecture**: MVVM
- **Authentication**: Keychain + Biometric (Face ID/Touch ID)
- **AI**: OpenAI GPT-4
- **Storage**: Keychain (secure), UserDefaults (preferences)
- **Optional**: Firebase (Auth, Firestore)

## 🔐 Security

- Passwords never stored in plain text
- API keys managed securely
- Biometric authentication support
- Keychain for sensitive data
- Network requests over HTTPS only
- Input validation and sanitization

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

DAOmates is for educational and informational purposes only. The information provided is not financial, investment, or legal advice. Always conduct your own research (DYOR) and consult with qualified professionals before making any investment decisions.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📞 Support

- Email: support@daomates.app
- Issues: [GitHub Issues](https://github.com/yourusername/daomates/issues)

## 🗺️ Roadmap

- [ ] Firebase integration for cloud sync
- [ ] Push notifications for market updates
- [ ] Advanced chat features (voice messages, images)
- [ ] Real-time crypto price integration
- [ ] Community features (share chats, tips)
- [ ] Wallet integration (view balances, transactions)
- [ ] Premium features (unlimited chats, priority responses)
- [ ] Multi-language support

## 👏 Acknowledgments

- OpenAI for GPT-4 API
- Apple for SwiftUI framework
- Crypto community for inspiration

## 📊 Status

- ✅ Beta Ready
- 🚧 App Store Submission: Pending
- 🎯 Current Version: 1.0.0

---

Made with ❤️ for the crypto community
