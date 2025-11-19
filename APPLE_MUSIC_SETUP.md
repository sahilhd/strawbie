# 🍎 Apple Music Integration Setup Guide

## Overview
This guide will help you integrate Apple Music into your app using MusicKit, allowing users to play REAL music from the Apple Music catalog.

---

## ✅ What's Already Done

1. **AppleMusicService.swift** - Complete Apple Music wrapper
2. **MusicService.swift** - Updated to prioritize Apple Music
3. **Authorization flow** - Automatic permission requests
4. **Search functionality** - Search Apple Music catalog
5. **Playback integration** - Uses SystemMusicPlayer

---

## 📋 Setup Steps

### Step 1: Add MusicKit Framework

1. Open Xcode
2. Select your project in the navigator
3. Select your target (DAOmates)
4. Go to **"Frameworks, Libraries, and Embedded Content"**
5. Click the **"+"** button
6. Search for **"MusicKit"**
7. Add **"MusicKit.framework"**
8. Set to **"Do Not Embed"** (it's a system framework)

### Step 2: Update Info.plist

Add the following key to your `Info.plist`:

```xml
<key>NSAppleMusicUsageDescription</key>
<string>We need access to Apple Music to play your favorite songs</string>
```

**How to add:**
1. Open `Info.plist` in Xcode
2. Right-click → Add Row
3. Key: `Privacy - Media Library Usage Description`
4. Value: `We need access to Apple Music to play your favorite songs`

### Step 3: Enable Apple Music Capability

1. Select your project in Xcode
2. Select your target
3. Go to **"Signing & Capabilities"** tab
4. Click **"+ Capability"**
5. Search for **"Apple Music"**
6. Add it

**Alternative (Manual):**
Add to your entitlements file:
```xml
<key>com.apple.developer.music-catalog-playback</key>
<true/>
```

### Step 4: Configure App ID (Apple Developer Portal)

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Select your App ID
4. Enable **"MusicKit"** capability
5. Save changes
6. Regenerate provisioning profiles if needed

---

## 🎵 How It Works

### Priority System

When user requests music, the app tries in order:

1. **Apple Music** (if iOS 15+)
   - Searches Apple Music catalog
   - Plays REAL songs
   - Requires user authorization
   
2. **YouTube** (fallback)
   - Searches YouTube Data API
   - Returns empty (by design)
   
3. **Sample Tracks** (final fallback)
   - Plays royalty-free sample music
   - Always works

### Authorization Flow

```swift
// First time user requests music:
1. App checks Apple Music authorization
2. If not authorized, shows system permission dialog
3. User grants/denies permission
4. If granted, searches and plays music
5. If denied, falls back to sample tracks
```

### Search Examples

User says: **"play some lofi music"**

```
🎵 searchAndPlay called with query: "lofi"
🍎 Attempting Apple Music search for: "lofi"
⚠️ Apple Music not authorized, requesting permission...
[System shows permission dialog]
✅ Found 10 tracks from Apple Music
🎵 Using Apple Music for playback
▶️ Apple Music playback started with 10 songs
```

---

## 🧪 Testing

### Test 1: First Time Authorization

1. Build and run app
2. Say: **"play some lofi music"**
3. System dialog appears: "Allow DAOmates to access Apple Music?"
4. Tap **"OK"**
5. Music starts playing (REAL Apple Music tracks!)

### Test 2: Different Genres

Try these commands:
- "play jazz"
- "play rock music"
- "play study beats"
- "play sleep sounds"
- "play hip hop"

Each searches Apple Music and plays real songs!

### Test 3: Check Console Logs

Look for:
```
🍎 Attempting Apple Music search for: lofi
🎵 Apple Music authorization status: authorized
✅ Found 10 tracks from Apple Music
▶️ Apple Music playback started
```

---

## 📱 User Requirements

### For Apple Music to Work:

1. **iOS 15.0 or later** (MusicKit requirement)
2. **Apple Music subscription** (active subscription required)
3. **Signed in to Apple ID** (in Settings → Music)
4. **Internet connection** (for streaming)

### If User Doesn't Have Apple Music:

- App automatically falls back to sample tracks
- No errors shown to user
- Seamless experience

---

## 🎮 Music Controls

### Available Controls:

```swift
// Play/Pause
AppleMusicService.shared.play()
AppleMusicService.shared.pause()

// Skip tracks
AppleMusicService.shared.skipToNext()
AppleMusicService.shared.skipToPrevious()

// Stop
AppleMusicService.shared.stop()
```

### System Music Player

Apple Music uses the **SystemMusicPlayer**, which means:
- ✅ Integrates with iOS Control Center
- ✅ Shows on Lock Screen
- ✅ Works with AirPlay
- ✅ Supports Bluetooth controls
- ✅ Respects system volume

---

## 🔧 Troubleshooting

### "Not authorized" Error

**Problem:** App can't access Apple Music
**Solution:**
1. Go to Settings → Privacy & Security → Media & Apple Music
2. Find your app
3. Enable access

### "No results found" Error

**Problem:** Search returns empty
**Solutions:**
- Check internet connection
- Verify Apple Music subscription is active
- Try different search terms
- Check if Apple Music service is down

### Music Doesn't Play

**Problem:** Search works but no audio
**Solutions:**
1. Check device volume
2. Check silent switch
3. Verify Apple Music subscription
4. Sign out and back into Apple Music
5. Restart app

### Falls Back to Sample Tracks

**Problem:** Always uses sample tracks instead of Apple Music
**Reasons:**
- User denied permission
- No Apple Music subscription
- iOS version < 15.0
- Apple Music not configured

---

## 💡 Advanced Features

### Genre Mapping

The app intelligently maps user requests to Apple Music searches:

```swift
"lofi" → "lofi hip hop study beats"
"jazz" → "smooth jazz instrumental"
"study" → "lofi hip hop study beats"
"sleep" → "sleep relaxing music"
"rock" → "classic rock"
```

### Playlist Management

```swift
// Get current playlist
let playlist = MusicService.shared.playlist

// Get current track
let track = MusicService.shared.currentTrack

// Check if playing
let isPlaying = MusicService.shared.isPlaying
```

---

## 📊 Comparison: Apple Music vs Sample Tracks

| Feature | Apple Music | Sample Tracks |
|---------|-------------|---------------|
| Real songs | ✅ Yes | ❌ No |
| Requires subscription | ✅ Yes | ❌ No |
| Requires authorization | ✅ Yes | ❌ No |
| Millions of songs | ✅ Yes | ❌ 6 tracks |
| Lock screen controls | ✅ Yes | ⚠️ Limited |
| Offline playback | ✅ Yes (if downloaded) | ❌ No |
| High quality audio | ✅ Yes | ⚠️ Varies |

---

## 🚀 Next Steps

1. **Complete Setup Steps 1-4** above
2. **Build and run** the app
3. **Test authorization** flow
4. **Try different music requests**
5. **Verify playback** works

---

## 📝 Code Reference

### Search and Play Music

```swift
// In your chat handler
if let musicIntent = MusicService.detectMusicIntent(in: message) {
    Task {
        await MusicService.shared.searchAndPlay(query: intent.query ?? "")
    }
}
```

### Check Authorization

```swift
if #available(iOS 15.0, *) {
    let service = AppleMusicService.shared
    if service.isAuthorized {
        // Can use Apple Music
    } else {
        // Request authorization
        let authorized = await service.requestAuthorization()
    }
}
```

---

## ✅ Checklist

Before testing, make sure:

- [ ] MusicKit framework added to project
- [ ] Info.plist has NSAppleMusicUsageDescription
- [ ] Apple Music capability enabled
- [ ] App ID configured in Developer Portal
- [ ] Device has iOS 15.0+
- [ ] User has Apple Music subscription
- [ ] User is signed into Apple ID

---

## 🎉 Success!

Once setup is complete, users can say:
- "play some lofi music" → Real lofi from Apple Music
- "play jazz" → Real jazz from Apple Music
- "play study beats" → Real study music from Apple Music

And hear ACTUAL music from the Apple Music catalog! 🎵✨

