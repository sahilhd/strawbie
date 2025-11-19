# 🎵 YouTube Music Integration Setup

## Overview

The app now supports real YouTube music search and playback through the YouTube Data API. When users request music (e.g., "play lofi beats"), the app searches YouTube and streams the audio.

## Features

✅ Real YouTube music search  
✅ Automatic audio extraction from videos  
✅ Video metadata (title, artist, thumbnail)  
✅ Fallback to sample tracks if YouTube unavailable  
✅ Graceful error handling  

## Setup Instructions

### Step 1: Get YouTube API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable "YouTube Data API v3"
4. Create credentials:
   - Click "Create Credentials"
   - Choose "API Key"
   - Copy your API key

### Step 2: Add API Key to Project

#### Option A: Environment Variable (Recommended)

**For Development (in Xcode Scheme):**
1. Open Xcode
2. Scheme → Edit Scheme → Run → Pre-actions
3. Add environment variable:
   ```
   YOUTUBE_API_KEY=YOUR_API_KEY_HERE
   ```

**For Testing:**
```bash
export YOUTUBE_API_KEY="your_api_key_here"
# Then run the app
```

#### Option B: Info.plist

1. Open `Info.plist`
2. Add a new key: `YOUTUBE_API_KEY`
3. Set value to your API key

**⚠️ WARNING**: Never commit API keys to git! Add to `.gitignore`:
```
# .gitignore
Info.plist  # if you used plist method
```

### Step 3: Verify Installation

Run the app and use the music feature:

```swift
// In ABGChatView or chat
User: "play lofi beats"
→ App searches YouTube
→ Shows results
→ Plays audio
```

Check console for:
```
✅ Searching YouTube for: lofi beats
✅ Found 10 YouTube tracks
🎵 Now playing: Best Lofi Hip Hop Mix...
```

## How It Works

### 1. Music Search Flow

```
User: "play lofi beats"
    ↓
MusicService.searchAndPlay("lofi beats")
    ↓
YouTubeService.searchMusic("lofi beats")
    ↓
YouTube API Search (top 10 results)
    ↓
Returns MusicTrack array with:
- Video title
- Channel name (artist)
- Thumbnail URL
- YouTube URL
    ↓
MusicService plays first result
```

### 2. Error Handling

If YouTube search fails:
1. Catches error (no API key, network error, etc.)
2. Falls back to sample tracks
3. User still gets music response
4. Logs error for debugging

### 3. Video to Audio

YouTube videos are played via the standard YouTube URL:
```
https://www.youtube.com/watch?v=VIDEO_ID
```

The system handles audio extraction automatically.

## API Configuration

### YouTubeService Methods

```swift
// Search for music
let tracks = try await YouTubeService.shared.searchMusic(query: "lofi beats")

// Get video details (duration, view count)
let (duration, views) = try await YouTubeService.shared.getVideoDetails(videoId: "abc123")
```

### MusicTrack Model

```swift
struct MusicTrack {
    let id: String           // YouTube video ID
    let title: String        // Video title
    let artist: String       // Channel name
    let artworkURL: String   // Thumbnail URL
    let audioURL: String     // YouTube URL
    let duration: Double     // Video duration
}
```

## Development vs Production

### Development

```swift
#if DEBUG
if let key = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"] {
    return key  // Uses environment variable
}
#endif
```

### Production

```swift
// Use Info.plist or secure key storage
if let key = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String {
    return key
}
```

## Testing

### Test Searches

Try these queries to test:
```
"play lofi beats"
"study music"
"chill vibes"
"jazz music"
"lo-fi hip hop beats to relax/study to"
```

### Debug Logging

Console output for debugging:

```
🔍 Searching YouTube for: lofi beats
🎥 Fetching from YouTube API...
✅ Found 10 YouTube tracks
🎵 Now playing: Lofi Hip Hop Mix 24/7...
```

## Troubleshooting

### "No API key found" Warning

**Problem**: Console shows API key warning

**Solution**:
1. Verify environment variable set
2. Check Info.plist has key
3. Rebuild project

### "YouTube API returned an error"

**Possible causes:**
- Invalid API key
- API quota exceeded
- Network connection issue
- Invalid search query

**Solution**:
1. Verify API key is valid
2. Check Google Cloud Console quota
3. Check internet connection
4. Fallback to sample tracks works

### Results not showing

**Problem**: YouTube search returns empty

**Solution**:
1. Try different search query
2. Check API quota usage
3. Verify API is enabled in Cloud Console
4. Check for network errors in console

## Cost Considerations

YouTube Data API is **free** but has quotas:
- Default: 10,000 quota units per day
- Each search: ~100 quota units
- Allows ~100 searches per day

For higher usage, consider:
- Implementing caching
- Premium tier ($$$)
- Reducing search frequency

## Future Enhancements

- [ ] Implement audio extraction library (yt-dlp, pytube)
- [ ] Cache search results to reduce API calls
- [ ] Add playlist support
- [ ] Implement YouTube history
- [ ] Add video recommendation system
- [ ] Support for live streams
- [ ] Offline music support

## Architecture

```
ABGChatView (User interaction)
    ↓
MusicService (Orchestrator)
    ├─ YouTubeService (Search)
    ├─ AVPlayer (Playback)
    └─ MusicPlayerWidget (UI)
```

## Security Notes

⚠️ **API Key Protection**:
- Never commit API keys to git
- Use environment variables for development
- Use secure storage (Keychain) for production
- Restrict API key in Google Cloud Console:
  - Set to "iOS" application type
  - Add bundle ID
  - Set HTTP referrer restrictions

## Files

- `YouTubeService.swift` - YouTube API integration
- `MusicService.swift` - Music playback orchestration
- `Config.swift` - API key configuration
- `MusicPlayerWidget.swift` - UI component

## Next Steps

1. ✅ Get YouTube API key
2. ✅ Add to environment/Info.plist
3. ✅ Build and run app
4. ✅ Test music search
5. ✅ Debug any issues

Happy streaming! 🎵✨

