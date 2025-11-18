# 🎵 YouTube Music Backend

Backend service to extract YouTube audio streams for music playback in the Strawbie app.

## 🚀 Quick Start

### Prerequisites

- Node.js 16+
- FFmpeg (for audio processing)
- yt-dlp (for YouTube extraction)

### Installation

```bash
# Navigate to youtube-backend directory
cd youtube-backend

# Install dependencies
npm install

# Install system dependencies
brew install ffmpeg  # macOS
# sudo apt-get install ffmpeg  # Linux
# choco install ffmpeg  # Windows
```

### Run Locally

```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

Server will start on `http://localhost:3000`

---

## 📡 API Endpoints

### 1. Health Check

```bash
GET /health
```

**Response:**
```json
{
  "status": "ok",
  "message": "YouTube Backend Service is running"
}
```

---

### 2. Extract Audio from YouTube URL

```bash
POST /api/extract-audio
Content-Type: application/json

{
  "videoId": "dQw4w9WgXcQ"
  // OR
  "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
}
```

**Response:**
```json
{
  "success": true,
  "audioUrl": "https://r4---...mp4",
  "title": "Rick Astley - Never Gonna Give You Up",
  "duration": 213,
  "thumbnail": "https://...",
  "extractedAt": "2024-01-15T10:30:00.000Z"
}
```

---

### 3. Search YouTube and Extract First Result

```bash
POST /api/search-and-extract
Content-Type: application/json

{
  "query": "lofi hip hop beats"
}
```

**Response:**
```json
{
  "success": true,
  "audioUrl": "https://r4---...mp4",
  "title": "lofi hip hop beats to study/relax to",
  "videoId": "jfKfPfyJRdk",
  "duration": 7200,
  "thumbnail": "https://...",
  "url": "https://www.youtube.com/watch?v=jfKfPfyJRdk",
  "extractedAt": "2024-01-15T10:30:00.000Z"
}
```

---

## 🔧 Environment Variables

Create a `.env` file:

```env
PORT=3000
NODE_ENV=development
```

---

## 📱 Integration with iOS App

Update `YouTubeService.swift`:

```swift
let backendURL = "http://your-backend-url.com"

// Search and extract
let url = URL(string: "\(backendURL)/api/search-and-extract")!
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.httpBody = try JSONEncoder().encode(["query": query])

let (data, _) = try await URLSession.shared.data(for: request)
let result = try JSONDecoder().decode(YouTubeResult.self, from: data)

// Use result.audioUrl directly in AVPlayer!
let player = AVPlayer(url: URL(string: result.audioUrl)!)
```

---

## 🚀 Deployment Options

### Option 1: Heroku (Free tier available)

```bash
# Install Heroku CLI
brew install heroku

# Login
heroku login

# Create app
heroku create your-app-name

# Deploy
git push heroku main

# View logs
heroku logs --tail
```

### Option 2: Railway.app (Easy, Free tier)

```bash
# Connect your GitHub repo
# Railway automatically detects Node.js
# Set environment variables in dashboard
# Deploy!
```

### Option 3: DigitalOcean / AWS / Google Cloud

Follow their Node.js deployment guides.

---

## ⚠️ Important Notes

### Rate Limiting
- YouTube may rate limit rapid requests
- Implement caching in production
- Add request queuing for many simultaneous users

### Terms of Service
- Ensure compliance with YouTube's ToS
- Consider user privacy
- Store URLs temporarily only

### FFmpeg Requirement
- Required for audio extraction
- Must be installed on server
- Heroku buildpacks available

---

## 🐛 Troubleshooting

### "yt-dlp not found"
```bash
npm install yt-dlp
```

### "ffmpeg not found"
```bash
brew install ffmpeg  # macOS
```

### "No audio URL found"
- Video may be region-restricted
- Video may be deleted
- Video may not have audio

### Heroku: "Build failed"
- Add buildpack: `heroku buildpacks:add https://github.com/jonathanong/heroku-buildpack-ffmpeg-latest.git`

---

## 📊 Monitoring

Monitor these metrics in production:

- Request latency
- Error rates
- FFmpeg processes
- Memory usage

---

## 📝 License

Internal use only - Strawbie App

---

## 🎧 Next Steps

1. Deploy backend to production
2. Update iOS app with backend URL
3. Test music search and playback
4. Monitor for issues
5. Add caching for performance

**Let's get music playing!** 🎵

