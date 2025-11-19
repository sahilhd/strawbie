# 🛠️ Development Mode Guide

## Current Status: **DEV MODE** ✅

Your app is now running in **development mode** with mock authentication. You can freely work on UI/functionality without Firebase setup!

---

## 🎯 What's Different in Dev Mode

### ✅ What Works
- ✅ **Full UI/UX development** - all views and navigation
- ✅ **Mock authentication** - signup/login simulated
- ✅ **No Firebase required** - builds and runs immediately
- ✅ **Quick iteration** - focus on design and functionality
- ✅ **ABG chat** - full companion experience
- ✅ **All visual features** - animations, transitions, etc.

### ⚠️ What's Simulated
- 🔄 Authentication (users aren't actually created)
- 🔄 Database storage (data doesn't persist)
- 🔄 Password reset (just logs to console)
- 🔄 User sessions (resets on app restart)

---

## 🚀 Quick Start (Dev Mode)

```bash
# Just open Xcode and run!
⌘ + R
```

That's it! No Firebase setup needed.

---

## 🔄 Switching Between Modes

### 🛠️ Dev Mode → 🚧 Production Mode

When you're ready to productionize, search for `🚧 PRODUCTION` markers in:

1. **`DAOmatesApp.swift`**
   ```swift
   // Uncomment these lines:
   import FirebaseCore
   FirebaseApp.configure()
   ```

2. **`FirebaseAuthService.swift`**
   ```swift
   // Uncomment these imports:
   import FirebaseAuth
   import FirebaseFirestore
   
   // Uncomment Firebase code blocks marked with:
   // MARK: - 🚧 PRODUCTION
   ```

3. **Follow Firebase setup**
   ```bash
   open QUICK_FIREBASE_SETUP.md
   ```

### 🚧 Production Mode → 🛠️ Dev Mode

If you want to go back to dev mode:
1. Comment out Firebase imports
2. Comment out Firebase code
3. The mock code will take over automatically

---

## 📝 Code Markers

Look for these markers in the code:

```swift
// MARK: - 🚧 PRODUCTION CODE COMMENTED FOR DEV
// This section has production Firebase code

// MARK: - 🚧 PRODUCTION: Firebase Configuration
// Uncomment when ready to use Firebase

// MARK: - 🛠️ MOCK Authentication (For Development)
// This is the active mock code for dev
```

---

## 🧪 Testing in Dev Mode

### Test Signup Flow
```
Username: TestUser
Email: test@daomates.com
Password: TestPassword123
```

The user will be "created" (mock) and you'll be logged in.

### Test Login Flow
Use any valid email/password format:
```
Email: anything@example.com
Password: 12345678
```

### Test Password Reset
Enter any valid email - it will "send" a reset email (logged to console).

---

## 📱 What to Focus On

In dev mode, you should work on:
- ✅ UI/UX design and polish
- ✅ View layouts and responsiveness
- ✅ Animations and transitions
- ✅ Chat functionality and AI responses
- ✅ Navigation flow
- ✅ Color schemes and typography
- ✅ User interactions and gestures
- ✅ Avatar customization
- ✅ Settings and profile views

---

## 🎨 Current Dev Setup

### Files in Dev Mode
```
DAOmates/
├── DAOmatesApp.swift              [DEV MODE] 🛠️
├── Services/
│   └── FirebaseAuthService.swift [MOCK AUTH] 🛠️
├── ViewModels/
│   └── AuthViewModel.swift       [Works with mock] ✅
└── Views/                         [All functional] ✅
```

### Console Output
You'll see messages like:
```
🛠️ DEV MODE: Running without Firebase for UI development
🛠️ DEV MODE: Using mock authentication
✅ Mock user created: test@example.com
ℹ️ Mock: No current user (login required)
```

---

## 💡 Pro Tips

### 1. Auto-Login for Faster Testing
If you want to skip login during development, modify `AuthViewModel.swift`:

```swift
init() {
    // Add this for auto-login in dev:
    self.isAuthenticated = true
    self.currentUser = User(
        id: "dev-user",
        username: "DevUser",
        email: "dev@daomates.com"
    )
}
```

### 2. Skip Onboarding
Set `showOnboarding = false` in `AuthViewModel`:

```swift
init() {
    self.showOnboarding = false  // Skip onboarding
}
```

### 3. Quick View Testing
Comment out the auth check in `ContentView.swift` to directly show any view:

```swift
var body: some View {
    // Directly show the view you're working on:
    CleanABGHomeView()
    
    // Or:
    // ABGChatView(avatar: Avatar.sample)
}
```

---

## 🔍 Debugging

### Check Console for Mock Messages
All mock operations log to console with `🛠️` emoji:
- User signup
- Login attempts
- Password resets
- Profile updates

### Test Different User States
Modify `getCurrentUser()` to return:
- `nil` - Test logged out state
- `User(...)` - Test logged in state

---

## 📦 When to Switch to Production

Switch to production mode when:
- ✅ UI/UX is finalized
- ✅ All views are complete
- ✅ Navigation flow is solid
- ✅ Ready to test with real data
- ✅ Preparing for TestFlight or App Store

---

## ⚡ Quick Commands

```bash
# Clean and rebuild
⌘ + Shift + K
⌘ + B

# Run in simulator
⌘ + R

# Clear all app data (if needed)
./clear_app_data.sh

# View dev mode docs
open DEV_MODE_GUIDE.md

# View production setup docs
open QUICK_FIREBASE_SETUP.md
```

---

## 🎯 Summary

**Current Status**: 🛠️ **DEV MODE ACTIVE**

- ✅ No Firebase setup required
- ✅ Mock authentication works
- ✅ Focus on UI/UX development
- ✅ Quick iteration and testing
- 🔄 When ready, switch to production mode

**Happy coding!** 🚀

