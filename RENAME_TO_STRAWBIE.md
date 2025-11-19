# 🍓 How to Fix App Name Display to "Strawbie"

The app display name might still show "DAOmates" due to Xcode caching. Follow these steps:

## ✅ Step 1: Clean Build & Delete App

### In Xcode:
```
1. Product → Clean Build Folder (⌘ + Shift + K)
2. Stop the app if running (⌘ + .)
3. In the Simulator: Long press the DAOmates app icon → Delete App
4. Or in Simulator menu: Device → Erase All Content and Settings
```

## ✅ Step 2: Verify Info.plist

The Info.plist should have these values:
```xml
<key>CFBundleDisplayName</key>
<string>Strawbie</string>

<key>CFBundleName</key>
<string>Strawbie</string>
```

## ✅ Step 3: Rebuild & Install

```
1. Build: ⌘ + B
2. Run: ⌘ + R
```

## ✅ Step 4: Check Home Screen

After reinstalling, you should see:
```
🍓
Strawbie
```

---

## 🔍 If Still Shows "DAOmates"

### Option A: Manual Info.plist Edit (In Xcode)
1. Open `DAOmates/Info.plist` in Xcode
2. Find `Bundle display name` 
3. Change value to `Strawbie`
4. Find `Bundle name`
5. Change value to `Strawbie`
6. Save (⌘ + S)
7. Clean & Rebuild

### Option B: Verify Build Settings
1. Click on `DAOmates` project (top left)
2. Select `DAOmates` target
3. Go to `Build Settings` tab
4. Search for "Product Name"
5. Make sure it says `$(TARGET_NAME)` or `Strawbie`
6. Search for "Display Name"
7. Make sure it says `Strawbie`

---

## 🎯 Expected Result

After these steps:
- ✅ App icon shows "Strawbie" underneath
- ✅ App switcher shows "Strawbie"
- ✅ Settings shows "Strawbie"
- ✅ No more "DAOmates" anywhere

---

## 💡 Why This Happens

iOS caches app metadata (name, icon) in the Simulator/Device. Changing the bundle name in code doesn't always update the cache. You need to:
1. Delete the old app
2. Clean Xcode build cache  
3. Reinstall fresh

This ensures iOS reads the new Info.plist values.

