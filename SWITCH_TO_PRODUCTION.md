# 🔄 Quick Switch: Dev Mode → Production Mode

When you're ready to enable real Firebase authentication and database:

## Step 1: Uncomment Firebase Code (5 min)

### File 1: `DAOmatesApp.swift`
```swift
// Line 9-11: Uncomment Firebase import
import FirebaseCore

// Line 18-21: Uncomment Firebase initialization
init() {
    FirebaseApp.configure()
    print("🔥 Firebase initialized successfully")
}
```

### File 2: `FirebaseAuthService.swift`
```swift
// Line 10-13: Uncomment Firebase imports
import FirebaseAuth
import FirebaseFirestore

// Line 18-21: Uncomment Firebase instances
private let auth = Auth.auth()
private let db = Firestore.firestore()

// Line 24-28: Uncomment auth state listener
auth.addStateDidChangeListener { [weak self] _, user in
    print("🔐 Auth state changed: \(user?.email ?? "no user")")
}

// Then uncomment all the /* MARK: - 🚧 PRODUCTION */ blocks:
// - signUp method (lines ~73-89)
// - signIn method (lines ~122-150)
// - signOut method (lines ~185-192)
// - resetPassword method (lines ~205-212)
// - getCurrentUser method (lines ~228-251)
// - updateProfile method (lines ~258-271)
```

## Step 2: Firebase Setup (5 min)

Follow the quick setup guide:
```bash
open QUICK_FIREBASE_SETUP.md
```

## Step 3: Build & Test

```bash
# Clean build
⌘ + Shift + K

# Build
⌘ + B

# Run
⌘ + R
```

---

## Quick Checklist

- [ ] Uncomment Firebase imports in `DAOmatesApp.swift`
- [ ] Uncomment Firebase imports in `FirebaseAuthService.swift`
- [ ] Uncomment all production code blocks
- [ ] Complete Firebase setup (console, packages, plist)
- [ ] Test signup/login with real Firebase

---

**Time**: ~10 minutes total
**Result**: Full production authentication with Firestore database!

