# 🚀 Quick Firebase Setup (5 Minutes)

Follow these steps to get Firebase Authentication working in DAOmates.

## ⚡ Quick Steps

### 1️⃣ Create Firebase Project (2 min)
1. Go to https://console.firebase.google.com/
2. Click **"Create a project"** → Name it `DAOmates`
3. Disable Analytics → Click **"Create project"**

### 2️⃣ Add iOS App (1 min)
1. Click iOS icon in Firebase Console
2. Enter bundle ID: **`com.sahilhanda.DAOmates`**
3. Download **`GoogleService-Info.plist`** ⬇️
4. **Drag it into Xcode** (DAOmates folder, check "Copy items")

### 3️⃣ Enable Authentication (1 min)
1. In Firebase Console → **Authentication** → **Get Started**
2. Click **Email/Password** → Toggle **Enable** → Save

### 4️⃣ Enable Firestore (1 min)
1. In Firebase Console → **Firestore Database** → **Create database**
2. Select **Production mode** → Choose location (e.g., `us-central1`) → Enable
3. Go to **Rules** tab, paste this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

4. Click **"Publish"**

### 5️⃣ Add Firebase SDK to Xcode (1 min)
1. In Xcode: **File** → **Add Package Dependencies...**
2. Paste: `https://github.com/firebase/firebase-ios-sdk`
3. Select: **FirebaseAuth** and **FirebaseFirestore**
4. Click **Add Package**

## ✅ That's It!

Now:
1. Clean build: **⌘ + Shift + K**
2. Build: **⌘ + B**
3. Run: **⌘ + R**

You should see the signup screen. Create an account and check Firebase Console to see your user!

## 🧪 Test It

```
Email: test@daomates.com
Password: TestPassword123
Username: TestUser
```

Check Firebase Console:
- **Authentication** > **Users** → See your user
- **Firestore** > **Data** → See user document

## ❌ Troubleshooting

**"Module not found"?**
- Make sure you added Firebase packages
- Clean build folder (⌘ + Shift + K)

**"No Firebase App"?**
- Check `GoogleService-Info.plist` is in your project
- Verify it's in **Copy Bundle Resources**

**Build errors?**
- Clear DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Rebuild

---

**Need detailed help?** See `FIREBASE_SETUP.md`

