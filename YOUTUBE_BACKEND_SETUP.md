# 🎵 YouTube Backend Setup Guide

## Overview

The YouTube backend extracts audio stream URLs from YouTube videos, allowing the Strawbie app to play music directly through AVPlayer.

**Flow:**
1. User says "Play lofi music"
2. App sends query to backend
3. Backend searches YouTube
4. Backend extracts audio stream URL
5. App receives URL and plays via AVPlayer

---

## Local Development Setup

### Step 1: Install Prerequisites

```bash
# macOS
brew install node ffmpeg

# Linux
sudo apt-get install nodejs npm ffmpeg

# Windows (using Homebrew)
choco install nodejs ffmpeg
```

### Step 2: Set Up Backend

```bash
# Navigate to youtube-backend directory
cd youtube-backend

# Install dependencies
npm install

# Start development server
npm run dev
```

Server runs on `http://localhost:3000`

### Step 3: Test Backend Locally

```bash
# Test health check
curl http://localhost:3000/health

# Test search and extract
curl -X POST http://localhost:3000/api/search-and-extract \
  -H "Content-Type: application/json" \
  -d '{"query": "lofi hip hop beats"}'
```

You should get back an audio URL!

---

## Update iOS App

### Step 1: Modify YouTubeService.swift

Replace the current `searchMusic` function with backend integration:

```swift
/// Search YouTube via backend and get playable audio URL
func searchMusic(query: String) async throws -> [MusicTrack] {
    print("🔍 Searching YouTube (via backend) for: \(query)")
    
    // Use your backend URL here
    let backendURL = "http://your-backend-url.com"  // ← UPDATE THIS
    
    guard let url = URL(string: "\(backendURL)/api/search-and-extract") else {
        throw YouTubeError.invalidURL
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = ["query": "\(query) music"]
    request.httpBody = try JSONEncoder().encode(body)
    
    print("🎥 Fetching from backend...")
    
    let (data, response) = try await URLSession.shared.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        print("❌ Backend error")
        throw YouTubeError.apiError
    }
    
    // Parse response
    let backendResponse = try JSONDecoder().decode(BackendResponse.self, from: data)
    
    print("✅ Got audio URL from backend")
    print("🎵 Title: \(backendResponse.title)")
    print("📱 Audio URL: \(backendResponse.audioUrl.prefix(50))...")
    
    // Create MusicTrack with the playable audio URL
    let track = MusicTrack(
        id: backendResponse.videoId,
        title: backendResponse.title,
        artist: "YouTube",
        artworkURL: backendResponse.thumbnail,
        audioURL: backendResponse.audioUrl,  // This is now playable!
        duration: backendResponse.duration
    )
    
    return [track]  // Return array with one track
}

// Add this struct to decode backend response
struct BackendResponse: Codable {
    let success: Bool
    let audioUrl: String
    let title: String
    let videoId: String
    let duration: Double
    let thumbnail: String?
    let url: String
    let extractedAt: String
    
    enum CodingKeys: String, CodingKey {
        case success, title, duration, url
        case audioUrl = "audioUrl"
        case videoId = "videoId"
        case thumbnail, extractedAt
    }
}
```

---

## Production Deployment

### Option 1: Railway.app (Recommended - Easiest)

1. Go to https://railway.app
2. Sign up with GitHub
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose your DAOmates repo
6. Railway auto-detects Node.js
7. Add environment variables:
   - `PORT=3000`
   - `NODE_ENV=production`
8. Deploy! Railway generates a URL like `https://your-app-railway.up.railway.app`

### Option 2: Heroku

```bash
# Install Heroku CLI
brew install heroku

# Login
heroku login

# Create app
heroku create strawbie-youtube-backend

# Add FFmpeg buildpack (needed for audio processing)
heroku buildpacks:add https://github.com/jonathanong/heroku-buildpack-ffmpeg-latest.git -a strawbie-youtube-backend

# Deploy
git push heroku main

# View logs
heroku logs --tail -a strawbie-youtube-backend

# Your URL will be: https://strawbie-youtube-backend.herokuapp.com
```

### Option 3: DigitalOcean / AWS

Follow their Node.js deployment guides. Make sure to:
- Install FFmpeg on the server
- Set PORT environment variable
- Use a process manager (PM2)

---

## Update iOS App with Production URL

Once deployed, update `YouTubeService.swift`:

```swift
// BEFORE (local development)
let backendURL = "http://localhost:3000"

// AFTER (production)
let backendURL = "https://your-app-railway.up.railway.app"
// or
let backendURL = "https://strawbie-youtube-backend.herokuapp.com"
```

---

## Testing

### Test Commands

```bash
# Health check
curl https://your-deployed-url.com/health

# Search and extract
curl -X POST https://your-deployed-url.com/api/search-and-extract \
  -H "Content-Type: application/json" \
  -d '{"query": "lofi beats"}'
```

### In iOS App

1. Build and run
2. Say "Play lofi music"
3. Should see in Xcode console:
   ```
   🔍 Searching YouTube (via backend) for: lofi
   🎥 Fetching from backend...
   ✅ Got audio URL from backend
   🎵 Title: Lofi Hip Hop Beats...
   🎵 Attempting to play: Lofi Hip Hop Beats...
   ✅ Player item ready to play!
   ```

---

## Troubleshooting

### Backend won't start

```bash
# Check Node version
node --version  # Should be 16+

# Check FFmpeg
which ffmpeg
ffmpeg -version

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install
```

### Audio URL is invalid

```bash
# Test yt-dlp directly
yt-dlp -f "bestaudio[ext=m4a]/bestaudio" --get-url "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# If this doesn't work, yt-dlp may need update
npm update yt-dlp
```

### CORS errors

Backend already has CORS enabled. If still getting errors, check:
- Backend URL in iOS app
- Network connectivity
- Firewall rules

### Memory issues on Heroku

Add more dynos or restart:
```bash
heroku ps:restart -a strawbie-youtube-backend
```

---

## Performance Tips

### Caching

Add Redis caching to avoid re-extracting the same URLs:

```javascript
// Cache URLs for 24 hours
cache.set(query, audioUrl, 86400);
```

### Rate Limiting

Implement rate limiting to prevent abuse:

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // 100 requests per window
});

app.use('/api/', limiter);
```

### Monitoring

Monitor these in production:
- Request latency
- Error rates
- FFmpeg process count
- Memory usage

---

## Security

### Best Practices

1. **Use HTTPS in production** - Railway and Heroku provide this by default
2. **Validate input** - Check query length and characters
3. **Rate limit** - Prevent abuse
4. **Monitor logs** - Watch for errors
5. **Rotate credentials** - If using any API keys

---

## Cost

### Railway.app
- Free tier: Great for hobby projects
- Paid: $5-15/month for production

### Heroku
- Free tier: Discontinued
- Hobby dyno: $7/month

### DigitalOcean
- Basic droplet: $5/month

---

## Next Steps

1. ✅ Set up backend locally
2. ✅ Test with curl commands
3. ✅ Deploy to Railway/Heroku
4. ✅ Update iOS app with production URL
5. ✅ Test music playback in app
6. ✅ Monitor for issues

---

## Support

If something doesn't work:

1. Check backend logs:
   ```bash
   # Local
   npm run dev  # Shows output

   # Heroku
   heroku logs --tail

   # Railway
   View logs in Dashboard
   ```

2. Test backend directly with curl
3. Check iOS app network requests in Xcode

**Let's get music playing!** 🎧🎵

