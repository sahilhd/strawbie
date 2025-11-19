# 🎵 Music Integration Guide for DAOmates

## Overview
This guide explains how to integrate music playback into your DAOmates app. The music player widget is already built and ready to use. You just need to connect it to a music source.

---

## 🎯 Current Implementation

### What's Already Built:
✅ **MusicPlayerWidget** - Beautiful UI with compact and expanded views  
✅ **MusicService** - Handles playback, playlist management, and controls  
✅ **Music Intent Detection** - Automatically detects when users request music in chat  
✅ **Integration with Chat** - Music player appears when music is requested  

### How It Works:
1. User types: "play some lofi music"
2. App detects music intent
3. Music player widget appears
4. Music starts playing

---

## 🎼 Music Integration Options

### **Option 1: YouTube Music API (RECOMMENDED - Simplest)**

#### Why YouTube?
- ✅ **No authentication required** for basic playback
- ✅ **Huge music library** - almost every song exists
- ✅ **Free to use** (with API key)
- ✅ **Simple REST API**
- ❌ May have ads (can be worked around)

#### Implementation Steps:

**1. Get YouTube Data API Key:**
```
1. Go to: https://console.cloud.google.com/
2. Create a new project
3. Enable "YouTube Data API v3"
4. Create credentials (API key)
5. Copy your API key
```

**2. Add to AppConfig.swift:**
```swift
struct AppConfig {
    static let youtubeAPIKey = "YOUR_YOUTUBE_API_KEY"
}
```

**3. Update MusicService.swift:**
```swift
// Add YouTube search function
func searchYouTube(query: String) async throws -> [MusicTrack] {
    let searchQuery = "\(query) official audio".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(searchQuery)&type=video&videoCategoryId=10&maxResults=10&key=\(AppConfig.youtubeAPIKey)"
    
    guard let url = URL(string: urlString) else { throw MusicError.invalidURL }
    
    let (data, _) = try await URLSession.shared.data(from: url)
    let response = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
    
    return response.items.map { item in
        MusicTrack(
            id: item.id.videoId,
            title: item.snippet.title,
            artist: item.snippet.channelTitle,
            artworkURL: item.snippet.thumbnails.high.url,
            audioURL: "https://www.youtube.com/watch?v=\(item.id.videoId)",
            duration: 180.0 // Estimate, can get exact from video API
        )
    }
}

// Update searchAndPlay to use YouTube
func searchAndPlay(query: String) async {
    do {
        let tracks = try await searchYouTube(query: query)
        await MainActor.run {
            self.playlist = tracks
            if !tracks.isEmpty {
                self.play(track: tracks[0])
            }
        }
    } catch {
        print("❌ YouTube search failed: \(error)")
    }
}
```

**4. Add YouTube Data Models:**
```swift
struct YouTubeSearchResponse: Codable {
    let items: [YouTubeVideo]
}

struct YouTubeVideo: Codable {
    let id: VideoId
    let snippet: Snippet
    
    struct VideoId: Codable {
        let videoId: String
    }
    
    struct Snippet: Codable {
        let title: String
        let channelTitle: String
        let thumbnails: Thumbnails
    }
    
    struct Thumbnails: Codable {
        let high: Thumbnail
    }
    
    struct Thumbnail: Codable {
        let url: String
    }
}
```

**5. For Audio Extraction:**
Use a library like **XCDYouTubeKit** or **youtube-dl** to extract direct audio URLs from YouTube videos.

```swift
// Using XCDYouTubeKit (add via SPM)
import XCDYouTubeKit

func getYouTubeAudioURL(videoId: String) async -> String? {
    return await withCheckedContinuation { continuation in
        XCDYouTubeClient.default().getVideoWithIdentifier(videoId) { video, error in
            if let streamURLs = video?.streamURLs,
               let audioURL = streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ??
                              streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] {
                continuation.resume(returning: audioURL.absoluteString)
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
}
```

---

### **Option 2: Apple Music API**

#### Why Apple Music?
- ✅ **Official Apple integration**
- ✅ **High quality audio**
- ✅ **Native iOS support**
- ❌ Requires Apple Music subscription
- ❌ More complex authentication

#### Implementation Steps:

**1. Setup Apple Music:**
```
1. Join Apple Developer Program
2. Create MusicKit identifier
3. Generate MusicKit key
```

**2. Add MusicKit framework:**
```swift
import MusicKit

// Request authorization
let status = await MusicAuthorization.request()

// Search for music
let request = MusicCatalogSearchRequest(term: "lofi beats", types: [Song.self])
let response = try await request.response()

// Play songs
let player = ApplicationMusicPlayer.shared
player.queue = [song]
try await player.play()
```

**3. Update Info.plist:**
```xml
<key>NSAppleMusicUsageDescription</key>
<string>We need access to play music for you</string>
```

---

### **Option 3: Spotify API**

#### Why Spotify?
- ✅ **Massive music library**
- ✅ **Good API documentation**
- ❌ Requires Spotify Premium for playback
- ❌ Complex OAuth authentication
- ❌ Can't play in background easily

