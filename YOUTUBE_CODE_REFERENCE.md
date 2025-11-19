# 🎵 YouTube Integration - Code Reference

Quick code snippets for working with YouTube music feature.

## Basic Usage

### Search for Music

```swift
// Simple search and play
await musicService.searchAndPlay(query: "lofi beats")
```

### Detect Music Intent

```swift
// Check if user wants music
if let intent = MusicService.detectMusicIntent(in: "play some jazz") {
    await musicService.searchAndPlay(query: intent.query ?? "music")
}
```

### Get YouTube Results

```swift
// Get raw YouTube search results
let tracks = try await YouTubeService.shared.searchMusic(query: "study music")
print("Found \(tracks.count) tracks")
```

## ABGChatView Integration

### Handle Music in Chat

```swift
func sendMessage() {
    let message = messageText
    
    // Check for music intent
    if let musicIntent = MusicService.detectMusicIntent(in: message) {
        print("🎵 Music requested: \(musicIntent.query ?? "music")")
        handleMusicIntent()
        messageText = ""
        return  // Don't send to OpenAI
    }
    
    // Normal chat flow
    chatViewModel.sendUserText(message)
    messageText = ""
}

func handleMusicIntent() {
    // Extract clean query
    let query = MusicService.extractMusicQuery(message: messageText)
    
    // Search and play
    Task {
        await musicService.searchAndPlay(query: query)
    }
    
    // Show custom response
    chatViewModel.messages.append(
        ChatMessage(content: "🎵 Now playing...", isFromUser: false)
    )
}
```

## MusicService Updates

### Configure YouTube Search

```swift
// In MusicService.searchAndPlay()
do {
    let youTubeTracks = try await YouTubeService.shared.searchMusic(query: query)
    
    await MainActor.run {
        self.playlist = youTubeTracks
        if !youTubeTracks.isEmpty {
            self.play(track: youTubeTracks[0])
        }
    }
} catch {
    print("⚠️ YouTube failed: \(error)")
    // Fallback to samples
}
```

## YouTubeService Methods

### Search YouTube

```swift
let tracks = try await YouTubeService.shared.searchMusic(query: "lofi beats")

// Returns: [MusicTrack]
// Each track has: id, title, artist, artworkURL, audioURL, duration
```

### Get Video Details

```swift
let (duration, views) = try await YouTubeService.shared.getVideoDetails(
    videoId: "abc123xyz"
)

print("Duration: \(duration) seconds")
print("Views: \(views)")
```

## MusicTrack Model

### Create from YouTube

```swift
let track = MusicTrack(
    id: "video_id",
    title: "Song Title",
    artist: "Artist Name",
    artworkURL: "https://...",  // Thumbnail URL
    audioURL: "https://www.youtube.com/watch?v=video_id",
    duration: 240.0
)
```

### Access Track Data

```swift
let track = musicService.currentTrack
print("Now playing: \(track?.title ?? "None")")
print("By: \(track?.artist ?? "Unknown")")
print("Duration: \(Int(track?.duration ?? 0) / 60) minutes")
```

## Configuration

### Get API Key (Config.swift)

```swift
// Automatic configuration
let key = AppConfig.youtubeAPIKey

// Tries in order:
// 1. YOUTUBE_API_KEY environment variable
// 2. YOUTUBE_API_KEY from Info.plist
// 3. Returns placeholder "YOUR_YOUTUBE_API_KEY"
```

## Error Handling

### Try-Catch Pattern

```swift
do {
    let tracks = try await YouTubeService.shared.searchMusic(query: query)
    // Use tracks
} catch YouTubeError.noAPIKey {
    print("API key not configured")
} catch YouTubeError.apiError {
    print("YouTube API error")
} catch YouTubeError.invalidURL {
    print("Invalid URL")
} catch {
    print("Unknown error: \(error)")
}
```

### With Fallback

```swift
async {
    let tracks = try? await YouTubeService.shared.searchMusic(query: query)
    
    if let tracks = tracks, !tracks.isEmpty {
        await MainActor.run {
            self.playlist = tracks
            self.play(track: tracks[0])
        }
    } else {
        // Use sample tracks
        let samples = createSamplePlaylist(for: query)
        await MainActor.run {
            self.playlist = samples
            self.play(track: samples[0])
        }
    }
}
```

## Playback Control

### Play/Pause

```swift
musicService.togglePlayPause()
// Sets: isPlaying = !isPlaying
// Calls: audioPlayer?.play() or audioPlayer?.pause()
```

### Skip Tracks

```swift
// Next track
musicService.nextTrack()

// Previous track
musicService.previousTrack()

// Specific track
musicService.play(track: playlist[index])
```

### Progress

```swift
let current = musicService.currentTime
let total = musicService.duration
let progress = current / total

print("\(Int(current / 60)):\(Int(current) % 60) / \(Int(total / 60)):\(Int(total) % 60)")
```

## UI Integration

### Music Player Widget

```swift
// In your view
if let _ = musicService.currentTrack {
    MusicPlayerWidget(musicService: musicService)
        .padding(.bottom, 12)
}
```

### Suggested Prompts

```swift
SuggestedPromptChip(text: "Play some music") { 
    messageText = "play some music"
    sendMessage()
}
```

## Console Logging

### Expected Output

```swift
// Successful search
print("🔍 Searching YouTube for: lofi beats")
print("🎥 Fetching from YouTube API...")
print("✅ Found 10 YouTube tracks")
print("🎵 Now playing: Best Lofi Hip Hop Mix")

// Error scenario
print("⚠️ YouTube search failed: API error")
print("🎵 Falling back to sample tracks: 2 tracks")
```

