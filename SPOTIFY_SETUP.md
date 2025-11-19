
# 🎧 Spotify Integration Setup Guide

## Overview

This app uses the **Spotify Web API** with **Client Credentials Flow** - completely FREE and no user login required!

---

## Step 1: Create Spotify App (FREE)

### 1. Go to Spotify Developer Dashboard
https://developer.spotify.com/dashboard

### 2. Log in with your Spotify account
- Use your existing Spotify account (free or premium)
- No payment required!

### 3. Create a new app
- Click "Create app"
- **App name**: "Strawbie Music" (or whatever you want)
- **App description**: "AI companion app with music integration"
- **Redirect URI**: Leave blank or use `strawbie://callback`
- **API**: Check "Web API"
- Click "Save"

### 4. Get your credentials
- Click on your new app
- Click "Settings"
- You'll see:
  - **Client ID**: Copy this
  - **Client Secret**: Click "View client secret" and copy

---

## Step 2: Add Credentials to Your App

### 1. Open Info.plist
Located at: `DAOmates/Info.plist`

### 2. Add these two keys:

```xml
<key>SPOTIFY_CLIENT_ID</key>
<string>YOUR_CLIENT_ID_HERE</string>
<key>SPOTIFY_CLIENT_SECRET</key>
<string>YOUR_CLIENT_SECRET_HERE</string>
```

**Example:**
```xml
<key>SPOTIFY_CLIENT_ID</key>
<string>abc123def456ghi789jkl012mno345pq</string>
<key>SPOTIFY_CLIENT_SECRET</key>
<string>xyz789abc456def123ghi890jkl567mno</string>
```

### 3. Save the file

---

## Step 3: Test It!

1. **Build and run** your app (⌘R)
2. Say **"play drake music"** or any artist/song
3. Check the Xcode console for:

```
🎧 Attempting Spotify search for: drake
🔑 Requesting new Spotify access token...
✅ Spotify access token obtained
🔍 Searching Spotify for: drake
✅ Found 10 tracks from Spotify
🎵 Using Spotify for playback
```

---

## How It Works

### Client Credentials Flow
- **No user login required!**
- App authenticates with Spotify using Client ID + Secret
- Gets access to search and preview tracks
- Perfect for background music in your app

### What You Get
- ✅ Search the entire Spotify catalog
- ✅ Get track metadata (title, artist, album art)
- ✅ 30-second preview URLs for each track
- ✅ Completely FREE
- ✅ No user permissions needed

### Limitations
- ⚠️ Only 30-second previews (not full tracks)
- ⚠️ Cannot control user's Spotify player
- ⚠️ Cannot access user's playlists

**Note**: For full track playback, users would need Spotify Premium and you'd need to implement OAuth flow. But 30-second previews work great for a music discovery feature!

---

## Troubleshooting

### "Spotify credentials not found"
- Make sure you added both keys to Info.plist
- Check spelling: `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET`
- Make sure keys are at root level of plist (not nested)

### "Failed to authenticate with Spotify"
- Verify your Client ID and Secret are correct
- Make sure there are no extra spaces
- Try regenerating the Client Secret in Spotify Dashboard

### "Failed to search Spotify catalog"
- Check your internet connection
- Verify authentication is working (check logs)
- Make sure your Spotify app is active (not deleted)

---

## API Limits

**Spotify Web API (Free Tier)**:
- ✅ Unlimited searches
- ✅ No rate limits for basic usage
- ✅ No cost

You're good to go! 🎉

---

## Next Steps

Once you have Spotify working:
1. Music will play automatically when users request songs
2. Falls back to YouTube if Spotify fails
3. Falls back to sample tracks if both fail

Your app now has 3 layers of music sources! 🎵

---

## Security Note

**IMPORTANT**: Don't commit your Client Secret to GitHub!

Add to `.gitignore`:
```
Info.plist
```

Or use environment variables for production.

