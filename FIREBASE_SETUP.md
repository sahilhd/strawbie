# Firebase Setup Guide for DAOmates

This guide will walk you through setting up Firebase Authentication and Firestore database for DAOmates.

## 🔥 Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Name your project: `DAOmates` (or your preferred name)
4. **Disable Google Analytics** (optional, you can enable it later)
5. Click **"Create project"**

## 📱 Step 2: Add iOS App to Firebase

1. In your Firebase project, click the **iOS icon** (⚙️ Settings > Your apps)
2. Register your app with:
   - **iOS bundle ID**: `com.sahilhanda.DAOmates` (must match your Xcode project)
   - **App nickname**: `DAOmates` (optional)
   - **App Store ID**: (leave blank for now)
3. Click **"Register app"**
4. **Download `GoogleService-Info.plist`** (CRITICAL - you'll need this file!)
5. Click **Continue** through the remaining steps

## 📦 Step 3: Add GoogleService-Info.plist to Xcode

1. Open your `GoogleService-Info.plist` file (from download)
2. Drag and drop it into Xcode:
   - Drop it into the `DAOmates/` folder (same level as `DAOmatesApp.swift`)
   - ✅ Check **"Copy items if needed"**
   - ✅ Select **"DAOmates" target**
   - Click **"Finish"**

3. **Verify it's added correctly**:
   - In Xcode, select the `DAOmates` target
   - Go to **Build Phases** > **Copy Bundle Resources**
   - You should see `GoogleService-Info.plist` listed there

## 🔐 Step 4: Enable Authentication in Firebase

1. In Firebase Console, go to **Build** > **Authentication**
2. Click **"Get started"**
3. Go to **Sign-in method** tab
4. Click on **"Email/Password"**
5. ✅ **Enable** Email/Password authentication
6. Click **"Save"**

## 💾 Step 5: Enable Firestore Database

1. In Firebase Console, go to **Build** > **Firestore Database**
2. Click **"Create database"**
3. Choose **"Start in production mode"** (we'll configure security rules next)
4. Select a Firestore location (choose closest to your users):
   - `us-central1` (Iowa)
   - `us-west1` (Oregon)
   - `europe-west1` (Belgium)
   - `asia-southeast1` (Singapore)
5. Click **"Enable"**

## 🔒 Step 6: Configure Firestore Security Rules

1. In Firestore Database, go to the **"Rules"** tab
2. Replace the default rules with the following:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Chats collection (if you add it later)
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

3. Click **"Publish"**

## 📚 Step 7: Add Firebase SDK to Xcode

1. Open your Xcode project
2. Go to **File** > **Add Package Dependencies...**
3. In the search bar, paste:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
4. Click **"Add Package"**
5. When the package options appear, select:
   - ✅ **FirebaseAuth**
   - ✅ **FirebaseFirestore**
6. Click **"Add Package"**

### Alternative: Using Package.swift (if needed)

If the above doesn't work, add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.20.0")
],
targets: [
    .target(
        name: "DAOmates",
        dependencies: [
            .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
            .product(name: "FirebaseFirestore", package: "firebase-ios-sdk")
        ]
    )
]
```

## ✅ Step 8: Verify Setup

1. **Clean Build Folder**: In Xcode, press **⌘ + Shift + K**
2. **Build Project**: Press **⌘ + B**
3. If everything builds successfully, you should see in the console:
   ```
   🔥 Firebase initialized successfully
   ```

## 🧪 Step 9: Test Authentication

1. Run the app in the simulator
2. Try to sign up with:
   - Email: `test@daomates.com`
   - Password: `TestPassword123`
   - Username: `TestUser`
3. Check the Firebase Console:
   - Go to **Authentication** > **Users** - you should see your test user
   - Go to **Firestore Database** > **Data** - you should see a `users` collection with your user document

## 🎯 Database Structure

Your Firestore database will have this structure:

```
users (collection)
  └── {userId} (document - Firebase Auth UID)
      ├── id: String
      ├── username: String
      ├── email: String
      ├── walletAddress: String (optional)
      ├── createdAt: Timestamp
      └── lastLogin: Timestamp
```

## 🔧 Troubleshooting

### ❌ "No Firebase App '[DEFAULT]' has been created"
- Make sure `GoogleService-Info.plist` is in your project
- Verify `FirebaseApp.configure()` is called in `DAOmatesApp.swift`

### ❌ "Module 'FirebaseAuth' not found"
- Make sure you added Firebase packages via SPM
- Clean build folder (⌘ + Shift + K) and rebuild

### ❌ "Permission denied" errors in Firestore
- Check your Firestore security rules
- Make sure the user is authenticated before accessing data

### ❌ Build errors after adding Firebase
- Update to latest Xcode version
- Make sure deployment target is iOS 15.0+
- Clean DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`

## 🚀 Next Steps

Once setup is complete:
1. ✅ Users can sign up and create accounts
2. ✅ Data is stored securely in Firestore
3. ✅ No auto-login - users must authenticate
4. ✅ Professional authentication flow

## 📱 Testing Checklist

- [ ] Sign up new user
- [ ] Sign in with existing user
- [ ] Sign out
- [ ] Password reset email
- [ ] Profile updates sync to Firestore
- [ ] Multiple users can sign up
- [ ] Data persists after app restart

## 🛡️ Security Best Practices

1. **Never commit** `GoogleService-Info.plist` to public repos
2. Always use Firestore security rules
3. Enable App Check for production
4. Use environment-specific Firebase projects (dev/staging/prod)
5. Enable multi-factor authentication for production

---

**Need help?** Check the [Firebase Documentation](https://firebase.google.com/docs/ios/setup) or Firebase Console support.

