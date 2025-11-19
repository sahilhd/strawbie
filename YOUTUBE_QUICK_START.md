# 🚀 YouTube Music Integration - Quick Start

Get YouTube music working in 5 minutes!

## 1️⃣ Get API Key (2 minutes)

```bash
# Visit Google Cloud Console
https://console.cloud.google.com/

# Create project → Enable YouTube Data API v3 → Create API Key
# Copy the key
```

## 2️⃣ Add to Xcode (2 minutes)

**Option A: Environment Variable (Recommended)**

```bash
# In Xcode:
# Scheme → Edit Scheme → Run → Pre-actions
# Add environment variable:
YOUTUBE_API_KEY="YOUR_KEY_HERE"
```

**Option B: Info.plist**

```xml
<key>YOUTUBE_API_KEY</key>
<string>YOUR_KEY_HERE</string>
```

## 3️⃣ Test It (1 minute)

```swift
// In chat, user types:
"play lofi beats"

// Console should show:
✅ Searching YouTube for: lofi beats
✅ Found 10 YouTube tracks
🎵 Now playing: Best Lofi Mix...
```

## ✅ You're Done!

Music search is now live! 🎵

## Test Queries

```
play lofi beats
study music please
jazz vibes
chill out sounds
lo-fi hip hop beats to relax to
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "No API key found" | Set environment variable or Info.plist |
| No results | Try different search term |
| Network error | Check internet connection |
| API error | Verify API key is correct |

## Architecture

```
User: "play lofi beats"
  ↓
MusicService detects intent
  ↓
YouTubeService.searchMusic()
  ↓
YouTube Data API v3
  ↓
Return 10 results
  ↓
Play first result
  ↓
🎵 Music playing!
```

## Files Modified

- ✅ YouTubeService.swift (NEW)
- ✅ MusicService.swift (updated)
- ✅ Config.swift (updated)
- ✅ MusicPlayerWidget.swift (already improved)

## Next: Audio Extraction

For better streaming quality, consider:
- yt-dlp library (extract audio only)
- youtube-ios-player-helper
- Custom AVPlayer integration

For now, YouTube URLs work great! 🎶

---

**Need help?** Check YOUTUBE_SETUP.md for detailed docs.

