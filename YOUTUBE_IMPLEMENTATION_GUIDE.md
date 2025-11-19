# 🎵 YouTube Music Integration - Implementation Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interaction                        │
│  Chat: "play lofi beats" or "play some study music"        │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  ABGChatView.swift                           │
│  • Detects music intent via MusicService.detectMusicIntent │
│  • Calls handleMusicIntent()                                │
│  • Extracts query from message                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  MusicService.swift                          │
│  • searchAndPlay(query: String)                             │
│  • Manages AVPlayer for playback                            │
│  • Maintains playlist and current track                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                YouTubeService.swift                          │
│  • searchMusic(query: String) → [MusicTrack]               │
│  • getVideoDetails(videoId: String)                         │
│  • Calls YouTube Data API v3                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              YouTube Data API v3                             │
│  GET: https://www.googleapis.com/youtube/v3/search         │
│  Returns: Video title, artist, thumbnail, duration         │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              MusicTrack Array Returned                       │
│  • id, title, artist, artworkURL, audioURL, duration       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              AVPlayer plays audioURL                         │
│  URL: https://www.youtube.com/watch?v=VIDEO_ID             │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              MusicPlayerWidget.swift                         │
│  • Shows album art, title, artist                           │
│  • Play/Pause/Skip controls                                 │
│  • Progress bar                                             │
└─────────────────────────────────────────────────────────────┘
```

## Detailed Flow

### 1. Music Intent Detection

```swift
// In ABGChatView.sendMessage()

// User types: "play lofi beats"
let message = "play lofi beats"

// Check if it's a music request
if let musicIntent = MusicService.detectMusicIntent(in: message) {
    print("🎵 Music intent detected: \(musicIntent.action)")
    
    // Extract clean query
    handleMusicIntent()  // Gets "lofi beats"
    
    // Don't send to OpenAI
    return  // Early return - prevents API call
}
```

### 2. Search Execution

```swift
// In MusicService.searchAndPlay()

func searchAndPlay(query: String) async {
    print("🎵 Searching: \(query)")
    
    do {
        // Call YouTubeService
        let youTubeTracks = try await YouTubeService.shared.searchMusic(query: query)
        
        // Result: Array of MusicTrack objects
        // [
        //   {id: "abc123", title: "Lofi Mix", artist: "Artist Name", ...},
        //   {id: "def456", title: "Beats", artist: "Another Artist", ...}
        // ]
        
        await MainActor.run {
            self.playlist = youTubeTracks
            self.play(track: youTubeTracks[0])  // Play first result
        }
    } catch {
        print("⚠️ Error: \(error)")
        // Fallback to sample tracks
    }
}
```

### 3. YouTube API Call

```swift
// In YouTubeService.searchMusic()

func searchMusic(query: String) async throws -> [MusicTrack] {
    // Build URL
    let searchURL = "https://www.googleapis.com/youtube/v3/search" +
                   "?part=snippet" +
                   "&q=\(query)" +
                   "&type=video" +
                   "&maxResults=10" +
                   "&key=\(apiKey)"
    
    // Make request
    let (data, response) = try await URLSession.shared.data(from: url)
    
    // Parse response
    let searchResponse = try JSONDecoder().decode(YouTubeSearchResponse.self, from: data)
    
    // Convert to MusicTrack
    return searchResponse.items.map { video in
        MusicTrack(
            id: video.id.videoId,
            title: video.snippet.title,
            artist: video.snippet.channelTitle,
            artworkURL: video.snippet.thumbnails.high.url,
            audioURL: "https://www.youtube.com/watch?v=\(video.id.videoId)",
            duration: 0
        )
    }
}
```

### 4. Playback

```swift
// In MusicService.play()

func play(track: MusicTrack) {
    guard let url = URL(string: track.audioURL) else { return }
    
    let playerItem = AVPlayerItem(url: url)
    audioPlayer = AVPlayer(playerItem: playerItem)
    
    currentTrack = track
    isPlaying = true
    
    audioPlayer?.play()
    
    print("🎵 Now playing: \(track.title) by \(track.artist)")
}
```

## Data Models

### YouTube Search Response

```json
{
  "items": [
    {
      "id": {
        "videoId": "abc123"
      },
      "snippet": {
        "title": "Best Lofi Hip Hop Mix 24/7",
        "description": "...",
        "thumbnails": {
          "high": {
            "url": "https://...",
            "width": 480,
            "height": 360
          }
        },
        "channelTitle": "Lofi Girl"
      }
    }
  ]
}
```

### MusicTrack Model

```swift
struct MusicTrack: Identifiable, Codable {
    let id: String              // YouTube video ID
    let title: String           // Video title
    let artist: String          // Channel name
    let artworkURL: String?     // Thumbnail URL
    let audioURL: String        // YouTube watch URL
    let duration: TimeInterval  // Video duration (0 if not fetched)
}
```

## Error Handling

```
YouTube Search Flow:
    ↓
Try block
    ↓
URLSession.data() → Success? Continue : Throw error
    ↓
JSONDecoder → Success? Return tracks : Throw error
    ↓
Catch block
    ↓
Print error
    ↓
Fall back to sample tracks
    ↓
User still gets music response
```

## API Configuration

### Environment Variable Setup

```bash
# In Xcode Scheme
Scheme → Edit Scheme → Run → Pre-actions