## Advanced Features

### Caching Search Results

```swift
var searchCache: [String: [MusicTrack]] = [:]

func searchWithCache(query: String) async throws -> [MusicTrack] {
    if let cached = searchCache[query] {
        return cached
    }
    
    let results = try await YouTubeService.shared.searchMusic(query: query)
    searchCache[query] = results
    return results
}
```

### Playlist Management

```swift
// Current playlist
print("Playlist: \(musicService.playlist.count) tracks")

// Current track
if let track = musicService.currentTrack {
    print("Now: \(track.title)")
}

// Current index
print("Track \(musicService.currentIndex + 1) of \(musicService.playlist.count)")
```

### Intent Detection

```swift
// Music intent types
if let intent = MusicService.detectMusicIntent(in: "play music") {
    switch intent.action {
    case .play:
        print("User wants to play: \(intent.query ?? "music")")
    case .pause:
        print("User wants to pause")
    case .next:
        print("User wants to skip")
    case .previous:
        print("User wants to go back")
    }
}
```

## Complete Example Flow

```swift
// 1. User types in chat
messageText = "play lofi beats"

// 2. Send message handler
if let musicIntent = MusicService.detectMusicIntent(in: messageText) {
    // 3. Show custom response
    chatViewModel.messages.append(
        ChatMessage(
            content: "🎵 Now playing...",
            isFromUser: false,
            videoURL: selectedOutfit.videoFileName
        )
    )
    
    // 4. Search YouTube
    Task {
        let query = musicIntent.query ?? "lofi beats"
        await musicService.searchAndPlay(query: query)
    }
    
    // 5. Don't send to OpenAI
    return
}

// 6. If not music, send to chat normally
chatViewModel.sendUserText(messageText)
```

## Testing Queries

```swift
// Try these in the app
let testQueries = [
    "play lofi beats",
    "put on some study music",
    "music please",
    "i want to hear jazz",
    "play relaxing sounds",
    "background music for focus",
    "some chill vibes",
    "sleep sounds"
]

for query in testQueries {
    Task {
        await musicService.searchAndPlay(query: query)
    }
}
```

## Debugging

### Enable Debug Logging

```swift
// In YouTubeService.swift
print("🔍 Searching YouTube for: \(query)")
print("🎥 Fetching from YouTube API...")
print("✅ Found \(tracks.count) YouTube tracks")

// In MusicService.swift
print("🎵 searchAndPlay called with query: \(query)")
print("🎵 Found \(youTubeTracks.count) YouTube tracks")
print("🎵 Now playing: \(track.title)")
```

### Check Console

```
🔍 Searching YouTube for: lofi beats
🎥 Fetching from YouTube API...
✅ Found 10 YouTube tracks

🎵 Now playing: Best Lofi Hip Hop Mix
Artist: Lofi Girl
Duration: 24:15:32
```

### Monitor API Calls

```swift
// Track API usage
var apiCallCount = 0
var totalQuotaUsed = 0

// Each search uses ~100 quota units
func trackAPICall() {
    apiCallCount += 1
    totalQuotaUsed += 100
    print("📊 API calls: \(apiCallCount), Quota used: \(totalQuotaUsed) / 10000")
}
```

## Performance Tips

### Optimize Search

```swift
// More specific query = better results
await musicService.searchAndPlay(query: "lo-fi hip hop beats to relax/study to")

// Less specific
await musicService.searchAndPlay(query: "music")
```

### Cache Results

```swift
// Avoid repeated API calls
let cachedResults = searchCache[query]
if cachedResults != nil {
    // Use cached
} else {
    // Do new search
}
```

### Limit Requests

```swift
// Debounce searches
var lastSearchTime: Date?

func searchIfNotRecent(query: String) async {
    if let last = lastSearchTime, 
       Date().timeIntervalSince(last) < 1.0 {
        return  // Too soon, skip
    }
    
    await musicService.searchAndPlay(query: query)
    lastSearchTime = Date()
}
```

## Common Patterns

### Music Request Handler

```swift
func handleMusicRequest(_ message: String) async {
    guard let intent = MusicService.detectMusicIntent(in: message) else {
        return
    }
    
    let query = MusicService.extractMusicQuery(message: message)
    
    // Show response
    chatViewModel.messages.append(
        ChatMessage(content: "🎵 Playing...", isFromUser: false)
    )
    
    // Search and play
    await musicService.searchAndPlay(query: query)
}
```

### Search with Timeout

```swift
func searchWithTimeout(query: String, timeout: TimeInterval = 3.0) async {
    let task = Task {
        try await YouTubeService.shared.searchMusic(query: query)
    }
    
    let result = try? await withThrowingTaskGroup(of: [MusicTrack].self) { group -> [MusicTrack] in
        return try await task.value
    }
    
    // Handle result
}
```

---

## Quick Reference Table

| Method | Purpose | Returns |
|--------|---------|---------|
| `searchMusic(query:)` | Search YouTube | `[MusicTrack]` |
| `getVideoDetails(videoId:)` | Get duration & views | `(Double, String)` |
| `detectMusicIntent(in:)` | Detect music request | `MusicIntent?` |
| `play(track:)` | Start playback | Void |
| `togglePlayPause()` | Pause/resume | Void |
| `nextTrack()` | Skip to next | Void |
| `previousTrack()` | Go to previous | Void |
| `seek(to:)` | Seek to position | Void |

---

**Ready to use YouTube music?** Start implementing with these code snippets! 🎵✨

