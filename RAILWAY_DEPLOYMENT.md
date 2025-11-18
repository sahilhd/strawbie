# 🚀 Deploy YouTube Backend to Railway

Railway.app makes deploying your Node.js backend incredibly easy. Here's the step-by-step guide.

## Prerequisites

✅ Backend setup complete (`npm install` done)
✅ GitHub repository with youtube-backend code
✅ Railway account (free at https://railway.app)

---

## Step 1: Create Railway Account

1. Go to https://railway.app
2. Click "Start Free"
3. Sign up with GitHub (easiest method)
4. Authorize Railway to access your repositories

---

## Step 2: Deploy Backend to Railway

### Via Railway Dashboard (Easiest)

1. **Login to Railway**
   - Go to https://railway.app and log in

2. **Create New Project**
   - Click "New Project"
   - Select "Deploy from GitHub repo"

3. **Select Repository**
   - Choose your DAOmates repository
   - Connect if not already connected

4. **Configure Settings**
   - Railway should auto-detect it's a Node.js project
   - You don't need to change anything yet
   - Click "Deploy"

### Via Railway CLI (Alternative)

```bash
# Install Railway CLI
npm i -g @railway/cli

# Login to Railway
railway login

# Navigate to youtube-backend
cd youtube-backend

# Deploy
railway up

# Get your deployment URL
railway open
```

---

## Step 3: Set Up Environment Variables

1. **In Railway Dashboard**
   - Go to your project
   - Click "Variables" tab
   - Add these environment variables:

   ```
   PORT = 3000
   NODE_ENV = production
   ```

2. **Railway will automatically**
   - Install dependencies
   - Run `npm start`
   - Assign a public URL

---

## Step 4: Install System Dependencies (Important!)

YouTube backend needs `yt-dlp` and `ffmpeg` to extract audio.

1. **Add Buildpack**
   - In Railway, go to "Settings"
   - Find "Buildpacks" section
   - Add: `https://github.com/jonathanong/heroku-buildpack-ffmpeg-latest.git`

2. **Install yt-dlp via Procfile**
   - Create `Procfile` in root of youtube-backend:
   
   ```
   web: pip install yt-dlp && node server.js
   ```

   Actually, Railway uses Node buildpack, so create `package.json` post-install script instead:

   In `package.json`, add:
   ```json
   "scripts": {
     "postinstall": "pip install yt-dlp || echo 'yt-dlp install optional'",
     "start": "node server.js",
     "dev": "nodemon server.js"
   }
   ```

3. **Or use Railway's Python support:**
   - In `railway.json` (if exists) or Environment
   - Add Python support for yt-dlp

---

## Step 5: Get Your Deployment URL

1. **In Railway Dashboard**
   - Go to your project
   - Click "View Logs" to see it running
   - Your URL appears at the top, like:
     ```
     https://youtube-backend-production-xxxx.railway.app
     ```
   - Or find it under "Deployments"

2. **Test it**
   ```bash
   curl https://your-railway-url.railway.app/health
   ```

   You should get:
   ```json
   {
     "status": "ok",
     "message": "YouTube Backend Service is running"
   }
   ```

---

## Step 6: Update iOS App

Update `YouTubeService.swift` with your Railway URL:

```swift
// In YouTubeService.swift

func searchMusic(query: String) async throws -> [MusicTrack] {
    print("🔍 Searching YouTube for: \(query)")
    
    // YOUR RAILWAY URL HERE
    let backendURL = "https://your-railway-url.railway.app"  // ← UPDATE THIS
    
    guard let url = URL(string: "\(backendURL)/api/search-and-extract") else {
        throw YouTubeError.invalidURL
    }
    
    // ... rest of code ...
}
```

---

## Step 7: Test Backend

```bash
# Test health
curl https://your-railway-url.railway.app/health

# Test music search
curl -X POST https://your-railway-url.railway.app/api/search-and-extract \
  -H "Content-Type: application/json" \
  -d '{"query": "lofi hip hop"}'
```

You should get back:
```json
{
  "success": true,
  "audioUrl": "https://r4---...",
  "title": "Lofi Hip Hop Beats...",
  "duration": 7200
}
```

---

## Security Checklist ✅

Before deploying, make sure:

- [ ] `.gitignore` includes `.env`
- [ ] No API keys in code
- [ ] Environment variables set in Railway
- [ ] `.env` file NOT committed to git
- [ ] `package.json` doesn't include secrets
- [ ] `.gitignore` includes `node_modules/`

### Verify Nothing Was Committed

```bash
# Check git status
git status

# Make sure .env is not staged
git diff --cached

# If .env was committed, remove it
git rm --cached .env
git commit -m "Remove .env from git tracking"
```

---

## Troubleshooting

### Backend shows error in logs

1. **Check logs in Railway**
   - Go to project
   - Click "Logs" tab
   - See real-time errors

2. **Common issues:**
   - `yt-dlp command not found` → Need to install system dependency
   - Port already in use → Change PORT in variables
   - Out of memory → Upgrade Railway tier

### Music not playing

1. **Test backend directly**
   ```bash
   curl https://your-url/api/search-and-extract \
     -d '{"query": "test"}'
   ```

2. **Check if URL is valid**
   - Paste the returned `audioUrl` in browser
   - Should start downloading audio file

3. **Check iOS app logs**
   - Xcode console should show backend URL being called
   - Look for network errors

### Deploy doesn't work

1. **Check Node version**
   - Railway auto-detects from `package.json`
   - Make sure `engines.node` is set correctly

2. **Check buildpacks**
   - Make sure ffmpeg buildpack is added
   - Redeploy after adding buildpack

---

## Next Steps

1. ✅ Backend deployed on Railway
2. ✅ Environment variables set
3. ✅ System dependencies installed
4. ✅ iOS app updated with backend URL
5. ✅ Test music search and playback
6. ✅ Monitor for errors

---

## Monitor Your Deployment

**In Railway Dashboard:**

- **Logs** - Watch for errors in real-time
- **Deployments** - See deployment history
- **Metrics** - Monitor CPU, memory, bandwidth
- **Settings** - Update variables, add domain

---

## Free Tier Limits

Railway free tier includes:
- ✅ $5 USD credit monthly
- ✅ Unlimited projects
- ✅ Auto-scaling
- ✅ HTTPS included
- ⚠️ May pause after 72 hours inactivity

**Pro Tip:** Even with limits, free tier is great for hobby projects and testing!

---

## Need Help?

1. Check Railway docs: https://docs.railway.app
2. View backend logs in Railway dashboard
3. Test API with curl commands
4. Check iOS Xcode console for network errors

---

**Now your backend is live and your app can play real music!** 🎵🚀