# Add to script:
export YOUTUBE_API_KEY="AIzaSyD..."
```

### Code Configuration

```swift
// In Config.swift
static var youtubeAPIKey: String {
    // Try environment variable first
    if let key = ProcessInfo.processInfo.environment["YOUTUBE_API_KEY"] {
        return key
    }
    
    // Try Info.plist
    if let key = Bundle.main.object(forInfoDictionaryKey: "YOUTUBE_API_KEY") as? String {
        return key
    }
    
    return "YOUR_YOUTUBE_API_KEY"
}
```

## Features

### ✅ Implemented

- YouTube API search integration
- Video metadata extraction (title, artist, thumbnail)
- MusicTrack model creation
- Fallback to sample tracks
- Error handling and logging
- API key configuration
- Environment variable support

### 🔄 In Progress

- UI to display search results
- End-to-end testing

### 📋 Future

- Audio-only streaming (yt-dlp integration)
- Search result caching
- Playlist support
- YouTube history
- Recommendations

## Testing

### Unit Tests

```swift
// Test YouTubeService
func testSearchMusic() async throws {
    let tracks = try await YouTubeService.shared.searchMusic(query: "lofi beats")
    XCTAssertGreaterThan(tracks.count, 0)
    XCTAssertNotNil(tracks[0].artworkURL)
}
```

### Integration Tests

```swift
// Test full flow
func testMusicSearchAndPlay() async {
    let musicService = MusicService.shared
    
    await musicService.searchAndPlay(query: "study music")
    
    // Wait for results
    try await Task.sleep(nanoseconds: 2_000_000_000)
    
    XCTAssertNotNil(musicService.currentTrack)
    XCTAssertTrue(musicService.isPlaying)
}
```

### Manual Testing

```
1. Run app
2. Go to chat
3. Type: "play lofi beats"
4. Check console:
   🔍 Searching YouTube for: lofi beats
   🎥 Fetching from YouTube API...
   ✅ Found 10 YouTube tracks
   🎵 Now playing: Best Lofi Mix...
5. Music player appears with controls
6. Verify play/pause/skip works
```

## Console Output Examples

### Successful Search

```
🔍 Searching YouTube for: lofi beats
🎥 Fetching from YouTube API...
✅ Found 10 YouTube tracks
🎵 Now playing: Best Lofi Hip Hop Mix 24/7
Artist: Lofi Girl
Duration: 24:15:32
```

### With Fallback

```
🔍 Searching YouTube for: xyz music
🎥 Fetching from YouTube API...
❌ YouTube API error
⚠️ YouTube search failed: API error
🎵 Falling back to sample tracks: 2 tracks
🎵 Now playing: Lofi Study Beats
```

### No API Key

```
⚠️ Warning: No YouTube API key found. Music search will not work.
📝 To use YouTube music, set YOUTUBE_API_KEY environment variable or Info.plist
```

## Performance Considerations

### API Call Timing

```
Search request: ~500ms - 2s (network dependent)
Parse response: ~100ms
Display results: ~50ms
Total: 650ms - 2.1s
```

### Quota Management

- Default quota: 10,000 units/day
- Search cost: ~100 units
- Allows: ~100 searches/day
- Best practice: Implement caching

### Memory Usage

- One MusicTrack: ~2KB
- 10 search results: ~20KB
- Current playing: ~5KB
- Total: ~25KB per search session

## Security Best Practices

### API Key Protection

1. ✅ Never commit keys to git
2. ✅ Use environment variables
3. ✅ Use Info.plist for prod
4. ✅ Restrict key in Cloud Console
5. ✅ Set iOS app type restriction
6. ✅ Add bundle ID whitelist

### Network Security

- Uses HTTPS for all API calls
- Validates certificate
- No sensitive data in logs
- No key in user-visible output

## Deployment

### Development

```
YOUTUBE_API_KEY=dev_key_here
Build: Debug
Run on simulator/device
```

### Production

```
Info.plist contains key
Build: Release
Restrict key to production bundle ID
Monitor quota usage
```

## Troubleshooting

### Issue: "No API key found"

```
Check:
✅ Environment variable set correctly
✅ Info.plist has key
✅ Rebuild project
✅ Restart Xcode
```

### Issue: Empty search results

```
Check:
✅ YouTube API enabled
✅ API key quota not exceeded
✅ Search query valid
✅ Network connection
✅ Check console for errors
```

### Issue: Playback doesn't start

```
Check:
✅ YouTube URL format correct
✅ Network permission enabled
✅ AVAudioSession configured
✅ AVPlayer initialized
```

## Files Structure

```
DAOmates/
├── Services/
│   ├── YouTubeService.swift     (NEW)
│   ├── MusicService.swift       (UPDATED)
│   └── ...
├── Views/
│   └── Music/
│       └── MusicPlayerWidget.swift
├── Utils/
│   └── Config.swift             (UPDATED)
└── Documentation/
    ├── YOUTUBE_SETUP.md         (NEW)
    ├── YOUTUBE_QUICK_START.md   (NEW)
    └── YOUTUBE_IMPLEMENTATION_GUIDE.md (NEW)
```

---

**Ready to integrate?** Start with `YOUTUBE_QUICK_START.md`! 🚀