#### Implementation Steps:

**1. Register App:**
```
1. Go to: https://developer.spotify.com/dashboard
2. Create an app
3. Get Client ID and Client Secret
4. Add redirect URI: daomates://callback
```

**2. Add SpotifyiOS SDK:**
```swift
// Add via SPM or CocoaPods
import SpotifyiOS

// Configure
let configuration = SPTConfiguration(
    clientID: "YOUR_CLIENT_ID",
    redirectURL: URL(string: "daomates://callback")!
)

// Authenticate
let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
```

**3. Search and Play:**
```swift
// Search
func searchSpotify(query: String) async throws -> [MusicTrack] {
    let urlString = "https://api.spotify.com/v1/search?q=\(query)&type=track&limit=10"
    // ... API call with OAuth token
}

// Play using Spotify App Remote
appRemote.playerAPI?.play(trackURI)
```

---

### **Option 4: SoundCloud API**

#### Why SoundCloud?
- ✅ **Free to use**
- ✅ **Good for indie/underground music**
- ✅ **Simple API**
- ❌ Smaller library than Spotify/YouTube
- ❌ API access can be limited

---

### **Option 5: Local Audio Files**

#### Why Local Files?
- ✅ **No API needed**
- ✅ **No internet required**
- ✅ **Full control**
- ❌ Limited music selection
- ❌ Large app size

#### Implementation:
```swift
// Add MP3 files to your project
// Update MusicService to use local files
let audioURL = Bundle.main.url(forResource: "lofi-beats", withExtension: "mp3")!
```

---

## 🚀 Quick Start (Recommended Path)

### **Best Approach: YouTube + XCDYouTubeKit**

1. **Install XCDYouTubeKit:**
   ```
   File > Add Package Dependencies
   https://github.com/0xced/XCDYouTubeKit
   ```

2. **Get YouTube API Key** (5 minutes)

3. **Update MusicService.swift** with YouTube search (copy code from Option 1)

4. **Test it:**
   ```
   User: "play some lofi music"
   App: Searches YouTube → Plays first result
   ```

---

## 🎨 UI Features Already Built

### Compact Player:
- Album art thumbnail
- Track title and artist
- Play/pause button
- Expand button

### Expanded Player:
- Large album art
- Track info
- Progress bar with time
- Previous/Play/Next controls
- Collapse button

### Auto-Show:
- Appears when music is requested in chat
- Stays visible while music is playing
- Smooth animations

---

## 📝 Example User Interactions

```
User: "play some chill music"
→ Searches for "chill music" → Plays top result

User: "put on lofi beats"
→ Searches for "lofi beats" → Creates playlist

User: "next song"
→ Skips to next track in playlist

User: "pause"
→ Pauses current track

User: "play focus music"
→ Searches for "focus music" → Plays
```

---

## 🔧 Testing Without API

The current implementation includes **sample tracks** that work without any API:

```swift
// In MusicService.swift - createSamplePlaylist()
// Uses free SoundHelix demo tracks
```

You can test the UI and playback controls immediately!

---

## 📊 Comparison Table

| Option | Setup Time | Cost | Library Size | Quality | Complexity |
|--------|-----------|------|--------------|---------|------------|
| **YouTube** | 10 min | Free | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ |
| **Apple Music** | 30 min | $9.99/mo | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Spotify** | 20 min | $9.99/mo | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **SoundCloud** | 15 min | Free | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Local Files** | 5 min | Free | ⭐ | ⭐⭐⭐⭐⭐ | ⭐ |

---

## 🎯 Recommendation

**Start with YouTube + XCDYouTubeKit:**
1. Easiest to implement
2. No subscription required
3. Huge music library
4. Works great for MVP

**Later, add Apple Music:**
- For premium users
- Better audio quality
- Official iOS integration

---

## 💡 Tips

1. **Cache search results** to reduce API calls
2. **Preload next track** for seamless playback
3. **Add to Strawbie's responses**: "I'm playing some lofi music for you! 🎶"
4. **Background audio**: Enable in Xcode → Signing & Capabilities → Background Modes → Audio

---

## 🐛 Troubleshooting

**Music not playing?**
- Check audio session is configured
- Verify URL is valid
- Check internet connection

**Widget not showing?**
- Ensure `showMusicPlayer = true` when music starts
- Check `musicService.currentTrack != nil`

**Search not working?**
- Verify API key is correct
- Check API quota limits
- Test with Postman first

---

## 📚 Resources

- [YouTube Data API Docs](https://developers.google.com/youtube/v3)
- [Apple MusicKit Docs](https://developer.apple.com/documentation/musickit)
- [Spotify Web API Docs](https://developer.spotify.com/documentation/web-api)
- [XCDYouTubeKit GitHub](https://github.com/0xced/XCDYouTubeKit)

---

## ✅ Next Steps

1. Choose your music source (YouTube recommended)
2. Get API credentials
3. Update `MusicService.swift` with search implementation
4. Test with real music
5. Enjoy! 🎉

---

**Need help? The music player UI and infrastructure are ready to go. Just plug in your music source!** 🎵

